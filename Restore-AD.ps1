#Isaiah Woods Martin Student ID: 001393994
#Creates variable for Finance OU information and Finance OU creation
$financeOU = "OU=Finance,DC=consultingfirm,DC=com"
$createOU = New-ADOrganizationalUnit -Name $finance

#Confirms presence of Finance OU. If found, deletes and recreates. Else, creates Finance OU.
if ([adsi]::Exists("LDAP://$financeOU")) {
    Write-Host "Found $financeOU `nDeleting and recreating."
    Remove-ADOrganizationalUnit -Identity $financeOU -Recursive -confirm:$false
    $createOU
    Write-Host "$financeOU has been successfully created"
}

else {
    Write-Host "$financeOU not found. Creating."
    $createOU
    Write-Host "$financeOU created successfully."
}
#Imports csv of users required to be added to Finance OU 
$ADImport = Import-CSV financePersonnel.csv

foreach ($User in $ADImport) {
$First = $User.First_Name
$Last = $User.Last_Name
$Name = $First + " " + $Last
$SamName = $User.samAccount
$Postal = $User.PostalCode
$Office = $User.OfficePhone
$Mobile = $User.MobilePhone

New-AdUser -GivenName $First -Surname $Last -Name $Name -SamAccountName $SamName -DisplayName $Name -PostalCode $Postal -MobilePhone $Mobile -OfficePhone $Office -Path $financeOU
}

#Required addition to script
Get-ADUser -Filter * -SearchBase “ou=Finance,dc=consultingfirm,dc=com” -Properties DisplayName,PostalCode,OfficePhone,MobilePhone > .\AdResults.txt