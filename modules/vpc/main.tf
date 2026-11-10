data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  subnets         = { for sn in var.subnets : sn.name => sn }
  public_subnets  = { for sn in var.subnets : sn.name => sn if sn.type == "public" }
  private_subnets = { for sn in var.subnets : sn.name => sn if sn.type == "private" }

  azs = data.aws_availability_zones.available.names

  # Spread each subnet type round-robin across AZs (public_1/priv_1 -> AZ a, _2 -> b, ...).
  # An explicit `availability_zone` on a subnet overrides this.
  subnet_azs = merge([
    for t in distinct([for sn in var.subnets : sn.type]) : {
      for i, sn in [for s in var.subnets : s if s.type == t] :
      sn.name => coalesce(sn.availability_zone, local.azs[i % length(local.azs)])
    }
  ]...)
}

resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  tags = merge({
    Name = "${var.vpc_name}-vpc"
  }, var.tags)
}

resource "aws_subnet" "this" {
  for_each          = local.subnets
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
  availability_zone = local.subnet_azs[each.key]

  tags = merge({
    Project = var.project_name
    Name    = "${var.project_name}-${each.value.type}-subnet${each.key}"
    },
    each.value.type == "public" ? { "kubernetes.io/role/elb" = "1" } : {}
  )
}

resource "aws_eip" "NAT" {
  count = length(local.private_subnets) != "" ? 1 : 0

  domain = "vpc"

  tags = {
    Project = var.project_name
    Name    = "${var.vpc_name}-NAT_IP"
  }
}

resource "aws_nat_gateway" "this" {
  count = length(local.public_subnets) != "" ? 1 : 0

  allocation_id = aws_eip.NAT[0].id
  subnet_id     = aws_subnet.this[var.NAT_subnet].id

  tags = {
    Project = var.project_name
    Name    = "${var.vpc_name}-NAT"
  }
}

resource "aws_internet_gateway" "this" {
  count  = length(local.public_subnets) != 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = {
    Project = var.project_name
    Name    = "${var.vpc_name}-IGW"
  }


}

resource "aws_route_table" "route_pub" {
  count  = length(local.public_subnets) != 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[count.index].id
  }
  tags = merge({
    Project = var.project_name
    Name    = "${var.vpc_name}-rt-pub"
  })
}

resource "aws_route_table" "route_priv" {
  count  = length(local.private_subnets) != 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.this[count.index].id
  }
  tags = merge({
    Project = var.project_name
    Name    = "${var.vpc_name}-rt-priv"
  })
}

resource "aws_route_table_association" "pub1" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.route_pub[0].id
}

resource "aws_route_table_association" "priv1" {
  for_each = local.private_subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.route_priv[0].id
}
