Param(
    # [ValidateSet('AzureDevOps','Local','AzureVM')]
    # [string] $buildEnv = "AzureDevOps",

    [Parameter(Mandatory=$false)]
    [string] $containerName = $ENV:CONTAINERNAME,

    [switch] $addBuildID
)

if ($addBuildID) {
    $containerName = -join ($containerName, $($env:Build_BuildId))
}

Write-Host "Removing Container $containerName"

Remove-BCContainer -containerName $containerName