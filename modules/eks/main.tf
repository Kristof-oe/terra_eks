
resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.subnets
    security_group_ids      = [aws_security_group.eks_cluster.id]
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController
  ]
  tags = { Name = "eks_task" }
}


resource "terraform_data" "configure_kubectl" {
  depends_on = [aws_eks_cluster.this]

  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.this.name}
    EOT
  }
}
# --profile ${var.configure_kubectl.aws_cli_profile}

# resource "kubectl_manifest" "namespace" {
#   yaml_body = <<YAML
#   apiVersion: v1
#   kind: Namespace
#   metadata:
#     name: app
#   YAML
# }
# resource "kubectl_manifest" "a" {
#   depends_on = [aws_eks_node_group.this, kubectl_manifest.namespace]
#   yaml_body = templatefile("${path.root}/kubernet/sa/sad.yaml", {
#     ecr_image_url = var.repo["sa"]
#   })
#   # yaml_body = <<YAML
#   #   apiVersion: apps/v1
#   #   kind: Deployment
#   #   metadata:
#   #     name: sa
#   #     namespace: app
#   #   spec:
#   #     replicas: 3
#   #     selector:
#   #       matchLabels:
#   #         app: serviceA
#   #     template:
#   #       metadata:
#   #         labels:
#   #           app: serviceA
#   #       spec:
#   #       containers:
#   #       - name: sa
#   #         image: ${var.repo["sa"]}
#   #         ports:
#   #         - containerPort: 8080
#   # YAML
# }

# resource "kubectl_manifest" "b" {
#   depends_on = [aws_eks_node_group.this, kubectl_manifest.namespace]
#   yaml_body = templatefile("${path.root}/kubernet/sb/sbd.yaml", {
#     ecr_image_url = var.repo["sb"]
#   })
#   # yaml_body = <<YAML
#   #   apiVersion: apps/v1
#   #   kind: Deployment
#   #   metadata:
#   #     name: sb
#   #     namespace: app
#   #   spec:
#   #     replicas: 3
#   #     selector:
#   #       matchLabels:
#   #         app: serviceB
#   #     template:
#   #       metadata:
#   #         labels:
#   #           app: serviceB
#   #       spec:
#   #       containers:
#   #       - name: sa
#   #         image: ${var.repo["sb"]}
#   #         ports:
#   #         - containerPort: 8080
#   # YAML
# }

# resource "terraform_data" "manifest" {
#   depends_on = [kubernetes_manifest.a, kubernetes_manifest.b]

#   provisioner "local-exec" {
#     command = <<EOT
#       kubernes apply ${path.module}/kubernet/ -R
#     EOT
#   }
# }

# resource "kubectl_manifest" "serviceA" {
#   depends_on = [aws_eks_node_group.this, kubectl_manifest.namespace]
#   yaml_body  = file("${path.root}/kubernet/sa/sas.yaml")
# }

# resource "kubectl_manifest" "serviceB" {
#   depends_on = [aws_eks_node_group.this, kubectl_manifest.namespace]
#   yaml_body  = file("${path.root}/kubernet/sb/sbs.yaml")
# }

# resource "kubectl_manifest" "daemonset" {
#   depends_on = [aws_eks_node_group.this, kubectl_manifest.namespace]
#   yaml_body  = file("${path.root}/kubernet/deamonset/deamonset.yaml")
# }

# resource "kubectl_manifest" "config" {
#   depends_on = [aws_eks_node_group.this, kubectl_manifest.namespace]
#   yaml_body  = file("${path.root}/kubernet/configmap/config-nginx.yaml")
# }

# resource "kubectl_manifest" "nlb" {
#   depends_on = [kubectl_manifest.daemonset, helm_release.lbc, kubectl_manifest.namespace]
#   yaml_body  = file("${path.root}/kubernet/load/nlb.yaml")

# }

# data "kubernetes_service_v1" "nlb" {
#   metadata {
#     name = "nlb"
#     namespace = "app"
#   }

#   depends_on = [ kubectl_manifest.nlb ]
# }