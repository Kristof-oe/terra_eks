
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  region       = var.region
  vpc_name     = var.vpc.name
  cidr_block   = var.vpc.cidr_block
  NAT_subnet   = var.vpc.NAT_subnet
  subnets      = var.vpc.subnets

  tags = var.vpc.tags

}

module "eks" {
  source          = "./modules/eks"
  vpc             = module.vpc.vpc
  vpc_cidr        = module.vpc.vpc_cidr
  name            = var.eks_cluster.name
  cluster_version = var.eks_cluster.version
  subnets         = module.vpc.all_subnet_ids
  # configure_kubectl = each.value.configure_kubectl
  node_group_name = var.node_group_name
  private_subnets = module.vpc.private_subnets
  aws_region      = var.region
  repo            = module.ecr.image_urls
}

module "ecr" {
  source = "./modules/ecr"

  ecr        = var.ecr
  aws_region = var.region
  # name                 = each.value.name
  # image_tag_mutability = each.value.image_tag_mutability
  # filter               = each.value.filter
  # filter_type          = each.value.filter_type
  # filter_              = each.value.filter_
  # filter_type_         = each.value.filter_type_
}
