Param(
    [ValidateSet('AzureDevOps','Local','AzureVM')]
    [Parameter(Mandatory=$false)]
    [string] $buildEnv = "AzureDevOps",

    [Parameter(Mandatory=$false)]
    [string] $containerName = $ENV:CONTAINERNAME,

    [Parameter(Mandatory=$false)]
    [string] $buildArtifactFolder = $ENV:BUILD_ARTIFACTSTAGINGDIRECTORY,

    [Parameter(Mandatory=$false)]
    [string] $buildProjectFolder = $ENV:BUILD_REPOSITORY_LOCALPATH,

    [Parameter(Mandatory=$true)]
    [string] $appFolder,

    [Parameter(Mandatory=$true)]
    [string] $versionName,

    [switch] $skipVerification
)


Write-Host "Serving container $containerName"

# $ArtifactFolder = Join-Path $buildArtifactFolder $versionName
$ArtifactFolder = $buildArtifactFolder
$ArtifactFolder = Join-Path $ArtifactFolder $appFolder

Write-Host "ArtifactFolder $ArtifactFolder"

Write-Host "Publishing $ArtifactFolder"
Get-ChildItem -Path $ArtifactFolder -Filter "*.app" | ForEach-Object {
    Write-Host "Publishing file"$_.FullName
    Publish-BCContainerApp -containerName $containerName -appFile $_.FullName -skipVerification:$skipVerification -sync -install
}

Write-Host
Write-Host "Task finished"