
output "config_repo" {
  value = [for i in module.ecr.repo_url :
  format("aws ecr get-login-password --region %s | docker login --username AWS --password-stdin %s", var.region, i)]
}

# output "repo_url" {
#   value = module.ecr.repo_url
# }

# output "load_dns" {
#   value = [ for i in ["sa", "sb"] : 
#   format("curl http://%s/api/%s", module.eks.dns_load, i )]
# }