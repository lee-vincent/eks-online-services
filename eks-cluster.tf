




data "aws_eks_cluster" "cluster" { name = module.eks.cluster_id }
data "aws_eks_cluster_auth" "cluster" { name = module.eks.cluster_id }
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

provider "kubernetes" {
  load_config_file       = "false"
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

resource "kubernetes_namespace" "appmesh-system" {
  metadata {
    name = "appmesh-system"
  }
}

locals {

  cluster_name = "eks-online-services-${random_string.suffix.result}"

  # manifest = templatefile("${path.module}/manifest.tpl", {
  #   APP_NAMESPACE   = "online-services"
  #   MESH_NAME       = "online-services"
  #   ENVOY_IMAGE     = "840364872350.dkr.ecr.${var.region}.amazonaws.com/aws-appmesh-envoy:v1.15.1.0-prod"
  # })
}



# resource "local_file" "manifest" {
#   content              = local.manifest
#   filename             = "./manifest.yaml"
#   file_permission      = "0644"
#   directory_permission = "0755"
# }

resource "random_string" "suffix" {
  length  = 4
  special = false
}




module "eks" {
  source                       = "terraform-aws-modules/eks/aws"
  cluster_name                 = local.cluster_name
  wait_for_cluster_interpreter = ["/bin/bash", "-c"]
  cluster_version              = "1.18"
  subnets                      = module.vpc.private_subnets
  # cluster_service_ipv4_cidr = "192.168.0.0/16"
  # cluster_enabled_log_types = ["api","audit","authenticator","controllerManager","scheduler"]
  map_users = [
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Administrator"
      username = "AWSAdministrator"
      groups   = ["system:masters"]
    },
  ]
  enable_irsa = true
  tags = {
    environment = var.environment
  }

  vpc_id = module.vpc.vpc_id

  worker_groups_launch_template = [
    {
      name                 = "wg1"
      instance_type        = "t2.small"
      asg_desired_capacity = 3
      asg_max_size         = 5
      asg_min_size         = 1
      # add additional sgs at the launch template level
      # additional_security_group_ids = [aws_security_group.security_group_wg1.id]
      key_name = aws_key_pair.bastion_key.key_name
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
    }
  ]
  # sgs applied to all workers (i.e. worker nodes created from launch template and launch config)
  worker_additional_security_group_ids = [aws_security_group.wg1_ingress_bastion.id]

}