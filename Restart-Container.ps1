Param(
    [Parameter(Mandatory=$false)]
    [string] $Target = 'OnPrem',

    [string] $RestartNeeded = $ENV:RESTARTNEEDED,

    [Parameter(Mandatory=$false)]
    [string] $containerName = $ENV:CONTAINERNAME
)

if ($RestartNeeded -eq 'True'){
    Restart-BCContainer -containerName $containerName
}

if ( $Target -eq 'sandbox') {
    $State = Invoke-ScriptInBcContainer $containername -scriptblock {
            Get-NAVTenant BC | Select -ExpandProperty "state"
        } | Select -ExpandProperty "Value"

    while ($State -eq 'Mounting'){
        Write-Host "Waiting for tenant to be operational"
        Start-Sleep -s 5

        $State = Invoke-ScriptInBcContainer $containername -scriptblock {
            Get-NAVTenant BC | Select -ExpandProperty "state"
        } | Select -ExpandProperty "Value"
    }
    Invoke-ScriptInBcContainer $containername -scriptblock {
            Get-NAVTenant BC
    }
}