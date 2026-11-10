variable "subnets" {
  type = list(any)
}

# variable "configure_kubectl" {
#   type = object({
#     aws_region = string
#     aws_cli_profile = string
#   })
#   default = {}
# }
variable "name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "vpc" {
  type = string
}

variable "vpc_cidr" {
  type = string
}


variable "node_group_name" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "aws_region" {
  type = string
}

variable "repo" {
  type = map(string)
}

