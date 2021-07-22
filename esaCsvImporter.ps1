$Users = Import-Csv -Path "C:\users.csv" # Change path to csv ;) 
$realmid = ae5dd561-d608-4b02-ae20-4f7be8fc9b29 #Insert correct realm id here (Use esa.ps1 getrealms)

foreach ($User in $Users)
{
    $username = $user.'username'
    
#uncomment Sms and comment out SoftToken options if you want to use email instead
.\esa.ps1 set $username SoftTokens $realmid #Enable SoftTokens (OTP)
.\esa.ps1 set $username SoftTokensPush $realmid #Enable SoftTokens Push (Push Authentication)
#.\esa.ps1 set $username Sms $realmid # Enable Sms (Sms/email authentication)
}

