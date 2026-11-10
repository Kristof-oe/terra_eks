variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "tags" {
  type = map(string)
}
variable "NAT_subnet" {
  type = string
}

variable "subnets" {
  type = list(object({
    name              = string
    cidr_block        = string
    type              = string
    availability_zone = optional(string)
  }))
}

