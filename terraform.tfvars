vpc = {
  name       = "aws_vpc"
  cidr_block = "10.0.0.0/16"
  tags       = {}
  NAT_subnet = "kris_public_1"
  subnets = [{
    name       = "kris_public_1"
    cidr_block = "10.0.0.0/24"
    type       = "public"
    },
    {
      name       = "kris_public_2"
      cidr_block = "10.0.1.0/24"
      type       = "public"
    },
    {
      name       = "kris_public_3"
      cidr_block = "10.0.2.0/24"
      type       = "public"
    },
    {
      name       = "kris_priv_1"
      cidr_block = "10.0.3.0/24"
      type       = "private"
    },
    {
      name       = "kris_priv_2"
      cidr_block = "10.0.4.0/24"
      type       = "private"
    },
    {
      name       = "kris_priv_3"
      cidr_block = "10.0.5.0/24"
      type       = "private"
  }]
}

eks_cluster = {
  name    = "eks_task"
  version = "1.37"
}

node_group_name = "kris_node"

ecr = [{
  name                 = "sa"
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"
  filter               = "s*"
  filter_type          = "WILDCARD"

  },
  {
    name                 = "sb"
    image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"
    filter               = "s*"
    filter_type          = "WILDCARD"
  }
]


