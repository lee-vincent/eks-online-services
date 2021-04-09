variable "region" {
  default = "us-east-1"
}

variable "k8s_cluster_name" {}
variable "environment" {}


variable "app_mesh_manifest_version" {
  default = "v1beta2"
}

variable "workstation_cidr" {
  type        = string
  description = "The ip of the workstation machine"
  sensitive   = true
}

variable "bastion_key" {
  type        = string
  description = "The public key used to ssh to the bastion host"
  sensitive   = true
}

