# add-type @"
#     using System.Net;
#     using System.Security.Cryptography.X509Certificates;
#     public class TrustAllCertsPolicy : ICertificatePolicy {
#         public bool CheckValidationResult(
#             ServicePoint srvPoint, X509Certificate certificate,
#             WebRequest request, int certificateProblem) {
#             return true;
#         }
#     }
# "@
# [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
# write-output "in script"
# $endpointurl = $args[0]
# $healthcheck = '/healhz'
# $url = $endpointurl+$healthcheck





#write-output $args[0]
$url = -join($args[0],"/healthz")
#$url
#"$url"
#write-output $url
#write-output "$url"



for (($i = 0); $i -lt 60; $i++) {

    try
    {
        $response = Invoke-WebRequest -Uri $url -ErrorAction Stop
        $StatusCode = $Response.StatusCode
    }
    catch
    {
        $StatusCode = $_.Exception.Response.StatusCode.value__
    }
    write-output "status code: $StatusCode"

    if(($StatusCode -ge 200) -and ($StatusCode -lt 300)) {
        write-output "success: k8s endpoint healthy"
        exit 0
    }
    Start-Sleep -Seconds 5
}

 write-output "TIMEOUT"
 exit 1

