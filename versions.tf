# EKS documentation
# Kubernetes version      1.18
# Amazon VPC CNI plug-in  1.7.5
# DNS (CoreDNS)           1.7.0
# KubeProxy               1.18.9



terraform {
  required_providers { # aka plugins
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.22.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.13.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 1.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 2.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 2.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.1"
    }
    helm = {
      source = "hashicorp/helm"
      version = "1.3.2"
    }
    external = {
      version = "2.0.0"
    }
  }
}

terraform {
  required_version = ">= 0.12"
}
