variable "region" {
  default     = "us-east-1"
}

variable "k8s_cluster_name" {}
variable "environment" {}
variable "workstation_external_cidr" {}

variable "app_mesh_manifest_version" {
  default = "v1beta2"
}

