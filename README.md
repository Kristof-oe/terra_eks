# terra_eks — Amazon EKS built with Terraform

This project uses Terraform to create an Amazon EKS cluster on AWS and deploy two Flask microservices to it, with an nginx reverse proxy in front of them.

## What it builds

### 1. VPC module (`modules/vpc`)
- A VPC with public and private subnets
- A NAT gateway so the private subnets can reach the internet

### 2. EKS module (`modules/eks`)
- **EKS cluster**, with IAM roles and security groups
- **Managed node group** running in the private subnets
- **Add-ons:** VPC CNI, CoreDNS, kube-proxy and the EKS Pod Identity Agent
- **Load balancing:** the AWS Load Balancer Controller, installed with Helm, using Pod Identity for its permissions. Traffic goes through an **nginx reverse proxy** to the services.
- **Kubernetes manifests applied automatically:** Terraform uses `kubectl_manifest` to apply the YAML files in `kubernet/` to the cluster:
  - Deployments are generated with `templatefile`, which fills in the image URL of each ECR repository
  - Services (ClusterIP) for each app
  - A ConfigMap holding the nginx reverse proxy config (`/api/sa` → service A, `/api/sb` → service B)
  - A DaemonSet that runs the nginx proxy on every node

### 3. ECR module (`modules/ecr`)
- One ECR repository per service (`sa`, `sb`)

## Applications (`app/`)
Two Flask apps I wrote myself (`sa` and `sb`). Each has a Dockerfile. The image is built with Docker and pushed to its ECR repository, and then deployed to EKS.

## Project structure
```
.
├── main.tf, variables.tf, outputs.tf, terraform.tfvars   # root config
├── modules/
│   ├── vpc/    # VPC and subnets
│   ├── eks/    # cluster, node group, IAM, add-ons, security groups, LB controller, manifests
│   └── ecr/    # container registries
├── kubernet/   # Kubernetes YAML: deployments, services, configmap, daemonset
└── app/        # Flask apps sa and sb, with Dockerfiles
```

## Usage
```bash
terraform init -backend-config=state.config
terraform apply

# log in to ECR (the command is printed in the config_repo output)
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <repo_url>

# build and push an app image
docker build -t <repo_url>:<tag> app/sa
docker push <repo_url>:<tag>
```
