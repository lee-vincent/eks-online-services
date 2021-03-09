module "iam_assumable_role_cluster_autoscaler" {
  source                          = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                         = "3.12.0"
  create_role                     = true
  role_name                       = "cluster-autoscaler"
  provider_url                    = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:cluster-autoscaler"]
}

module "iam_assumable_role_appmesh" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                         = "3.12.0"
  create_role                     = true
  role_name                     = "appmesh-controller"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns = [
    "arn:aws:iam::aws:policy/AWSCloudMapFullAccess",
    "arn:aws:iam::aws:policy/AWSAppMeshFullAccess"
  ]
  oidc_fully_qualified_subjects = ["system:serviceaccount:appmesh-system:appmesh-controller"]
}


module "iam_assumable_role_aws_load_balancer_controller" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                         = "3.12.0"
  create_role                     = true
  role_name                     = "aws-load-balancer-controller"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/AWSLoadBalancerControllerIAMPolicy",
  ]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
}



resource "aws_iam_policy" "cluster_autoscaler" {
  name_prefix = "cluster-autoscaler"
  description = "EKS cluster-autoscaler policy for cluster ${module.eks.cluster_id}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid    = "clusterAutoscalerAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "clusterAutoscalerOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${module.eks.cluster_id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}