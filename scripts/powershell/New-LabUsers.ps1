# Creates lab users from users.csv

#ask for stating password (never store in a file)
$password = Read-Host -AsSecureString "Starting password for new users"

# The domain part for every DN
$usersOU = "OU=Users,OU=CORP,DC=corp,DC=lab,DC=internal"

# Read the CSV and loop through each row
Import-Csv "$PSScriptRoot\users.csv" | ForEach-Object {

	# Build the logon name: first.last, all lower case
	$sam = ("{0}.{1}" -f $_.FirstName, $_.LastName).ToLower()
	
	# Build the OU path from the Department column
	$ouPath = "OU=$($_.Department),$usersOU"

	# Create the user
	 New-ADUser `
        -Name "$($_.FirstName) $($_.LastName)" `
        	-GivenName $_.FirstName `
        	-Surname $_.LastName `
        	-SamAccountName $sam `
       		-UserPrincipalName "$sam@corp.lab.internal" `
        	-Department $_.Department `
        	-Path $ouPath `
        	-AccountPassword $password `
        	-Enabled $true `
        	-ChangePasswordAtLogon $true `

	Write-Host "Created $sam in $($_.Department)"
}