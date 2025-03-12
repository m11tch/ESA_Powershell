# Script to deprovision users that have not authenticated in the last X days. 
#####################################
### Change the following vars     ###
#####################################
# Define the cutoff date (30 days ago)
$cutoffDate = (Get-Date).AddDays(-30)

$server = "127.0.0.1" # ESA Server adress
$user = 'uiwsaypdkn' #API Username
$pass = 'pzutzrnkms' #API Password
$realmid = "6f04065d-4bb5-449c-ad31-e49d188a506e" #realmID
$serverPort = "8001" # ESA Server Port (Default: 8001)

#####################################
### Do not make any changes below ###
#####################################
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $True }
$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols

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
    Id = $realmid
    }
     
} | ConvertTo-Json

$ContentType = "application/json"
# Get users from selected realm
$list = Invoke-RestMethod -Method Post -ContentType $ContentType -Uri $url -Body $Body  -Headers $Headers 
# Filter out active users and users that have no timestamp so that we only have inactive users left
$InactiveUsers = $list | Where-Object LastSuccessfulAuthentication -lt $cutoffDate | Where-Object LastSuccessfulAuthentication -ne $null
# Loop over inactive users to deprovision them.
foreach ($item in $InactiveUsers)
{
    $Url = "https://"+ $server + ":8001/manage/v2/Deprovision"
    $Body = @{
 
    "username" = $item.name
    "realm" = @{
        Type = $item.realm.Type
        Id = $item.realm.id
        }

    
    } | ConvertTo-Json

    Invoke-RestMethod -Method Post -ContentType $ContentType -Uri $url -Body $Body -Headers $Headers 
}