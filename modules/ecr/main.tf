locals {
  ecrs = { for i in var.ecr : i.name => i }
}

resource "aws_ecr_repository" "this" {
  for_each             = local.ecrs
  name                 = each.value.name
  image_tag_mutability = each.value.image_tag_mutability

  image_tag_mutability_exclusion_filter {
    filter      = each.value.filter
    filter_type = each.value.filter_type
  }

}


# resource "terraform_data" "configure_ecr" {
#   for_each = aws_ecr_repository.this

#   depends_on = [aws_ecr_repository.this]
#   provisioner "local-exec" {
#     command = <<EOT
#       aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${each.value.repository_url}
#     EOT
#   }
# }

# resource "terraform_data" "build_container" {
#   depends_on = [terraform_data.configure_ecr]
#   for_each   = aws_ecr_repository.this
#   provisioner "local-exec" {
#     command = <<EOT
#       docker build -t ${each.value.name} ${path.root}/app/${each.value.name}/. 
#       docker tag ${each.value.name} ${each.value.repository_url}:${each.value.name} 
#       docker push ${each.value.repository_url}:${each.value.name}
#     EOT
#   }
# }

