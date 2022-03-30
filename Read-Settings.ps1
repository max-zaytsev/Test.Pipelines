Param(
    # [ValidateSet('AzureDevOps','Local','AzureVM')]
    # [Parameter(Mandatory=$false)]
    # [string] $buildEnv = "AzureDevOps",
    # [Parameter(Mandatory=$false)]
    # [string] $dummy,

    [Parameter(Mandatory=$false)]
    [string] $buildProjectFolder = $ENV:BUILD_REPOSITORY_LOCALPATH,

    # [Parameter(Mandatory=$true)]
    # [string] $projectFolder,

    [Parameter(Mandatory=$true)]
    [string] $containername,

    [Parameter(Mandatory=$false)]
    [string] $containerimage,

    # [Parameter(Mandatory=$true)]
    # [string] $licensePath
)
Write-Host $dummy
Write-Host $projectFolder

$projectFolderPath = Join-Path -Path $buildProjectFolder -ChildPath $projectFolder
$versionFilePath = Join-Path -Path $projectFolderPath -ChildPath "buildscripts\version.json"
Write-Host $versionFilePath
if (Test-Path $versionFilePath){
    Write-Host "Set VersionJSON = $($true)"
    Write-Host "##vso[task.setvariable variable=VersionJSON]$($true)"
    
    $versionJson = (Get-Content $versionFilePath | ConvertFrom-Json)
    Write-Host $versionJson

    $appBuild = $versionJson.appBuild
    $appRevision = $versionJson.appRevision

    $appVersion = "" + $appBuild + "." + $appRevision
    Write-Host "appVersion $appVersion"
    Write-Host "##vso[task.setvariable variable=appVersion]$($appVersion)"
    write-host "##vso[build.updatebuildnumber]$appVersion"

    Write-Host "Set appBuild = $appBuild"
    Write-Host "##vso[task.setvariable variable=appBuild]$($appBuild)"
    Write-Host "Set appRevision = $($appRevision)"
    Write-Host "##vso[task.setvariable variable=appRevision]$($appRevision)"
} else {
    Write-Host "Set VersionJSON = $($false)"
    Write-Host "##vso[task.setvariable variable=VersionJSON]$($false)"
}
# Write-Host "projectFolderPath $projectFolderPath"
# write-host "##vso[task.setvariable variable=projectFolderPath]$projectFolderPath"

$containerName = -join($containerName, $($env:Build_BuildId))
Write-Host "Set containername = $($containername)"
Write-Host "##vso[task.setvariable variable=containername]$($containername)"

Write-Host "Set imageName = $($containerImage)"
Write-Host "##vso[task.setvariable variable=imageName]$($containerImage)"

# if($addDefaultNetworkPath -eq 'true'){
#     $FullLicensePath = Join-Path -Path $LicensePath -ChildPath $LicenseFile
# } else {
    $FullLicensePath = Join-Path $buildProjectFolder 'Cronus.flf'
# }
Write-Host "Set FullLicensePath = $FullLicensePath"
Write-Host "##vso[task.setvariable variable=FullLicensePath]$FullLicensePath"  