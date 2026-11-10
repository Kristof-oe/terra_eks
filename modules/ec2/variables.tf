variable "name" {
  type = string
}

variable "type" {
  type = string
}

variable "ami" {
  type = string
}

variable "instances_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "tags" {
  type = map(string)
}