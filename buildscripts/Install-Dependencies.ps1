Param(
    # [Parameter(Mandatory=$false)]
    # [string] $dependencyFolder,

    [Parameter(Mandatory=$false)]
    [string] $containerName = $ENV:CONTAINERNAME,

    [Parameter(Mandatory = $false)]
    [string] $buildProjectFolder = $ENV:BUILD_REPOSITORY_LOCALPATH,

    [switch] $Sleep
)   

$dependencyFolder = Join-Path $buildProjectFolder 'dependencies'

Write-Host "Serving container $containerName dependencyFolder $dependencyFolder"
Write-Host "Syncing tenant"

if ($Sleep){
    Start-Sleep -s 180
}

if (Test-Path "$dependencyFolder" -PathType Container) {
    Write-Host "Publishing Folder $dependencyFolder"
    Get-ChildItem "$dependencyFolder" -Filter *.app | Foreach-Object {
        Write-Host "Publishing "$_.Filename
        Publish-BCContainerApp -containerName $containerName -appFile $_.FullName -sync -skipverification -install
    }
} else {
    if (Test-Path "$dependencyFolder" -PathType Leaf) {
        Write-Host "Publishing file $dependencyFolder"
        Publish-BCContainerApp -containerName $containerName -appFile $dependencyFolder -sync -skipverification -install
    } else {
        Write-Host "No File or Folder found"
    }
}

Write-Host
Write-Host "Task finished"