provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}

# need to do a helm repo add eks https://aws.github.io/eks-charts before this happens
# resource "helm_release" "appmesh-controller" {
#   name       = "appmesh-controller"
#   namespace  = kubernetes_namespace.appmesh-system.metadata.0.name
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "appmesh-controller"

#   set {
#     name  = "region"
#     value = var.region
#   }

#   set {
#     name  = "serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = "appmesh-controller"
#   }

#     set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/appmesh-controller"
#   }
# }

# // this is needed to provision aws nlb's from k8s
# resource "helm_release" "aws-load-balancer-controller" {
#   name       = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"

#   set {
#     name  = "region"
#     value = var.region
#   }

#   set {
#     name  = "serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   }

#     set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-load-balancer-controller"
#   }
# }

resource "helm_release" "cluster-autoscaler" {
  name       = "ca-release"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version = "9.7.0"

  set {
    name  = "autoDiscovery.clusterName"
    value = local.cluster_name
  }

  set {
    name  = "awsRegion"
    value = var.region
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/cluster-autoscaler-controller"
  }

  set {
    name = "extraArgs.balance-similar-node-groups"
    value = "true"
  }

  set {
    name = "extraArgs.skip-nodes-with-system-pods"
    value = "false"
  }



}

# resource "null_resource" "wait_for_appmesh_crds" {
#   triggers = {
#     timestamp        = timestamp()
#   }


#   depends_on = [
#     helm_release.appmesh-controller,
#     helm_release.cluster-autoscaler,
#   ]
 

#   provisioner "local-exec" {
#     command = ".\\wait-crds.ps1 ${module.eks.kubeconfig_filename}"
#     interpreter = ["PowerShell", "-Command"]

#   }
# }

# now it's safe to apply k8s manifest.yaml's with appmesh resource definitions
# from the aws-app-mesh howto's

# still have question on k8s or terraform provisoining Load Balancers
