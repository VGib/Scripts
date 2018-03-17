class RunningVm
{
    [string] $VMName
    [string] $Id
}

function GetRunning-VM ()
{
    [regex]$regex = '\"(?<name>[\w \s]+)\"\s+\{(?<id>[\w \-]+)\}'
    return (& vboxmanage list runningvms  ) | foreach {
        $vm = New-Object RunningVm 
        $match = $regex.Matches($_) | Select-Object -First 1
        $vm.VMName = $match.Groups["name"].Value
        $vm.Id = $match.Groups["id"].Value
        return $vm
    }
}

function IsRunning-VM 
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $VMName
    )

    return ( GetRunning-VM | where { $_.VMName -eq $VMName } | Measure-Object ).Count -gt 0
}

function Start-VM
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $VMName
    )

    & vboxmanage startvm $VMName
}

function Stop-VM
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $VMName
    )
    $VMId = (GetRunning-VM | where { $_.VMName -eq $VMName } | Select-Object -First 1).Id
    if(-not [string]::IsNullOrEmpty($VMId))
    {
         & vboxmanage controlvm $VMId acpipowerbutton
    }
}

function StopAndWait-VM
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $VMName,

        [timespan]
        $Timeout = [timespan]::FromMinutes(10)
    )


    Stop-VM -VMName $VMName
    $now = Get-Date
    while (  (IsRunning-VM -VMName $VMName) -and ( ((Get-Date) - $now) -lt $Timeout ) )
    {
        Start-Sleep -Milliseconds 100
    }
}
