$Users = Import-Csv -Path "C:\users.csv" # Change path to csv ;) 
$realmid = ae5dd561-d608-4b02-ae20-4f7be8fc9b29 #Insert correct realm id here (Use esa.ps1 getrealms)

foreach ($User in $Users)
{
    $username = $user.'username'
    $serial = $user.'serialnumber'
    
.\esa.ps1 hardtoken $username $serial $realmid # Assign Hardtoken 
.\esa.ps1 set $username HardTokens $realmid #Enable Hardtoken Auth option

}

