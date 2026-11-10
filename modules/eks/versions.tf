terraform {
  required_version = ">=1.3.2"

  required_providers {
    helm = {
        source = "hashicorp/helm"
        version = "~> 3.0"
    }
    kubernes = {
        source = "hashicorp/kubernetes"
        version = "~>2.27"
    }
    kubectl = { 
        source = "gavinbunney/kubectl"
        version = "~> 1.19.0"
    }
  }
}