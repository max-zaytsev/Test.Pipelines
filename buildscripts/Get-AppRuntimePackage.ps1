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

    [Parameter(Mandatory = $true)]
    [string] $versionName,

    [Parameter(Mandatory=$false)]
    [string] $appVersion = ""
)
$ArtifactFolder = Join-Path $buildArtifactFolder $versionName
$ArtifactFolder = Join-Path $ArtifactFolder $appFolder

Write-Host "ArtifactFolder $ArtifactFolder"

$appFile = (Get-Item (Join-Path $ArtifactFolder "*.app")).FullName
$appJsonFile = (Get-Item (Join-Path $ArtifactFolder "app.json")).FullName
$appJson = Get-Content $appJsonFile | ConvertFrom-Json

if (-not ($appVersion)) {
    $appVersion = $appJson.Version
}

$runtimeAppFolder = Join-Path $ArtifactFolder "RuntimePackages"
New-Item -Path $runtimeAppFolder -ItemType Directory | Out-Null

Write-Host "Getting Runtime Package $appFolder and moving to $runtimeAppFolder"
Get-NavContainerAppRuntimePackage -containerName $containerName -appName $appJson.name -appVersion $appVersion -appFile (Join-Path $runtimeAppFolder ([System.IO.Path]::GetFileName($appFile)))

Write-Host
Write-Host "Task finished"