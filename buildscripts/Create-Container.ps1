Param(
    # [ValidateSet('AzureDevOps','Local','AzureVM')]
    # [Parameter(Mandatory=$false)]
    # [string] $buildenv = "AzureDevOps",

    [Parameter(Mandatory=$false)]
    [string] $containerName = $ENV:CONTAINERNAME,

    [Parameter(Mandatory=$false)]
    [string] $imageName = $ENV:IMAGENAME,

    [Parameter(Mandatory=$false)]
    [string] $buildProjectFolder = $ENV:BUILD_REPOSITORY_LOCALPATH,

    [Parameter(Mandatory=$false)]
    [pscredential] $credential = $null,

    [Parameter(Mandatory = $true)]
    [string] $versionName,

    [Parameter(Mandatory=$false)]
    [string] $ContainerMajor = $env:APPMAJOR,

    [Parameter(Mandatory = $false)]
    [string] $ContainerMinor = $env:APPMINOR,

    [Parameter(Mandatory = $false)]
    [string] $ContainerCountry,

    [ValidateSet('OnPrem','Sandbox')]
    [Parameter(Mandatory = $false)]
    [string] $ContainerTarget = 'OnPrem',

    [Parameter(Mandatory = $false)]
    [string] $ContainerStorageAccount = 'BCArtifacts',

    [Parameter(Mandatory = $false)]
    [string] $ContainerSasToken,

    [Parameter(Mandatory = $false)]
    [String] $FullLicensePath = $env:FULLLICENSEPATH,
    
    [Parameter(Mandatory = $false)]
    [string] $projectFolderPath = $ENV:PROJECTFOLDERPATH,

    [Parameter(Mandatory = $false)]
    [string] $buildArtifactFolder = $ENV:BUILD_ARTIFACTSTAGINGDIRECTORY
)

function GetURL{
    Param(
        [Parameter(Mandatory=$false)]
        [string] $country,

        [Parameter(Mandatory=$false)]
        [string] $select,

        [Parameter(Mandatory=$false)]
        [string] $major,

        [Parameter(Mandatory=$false)]
        [string] $minor,

        [Parameter(Mandatory=$false)]
        [string] $target,

        [Parameter(Mandatory=$false)]
        [string] $storageAccount,

        [Parameter(Mandatory=$false)]
        [string] $sasToken
    )
    $parameters = @{
    }

    if($country) {
        $parameters += @{
            "country" = $country
        }
    }

    if($select){
        $parameters += @{
            "select" = $select
        }
    }

    if($major){
        if ($minor){
            $parameters += @{
                "version" = "$major.$minor"
            }
        } else {
            $parameters += @{
                "version" = $major
            }
        }
    }

    if($target){
        $parameters += @{
            "type" = $target
        }
    }

    if($storageAccount){
        $parameters += @{
            "storageAccount" = $storageAccount
        }
    }
    if($sasToken){
        $parameters += @{
            "sasToken" = $sasToken
        }
    }
    $webclient = New-Object System.Net.WebClient
    $webclient.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials    
    [Net.ServicePointManager]::SecurityProtocol = "tls12"

    return Get-BCArtifactUrl @parameters
}

Write-Host $NetworkPath

if (-not ($credential)) {
    Write-Host "Setting credentials"
    $securePassword = try { $ENV:PASSWORD | ConvertTo-SecureString } catch { ConvertTo-SecureString -String $ENV:PASSWORD -AsPlainText -Force }
    $credential = New-Object PSCredential -ArgumentList $ENV:USERNAME, $SecurePassword
}

Write-Host "Serving container $containerName"

$parameters = @{
    "Accept_Eula" = $true
    "Accept_Outdated" = $true
}

Write-Host $FullLicensePath
if ($FullLicensePath) {
    $parameters += @{
        "licenseFile" = $FullLicensePath
    }
}

# $workspaceFolder = Join-Path $projectFolderPath $versionName
# New-Item -ItemType Directory -Path $workspaceFolder
$workspaceFolder = $projectFolderPath
$additionalParameters = @("--volume ""${workspaceFolder}:C:\Source\build""")
write-host "workspacefolder $workspaceFolder"

# $ArtifactFolder = Join-Path $buildArtifactFolder $versionName
# New-Item -ItemType Directory -Path $ArtifactFolder
$ArtifactFolder = $buildArtifactFolder
$additionalParameters += @("--volume ""${ArtifactFolder}:C:\Source\artifact""")
write-host "ArtifactFolder $ArtifactFolder"

Write-Host "Getting URL for $ContainerMajor $ContainerMinor $ContainerCountry $ContainerTarget"
$URLParameters = @{}

if($ContainerMajor -ne ''){
    $URLParameters += @{"major" = $ContainerMajor}
}
if($ContainerMinor -ne ''){
    $URLParameters += @{"minor" = $ContainerMinor}
}
if($ContainerCountry -ne ''){
    $URLParameters += @{"country" = $ContainerCountry}
}
if($ContainerTarget -ne ''){
    $URLParameters += @{"target"= $ContainerTarget}
}
if ($ContainerStorageAccount -ne '') {
    $URLParameters += @{"storageAccount" = $ContainerStorageAccount }
}
if ($ContainerSasToken -ne '') {
    $URLParameters += @{"sasToken" = $ContainerSasToken }
}

$artifactURL = GetURL @URLParameters

Write-Host "Create $containerName from $imageName URL $artifactURL"
New-BCContainer @Parameters -containername $containerName -imageName $imageName -artifactURL $artifactURL `
                -doNotCheckHealth `
                -alwaysPull:$alwaysPull `
                -additionalParameters $additionalParameters `
                -auth "UserPassword" `
                -Credential $credential `
                -doNotUseRuntimePackages `
                -enableTaskScheduler:$false

Write-Host
Write-Host "Task finished"