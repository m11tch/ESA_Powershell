#####################################
### Change the following vars     ###
#####################################

$server = "127.0.0.1" # ESA Server adress
$user = 'sodnezxtzy' #API Username
$pass = 'utzsgztmyu' #API Password
$realmid = "6f04065d-4bb5-449c-ad31-e49d188a506e" #realmID
$serverPort = "8001" # ESA Server Port (Default: 8001)
$outputCSV = "C:\Users\usr\Desktop\$(get-date -f yyyy-MM-dd)-ESAUserOverview.csv" # path to write CSV file to

#####################################
### Do not make any changes below ###
#####################################

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


$list = Invoke-RestMethod -Method Post -ContentType $ContentType -Uri $url -Body $Body  -Headers $Headers 
foreach ($item in $list)
{
   $item | Select Name, DisplayName, TwoFactorAuthEnabled, WaitingToUseApp  | Export-Csv -Append $outputCSV -NoTypeInformation
}