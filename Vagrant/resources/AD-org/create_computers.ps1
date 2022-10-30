# This script is used for creating bulk Computers from a CSV file
# Update the CSV with the Computer name and other information

# Import active directory module for running AD cmdlets
Import-Module activedirectory
  
#Store the data from ADUsers.csv in the $ADUsers variable. CSV template needs the following headers-> name, path
$ADComputers = Import-csv c:\Vagrant\resources\AD-org\siemlabcomputers.csv

#Loop through each row containing user details in the CSV file
foreach ($computer in $ADComputers)
{
	#Read data from each field in each row and assign the data to a variable as below
		
	$name 						= $computer.name
	$OperatingSystem			= $computer.OperatingSystem
	$OperatingSystemHotFix		= $computer.OperatingSystemHotFix
	$OperatingSystemServicePack	= $computer.OperatingSystemServicePack
	$OperatingSystemVersion 	= $computer.OperatingSystemVersion
	$location 					= $computer.Location
	$Path						= $computer.Path

 	   New-ADComputer `
            -Name $name `
			-OperatingSystem $OperatingSystem `
			-OperatingSystemHotFix $OperatingSystemHotFix `
			-OperatingSystemServicePack	$OperatingSystemServicePack `
			-OperatingSystemVersion $OperatingSystemVersion `
			-location $location `
			-Path $Path `

}
