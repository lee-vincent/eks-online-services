param
(
    [string]$KubeFile
)

$deploymentstatus = kubectl --kubeconfig "$KubeFile" wait --for condition=available --timeout=300s deployment/appmesh-controller -n appmesh-system -o=json | jq -r '.status.conditions[].type'
$deploymentstatus = $deploymentstatus | Select-String -Pattern "Available"
$deploymentstatus = "$deploymentstatus".trim()
Write-Output "appmesh-controller deployment status: $deploymentstatus"
if ("$deploymentstatus" -notmatch  "Available") {
    Write-Output "error: is the appmesh-controller deployed?"
    Exit 1
}

Write-Output "success: appmesh-controller deployed status: $deploymentstatus"

$requiredver="v1.2.0"
$currentver = kubectl --kubeconfig "$KubeFile" get deployment -n appmesh-system appmesh-controller -o json | jq -r ".spec.template.spec.containers[].image"
$currentver = $currentver.split(":")[1]; # v1.2.0
Write-Output "message: appmesh version $currentver"

if ("$requiredver" -notmatch  "$currentver") {
    Write-Output "current appmesh version $currentver does not match required version $requiredver"
    Exit 1
}

Write-Output "success: appmesh version matches $currentver"


# these are the appmesh crds that helm installs
$vr = "crd/virtualrouters.appmesh.k8s.aws"
$gr = "crd/gatewayroutes.appmesh.k8s.aws"
$am = "crd/meshes.appmesh.k8s.aws"                      
$sgp = "crd/securitygrouppolicies.vpcresources.k8s.aws"
$vg = "crd/virtualgateways.appmesh.k8s.aws"
$vn = "crd/virtualnodes.appmesh.k8s.aws"
$vs = "crd/virtualservices.appmesh.k8s.aws"

$vr, $gr, $am, $sgp, $vg, $vn, $vs | ForEach-Object {
    $crdresult = ""
    Write-Output "Testing CRD: $_"
    $crdresult = kc --kubeconfig "$KubeFile" -n appmesh-system  wait --for condition=established --timeout=60s $_ -o=json | jq -r '.status.conditions[].type'
    $crdresult = $crdresult | Select-String -Pattern "Established"
    $crdresult="$crdresult".Trim()
    if ("$crdresult" -notmatch  "Established") {
        Write-Output "CRD NOT ESTABLISHED: $_"
        Exit 1
    }
    Write-Output "PASSED: $_"
}

Write-Output "success: appmesh CRDs installed"

# now you can apply k8s manifest.yaml's