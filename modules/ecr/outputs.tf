output "repo_url" {
  value = [for i in aws_ecr_repository.this : i.repository_url]
}

output "image_urls" {
  value      = { for i, j in aws_ecr_repository.this : i => j.repository_url }
  # value      = { for i, j in aws_ecr_repository.this : i => "${j.repository_url}:${i}" }
  # depends_on = [terraform_data.build_container]
}