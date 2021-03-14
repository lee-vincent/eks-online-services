locals {
  iam_settings = {
    "cluster-autoscaler-controller"  = { oidc_fully_qualified_subject = "system:serviceaccount:kube-system:cluster-autoscaler", policy_arn = aws_iam_policy.cluster_autoscaler.arn },
    "appmesh-controller"             = { oidc_fully_qualified_subject = "system:serviceaccount:appmesh-system:appmesh-controller", policy_arn = aws_iam_policy.appmesh_controller.arn },
    "aws-lb-controller"              = { oidc_fully_qualified_subject = "system:serviceaccount:kube-system:aws-load-balancer-controller", policy_arn = aws_iam_policy.aws_lb_controller.arn },
  }
}

# curl -o appmesh-controller-iam-policy.json https://raw.githubusercontent.com/aws/aws-app-mesh-controller-for-k8s/master/config/iam/controller-iam-policy.json
# curl -o  https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.0.0/docs/install/iam_policy.json
module "iam_assumable_role_admin" {
  for_each                        = local.iam_settings
  source                          = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                         = "3.12.0"
  create_role                     = true
  role_name                       = each.key
  provider_url                    = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [each.value.policy_arn]
  oidc_fully_qualified_subjects = [each.value.oidc_fully_qualified_subject]
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name = "cluster-autoscaler"
  description = "EKS cluster-autoscaler policy for cluster ${module.eks.cluster_id}"
  policy = templatefile("${path.module}//cluster-autoscaler-controller-iam-policy.json", {
    CLUSTER_ID   = module.eks.cluster_id
  })
}

resource "aws_iam_policy" "appmesh_controller" {
  name = "appmesh-controller"
  description = "EKS appmesh-controller policy for cluster ${module.eks.cluster_id}"
  policy = templatefile("${path.module}//appmesh-controller-iam-policy.json", {})
}


resource "aws_iam_policy" "aws_lb_controller" {
  name = "aws-lb-controller"
  description = "EKS aws-lb-controller policy for cluster ${module.eks.cluster_id}"
  policy = templatefile("${path.module}//aws-lb-controller-iam-policy.json", {})
}