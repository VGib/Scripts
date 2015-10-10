# This script upgrade all chocolatey package with OneGet


$packages = Get-Package -ProviderName chocolatey | foreach {

$onlineVersion = (Find-Package -ProviderName chocolatey -Name $_.Name).Version

$obj = New-Object PSObject
Add-Member -InputObject $obj -MemberType NoteProperty -Name "Name" -Value $_.Name
Add-Member -InputObject $obj -MemberType NoteProperty -Name "CurrentVersion" -Value $_.Version
Add-Member -InputObject $obj -MemberType NoteProperty -Name "OnlineVersion" $onlineVersion
return $obj
}

# upgrade package with version superior
$packages | where { $_.onlineVersion -gt $_.CurrentVersion } | foreach {
    echo ("Upgrading " + $_.Name)
    Uninstall-Package -ProviderName chocolatey $_.Name -Confirm
    Install-Package  -ProviderName chocolatey $_.Name -Confirm
}