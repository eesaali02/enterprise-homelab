New-ADOrganizationalUnit -Name "Finance" -Path "OU=Users,OU=CORP,DC=corp,DC=lab,DC=internal"

"HR","Sales","IT" | ForEach-Object {New-ADOrganizationalUnit -Name "$_" -Path "OU=Users,OU=CORP,DC=corp,DC=lab,DC=internal"}

"Workstations", "Servers","Admin Workstations" | ForEach {New-ADOrganizationalUnit -Name "$_" -Path "OU=Computers,OU=CORP,DC=corp,DC=lab,DC=internal"}