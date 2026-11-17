# output "dns_load" {
#   value= data.kubernetes_service_v1.nlb.status[0].load_balancer[0].ingress[0].hostname
# }
output "eks_cluster_name" {
  value = aws_eks_cluster.this.name
}