module "iam_assumable_role_admin_appmesh" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 3.0"
  create_role                   = true
  role_name                     = "appmesh-controller"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns = [
    "arn:aws:iam::aws:policy/AWSCloudMapFullAccess",
    "arn:aws:iam::aws:policy/AWSAppMeshFullAccess"
  ]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${kubernetes_namespace.appmesh-system.metadata.0.name}:appmesh-controller"]
}




module "iam_assumable_role_lbc" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 3.0"
  create_role                   = true
  role_name                     = "aws-load-balancer-controller"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns = [
    "arn:aws:iam::${aws_account_id}:policy/AWSLoadBalancerControllerIAMPolicy",
  ]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
}



