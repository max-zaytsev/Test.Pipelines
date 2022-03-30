Param(
    [ValidateSet('AzureDevOps','Local','AzureVM')]
    [Parameter(Mandatory=$false)]
    [string] $buildenv = "AzureDevOps",

    [Parameter(Mandatory=$false)]
    [string] $containerName = $ENV:CONTAINERNAME,
    
    [Parameter(Mandatory=$false)]
    [pscredential] $credential = $null,
    
    [Parameter(Mandatory=$false)]
    [string] $appCompileFolder = $ENV:APPCOMPILEFOLDER,

    [Parameter(Mandatory=$false)]
    [string] $buildSymbolsFolder = (Join-Path $appCompileFolder ".alPackages"),

    [Parameter(Mandatory=$false)]
    [string] $buildArtifactFolder = $ENV:BUILD_ARTIFACTSTAGINGDIRECTORY,

    [Parameter(Mandatory = $true)]
    [string] $versionName,

    [Parameter(Mandatory = $true)]
    [string] $appFolder
)

if (-not ($credential)) {
    $securePassword = try { $ENV:PASSWORD | ConvertTo-SecureString } catch { ConvertTo-SecureString -String $ENV:PASSWORD -AsPlainText -Force }
    $credential = New-Object PSCredential -ArgumentList $ENV:USERNAME, $SecurePassword
}

# $ArtifactFolder = Join-Path $buildArtifactFolder $versionName
$ArtifactFolder = $buildArtifactFolder
$ArtifactFolder = Join-Path $ArtifactFolder $appFolder

Write-Host "ArtifactFolder $ArtifactFolder"
Write-Host "appProjectFolder appCompileFolder $appCompileFolder"
Write-Host "buildSymbolsFolder $buildSymbolsFolder"

Write-Host "Compiling $versionName"

Write-Host "Compile-AppInBCContainer -containerName $containerName -credential $credential -appProjectFolder (Join-Path $appCompileFolder $appFolder) -appSymbolsFolder $buildSymbolsFolder -appOutputFolder $ArtifactFolder -UpdateSymbols:$updateSymbols #-AzureDevOps:($buildenv -eq "AzureDevOps")"
$appFile = Compile-AppInBCContainer -containerName $containerName -credential $credential -appProjectFolder (Join-Path $appCompileFolder $appFolder) -appSymbolsFolder $buildSymbolsFolder -appOutputFolder $ArtifactFolder -UpdateSymbols:$updateSymbols #-AzureDevOps:($buildenv -eq "AzureDevOps")
Write-Host $appFile
if ($appFile -and (Test-Path $appFile)) {
    Copy-Item -Path $appFile -Destination $buildSymbolsFolder -Force
    Copy-Item -Path (Join-Path $appCompileFolder "$appFolder\app.json") -Destination (Join-Path $ArtifactFolder "\app.json") 
}

Write-Host
Write-Host "Task finished"