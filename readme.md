**esa.ps1**

Usage:
- Enabling 2fa for user:
 ```
 esa.ps1 set username authentication_type
     esa.ps1 set username Sms realmid
     esa.ps1 set username SofTokens realmid
     esa.ps1 set username SoftTokensPush realmid
     esa.ps1 set username HardTokens realmid
 ```

- Assigning hardtoken to user:
```esa.ps1 hardtoken username serialnumber realmid```
- Provisioning user (send SMS) 
`esa.ps1 provision username realmid`
- Deprovision user
`esa.ps1 deprovision username realmid`
- get Realm ID's
`esa.ps1 getrealms`
- List all users in realm:
`esa.ps1 getuserlist realmid`
- Force Sync on realm:
`esa.ps1 forcerealmsync realmid`

**esaExportUserstoCSV.ps1**
1. get the correct realm id by using `esa.ps1 getrealms`
2. insert realmid and other credentials in esaExportUserToCSV.ps1: 

![realmid](/img/realmid_to_esaExportUserToCSVps1.png)

![credentials](/img/api_creds_to_esaExportUserToCSVps1.png)

3. Run esaExportUserToCSV.ps1 

**esaExportUsersAllRealmsToCSV.ps1**
1. insert credentials / server adress in esaExportUsersToCSV.ps1
2. run esaExportUsersAllRealmsToCSV.ps1


**esaCsvImporter.ps1**
1. get the correct realm id by using `esa.ps1 getrealms`
2. insert realmid in 'esaCsvImporter.ps1':
![realmid](/img/realmid_to_esaCsvImporter.png)
3. Create CSV file with the following format: 

```
username
Henk
Klaas
Piet
Karel
```


**esaCsvImporterHardTokens.ps1**
1. get the correct realm id by using `esa.ps1 getrealms`
2. insert realmid in 'esaCsvImporter.ps1':
![realmid](/img/realmid_to_esaCsvImporter.png)
3. Create CSV file with the following format: 
```
username,serialnumber
Henk,1231313
Klaas,2323235
Piet,3233235
Karel,434324
```
