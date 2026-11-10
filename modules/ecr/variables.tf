# variable "name" {
#   type = string
# }

# variable "image_tag_mutability" {
#   type = string
# }

# variable "filter" {
#   type = string
# }

# variable "filter_type" {
#   type = string
# }

# variable "filter_" {
#   type = string
# }


# variable "filter_type_" {
#   type = string
# }

variable "ecr" {
  type = list(object({
    name                 = string
    image_tag_mutability = string
    filter               = string
    filter_type          = string
  }))
}

variable "aws_region" {
  type = string
}