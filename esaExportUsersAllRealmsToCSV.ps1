#####################################
### Change the following vars     ###
#####################################

$server = "127.0.0.1" # ESA Server adress
$serverPort = "8001" # ESA Server Port (Default: 8001)
$untrustedCert = $false # set to true if webconsole certificate is not trusted on the system
$user = 'sodnezxtzy' #API Username
$pass = 'utzsgztmyu' #API Password
$outputCSV = "C:\Users\usr\Desktop\$(get-date -f yyyy-MM-dd)-ESAUserOverview.csv" # path to write CSV file to

#####################################
### Do not make any changes below ###
#####################################
if ($untrustedCert) {
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
        add-type @"
            using System.Net;
            using System.Security.Cryptography.X509Certificates;
            public class TrustAllCertsPolicy : ICertificatePolicy {
                public bool CheckValidationResult(
                    ServicePoint srvPoint, X509Certificate certificate,
                    WebRequest request, int certificateProblem) {
                    return true;
                }
            }
"@
}

function getRealms {
    $pair = "$($user):$($pass)"

    $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))

    $basicAuthValue = "Basic $encodedCreds"

    $Headers = @{
        Authorization = $basicAuthValue
    }
    $Url = "https://"+ $server + ":8001/manage/v2/GetRealms"
    $Body = @{

    "withUserCount" = "true" 
     
    } | ConvertTo-Json

    $realms = Invoke-RestMethod -Method Post -ContentType $ContentType -Uri $url -Body $Body  -Headers $Headers 
    return $realms
}

function exportUsersToCSV {
    param (
        $realmId
    )
    $Url = "https://"+ $server + ":"+ $serverport + "/manage/v2/GetUserList"
    $pair = "$($user):$($pass)"

    $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))

    $basicAuthValue = "Basic $encodedCreds"

    $Headers = @{
        Authorization = $basicAuthValue
    }

    $Body = @{

    "realm" = @{
        Type = "auth"
        Id = $realmId
        }
     
    } | ConvertTo-Json

    $ContentType = "application/json"

    $list = Invoke-RestMethod -Method Post -ContentType $ContentType -Uri $url -Body $Body  -Headers $Headers 
    foreach ($item in $list)
    {
       $item | Select Name, DisplayName,Email, TwoFactorAuthEnabled, WaitingToUseApp,AccountEnabled,AppSent,WaitingToSendApp,AccountLocked  | Export-Csv -Append $outputCSV -NoTypeInformation
    }

}

foreach ($realm in getRealms) {
   exportUsersToCSV  -realmId $realm.Realm.Id
}

