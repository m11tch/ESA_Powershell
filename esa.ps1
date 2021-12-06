#ESA Powershell/API Interaction example script V0.5 by Mitchell Wesdijk(mitchell@eset.nl)
#Updated 17/11/2020
#Define API credentials and convert to basic auth header
$server = "127.0.0.1" # ESA Server adress
$user = 'xynpfkofjf' #API Username
$pass = 'rgiynptkfd' #API Password
 
if ($args[0] -eq $Null) {
$UsageExample = @"
Usage:
Enabling 2fa for user:
    esa.ps1 set username authentication_type
        esa.ps1 set username Sms realmid
        esa.ps1 set username SofTokens realmid
        esa.ps1 set username SoftTokensPush realmid
        esa.ps1 set username HardTokens realmid
        
Assigning hardtoken to user:
    esa.ps1 hardtoken username serialnumber realmid
Provisioning user (send SMS) 
    esa.ps1 provision username realmid
Deprovision user
    esa.ps1 deprovision username realmid
get Realm ID's
    esa.ps1 getrealms
Force realm force realm sync
    esa.ps1 forcerealmsync realmid
List all users in realm:
    esa.ps1 getuserlist realmid
"@
echo $UsageExample
} else {



$pair = "$($user):$($pass)"

$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))

$basicAuthValue = "Basic $encodedCreds"

$Headers = @{
    Authorization = $basicAuthValue
}

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $True }
$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols

# Create variables to store the values consumed by the Invoke-RestMethod command.


if ($args[0] -eq  "set") {
$Url = "https://"+ $server + ":8001/manage/v2/SetAuthenticationTypes"
$Body = @{
 
"username" = $args[1]
 "realm" = @{
    Type = "auth"
    Id = $args[3]
    } 
  "authenticationTypes" =  @{
        $args[2] = "true"
        }
    
} | ConvertTo-Json
} 
elseif ($args[0] -eq "provision") {
$Url = "https://"+ $server + ":8001/manage/v2/Provision"
$Body = @{
 
"username" = $args[1]
"realm" = @{
    Type = "auth"
    Id = $args[2]
    }
     
} | ConvertTo-Json
}elseif ($args[0] -eq "deprovision") {
$Url = "https://"+ $server + ":8001/manage/v2/SetAuthenticationTypes"
$Body = @{
 
"username" = $args[1]
"realm" = @{
    Type = "auth"
    Id = $args[2]
    }
  
  "authenticationTypes" =  @{
        Sms = "false"
        SoftTokens = "false"
        SoftTokensPush = "false"
        }
    
} | ConvertTo-Json
}
 
elseif ($args[0] -eq "hardtoken") {
$Url = "https://"+ $server + ":8001/manage/v2/AssignHardToken"
$Body = @{

"hardTokenSerialNumber" = $args[2]
"realm" = @{
    Type = "auth"
    Id = $args[3]
    }
"username" = $args[1]
} | ConvertTo-Json
}
elseif ($args[0] -eq "getrealms") {
$Url = "https://"+ $server + ":8001/manage/v2/GetRealms"
$Body = @{

"withUserCount" = "true" 
     
} | ConvertTo-Json
}elseif ($args[0] -eq "getuserlist") {
$Url = "https://"+ $server + ":8001/manage/v2/GetUserList"
$Body = @{


"realm" = @{
    Type = "auth"
    Id = $args[1]
    }
     
} | ConvertTo-Json
}elseif ($args[0] -eq "forcerealmsync") {
$Url = "https://"+ $server + ":8001/manage/v2/GetRealmSync"
$Body = @{

"realm" = @{
    Type = "auth"
    Id = $args[1]
    }
     
} | ConvertTo-Json
$ContentType = "application/json"
$realmdata = Invoke-RestMethod -Method Post -ContentType $ContentType -Uri $url -Body $Body  -Headers $Headers 

$Url = "https://"+ $server + ":8001/manage/v2/SetRealmSync"
$Body = @{
"realm" = @{
    Id = $args[1]

    }

"syncParams" = @{
    ServerPath = $realmdata.ServerPath
    LdapType = $realmdata.LdapType
    ConfigStr = $realmdata.ConfigStr                       
    User = $realmdata.User    
    Password = $realmdata.Password
    SyncInterval = $realmdata.SyncInterval
    RunImmediately = "true"

    }
} | ConvertTo-Json | %{
    [Regex]::Replace($_, 
        "\\u(?<Value>[a-zA-Z0-9]{4})", {
            param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
                [System.Globalization.NumberStyles]::HexNumber))).ToString() } )}

} elseif ($args[0] -eq "reportusersperrealm") {
$reportdata = @()
$Url = "https://"+ $server + ":8001/manage/v2/GetRealms"
$ContentType = "application/json"
$Body = @{

"withUserCount" = "true" 
     
} | ConvertTo-Json

$realms = Invoke-RestMethod -Method Post -ContentType $ContentType -Uri $Url -Body $Body -Headers $Headers 

foreach ($realm in $realms) {
   
    $Url = "https://"+ $server + ":8001/manage/v2/GetUserList"
    $Body = @{


"realm" = @{
    Type = "auth"
    Id = $realm.Realm.id
    }
     
} | ConvertTo-Json

$realmusers = Invoke-RestMethod -Method Post -ContentType $ContentType -Uri $Url -Body $Body -Headers $Headers 
$realmusers2FA = $realmusers | Where-Object -Property TwoFactorAuthenabled -Match 'True'

$realmname = $realm.Realm.name
$realmUserCount2FA = $realmusers2FA.count
if ($realmUserCount2FA -eq $Null) { #fix for empty realms
    $realmUserCount2FA = "0"
}
$reportdata += [pscustomobject]@{Realm=$realmname;Count=$realmUserCount2FA}

}

$reportdata
exit
}


$ContentType = "application/json"

# Now, run the Invoke-RestMethod command with all variables in place
Invoke-RestMethod -Method Post -ContentType $ContentType -Uri $url -Body $Body -Headers $Headers 
}