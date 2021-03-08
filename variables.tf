variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "k8s_cluster_name" {}
variable "environment" {}
variable "workstation_external_cidr" {}
variable "aws_account_id" {}

variable "app_mesh_manifest_version" {
  default = "v1beta2"
}

