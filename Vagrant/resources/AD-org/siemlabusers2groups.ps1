$ErrorActionPreference = 'SilentlyContinue' 

Import-Module ActiveDirectory

#Import CSV
$groupmembers = Import-Csv c:\Vagrant\resources\AD-org\siemlabusers2groups.csv


# Loop through the CSV
    foreach ($group in $groupmembers) {

    $memberProps = @{

      Identity          = $group.group
      Members          = $group.user

    }#end memberProps

    Add-ADGroupMember @memberProps

} #end foreach loop
