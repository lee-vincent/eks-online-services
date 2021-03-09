locals {
  cluster_name = "eks-online-services-${random_string.suffix.result}"

  manifest = templatefile("${path.module}/manifest.tpl", {
    APP_NAMESPACE   = "online-services"
    MESH_NAME       = "online-services"
    ENVOY_IMAGE     = "840364872350.dkr.ecr.${var.region}.amazonaws.com/aws-appmesh-envoy:v1.15.1.0-prod"
  })
}

resource "local_file" "manifest" {
  content              = local.manifest
  filename             = "./manifest.yaml"
  file_permission      = "0644"
  directory_permission = "0755"
}

resource "random_string" "suffix" {
  length  = 4
  special = false
}


module "eks" {
  source                        = "terraform-aws-modules/eks/aws"
  cluster_name                  = local.cluster_name
  wait_for_cluster_interpreter  = ["/bin/bash", "-c"]
  cluster_version               = "1.18"
  subnets                       = module.vpc.private_subnets
  # cluster_service_ipv4_cidr = "192.168.0.0/16"

  enable_irsa     = true
  tags = {
    Environment = "training"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {

      name                          = "wg1"
      instance_type                 = "t2.small"
      additional_userdata           = "customer user data"
      asg_desired_capacity          = 2
      asg_max_size                  = 5
      asg_min_size                  = 1
      additional_security_group_ids = [aws_security_group.security_group_wg1.id]
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    },
  ]

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]

}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}