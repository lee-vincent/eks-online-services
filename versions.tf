terraform {
  required_providers { # aka plugins
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.43.0"
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
      source  = "hashicorp/helm"
      version = "2.0.2"
    }
    external = {
      version = "2.0.0"
    }
    # provider "http" {}
  }
}