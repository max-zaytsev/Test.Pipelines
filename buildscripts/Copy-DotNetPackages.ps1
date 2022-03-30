Param(
    [ValidateSet('AzureDevOps','Local','AzureVM')]
    [Parameter(Mandatory=$false)]
    [string] $buildenv = "AzureDevOps",

    [Parameter(Mandatory=$false)]
    [string] $containerName = $ENV:CONTAINERNAME,
    
    [Parameter(Mandatory=$false)]
    [string] $buildProjectFolder = $ENV:BUILD_REPOSITORY_LOCALPATH,
    
    [Parameter(Mandatory=$true)]
    [string] $appFolder,

    [Parameter(Mandatory=$false)]
    [string] $appVersions = $ENV:APPVERSIONS,

    [Parameter(Mandatory=$false)]
    [string] $projectFolderPath = $ENV:PROJECTFOLDERPATH
)

$RestartNeeded = $false;

$localpath = Join-Path (Join-Path $projectFolderPath $appFolder) ".netpackages"
Write-Host "DotNet DLL-Quell-Pfad: $localpath" 
Write-Host "Serving container $containerName"

$addinPath = Invoke-ScriptInBCContainer -containerName $containerName -scriptblock { $(get-childitem "c:\program files\Microsoft Dynamics*" -filter "add-ins" -recurse).fullname }

foreach ($addinFolder in $addinPath) {
    Write-Host "kopiere DLLs nach $addinFolder ..."
    if (Test-Path $localpath -PathType Container) {
        foreach ($file in Get-ChildItem $localpath) {
            Copy-FileToBCContainer -containerName $containerName -localPath $file.fullname -containerPath (join-path $addinFolder $file.name)
            $RestartNeeded = $true;
        }
    }
}

if ($RestartNeeded) {
    Write-Host "Set RestartNeeded = $RestartNeeded"
    Write-Host "##vso[task.setvariable variable=RestartNeeded]$($RestartNeeded)"
}

Write-Host
Write-Host "Task finished"