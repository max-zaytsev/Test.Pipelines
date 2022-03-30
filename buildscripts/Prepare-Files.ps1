Param(
    [Parameter(Mandatory = $true)]
    [string] $appFolder,

    [Parameter(Mandatory = $true)]
    [string] $versionName = '',

    [Parameter(Mandatory = $false)]
    [string] $projectFolderPath = $env:PROJECTFOLDERPATH,

    [Parameter(Mandatory = $false)]
    [string] $AppJSONMajor = '',

    [Parameter(Mandatory = $false)]
    [string] $AppJSONMinor = '',

    [Parameter(Mandatory = $false)]
    [string] $AppJSONPlatform = '',

    [Parameter(Mandatory = $false)]
    [string] $AppJSONApplication = '',

    [Parameter(Mandatory = $false)]
    [string] $AppJSONRuntime = '',

    [Parameter(Mandatory = $false)]
    [string] $AppJSONTarget = '',

    [Parameter(Mandatory = $false)]
    [string] $AppJSONShowMyCode = '',

    [Parameter(Mandatory = $false)]
    [string] $AppJSONrEPAllowDebugging = '',

    [Parameter(Mandatory = $false)]
    [string] $AppJSONrEPAllowDownloadingSourceCode = '',

    [Parameter(Mandatory = $false)]
    [string] $AppJSONrEPIncludeSourceInSymbolFile = '',

    [Parameter(Mandatory = $false)]
    [string] $AppJSONPreProcessorSymbols = ''
)

$appCompileFolder = Join-Path $projectFolderPath $versionName
$appSourceFolder = Join-Path $projectFolderPath $appFolder

Write-Host "Set appCompileFolder = $($appCompileFolder)"
Write-Host "##vso[task.setvariable variable=appCompileFolder]$($appCompileFolder)"
Write-Host "appSourceFolder $appSourceFolder"

Write-Host "Copying $appSourceFolder to $appCompileFolder"
Copy-Item -Path $appSourceFolder -Destination $appCompileFolder -Recurse

$appJsonFile = Join-Path $appCompileFolder "$appFolder\app.json"

$appJson = Get-Content $appJsonFile | ConvertFrom-Json

if ($AppJSONPlatform -ne '') {
    $appJson.platform = $AppJSONPlatform
}

if ($AppJSONApplication -ne '') {
    if ([bool]($appJson.PSobject.Properties.name -match "Application")) {
        $appJson.application = $AppJSONApplication
    }
    else {
        $appJson | Add-Member -name "application" -value $AppJSONApplication -MemberType NoteProperty

        $i = 0;
        $newDep = @()
        foreach ($dep in $appJson.dependencies) {
            Write-Host "Dependency: $dep"
            if ($dep.publisher -eq "Microsoft") {
                Write-Host "Hab dich auf Position $i"
            }
            else {
                Write-Host "die bleibt in der app.json: Name = " $($dep).name
                $newDep += $dep
            }
            $i = $i + 1;
        }
        Write-Host $newDep
        
        # $test = $appJson.dependencies | Where-Object { $_ -ne $appJson.dependencies[$i-1] }
        # foreach ($dep in $test) {
        #     Write-Host "Dependency: $dep"
        # }
        # if (!$test) {
        #     $test = @()
        # }

        $appJson.dependencies = $newDep
        
        # Write-Host "Count: " $appJson.dependencies.count
        # Write-Host "application set. Removing BaseApp dependencies"
        # foreach($dependency in $appJson.dependencies){
        #     if ($dependency.publisher -eq "Microsoft"){
                
        #     }
        # }

        # $dependencies = $appJson.dependencies
        # $dependencies = $dependencies | ? { $_.publisher -ne "Microsoft" }
        
        # Write-Host "Dependencies: " $dependencies.GetType().Name
        # $dependencies
        # Write-Host "Count: " $appJson.dependencies.count

        
        # if($dependencies.count -gt 0 -or $dependencies -ne ""){
        #     $appJson.dependencies = $dependencies
        # } else {
        #     $appJson.PSObject.Properties.Remove('dependencies')
        # }

        # $appJson.dependencies
    }
}

if ($AppJSONRuntime -ne '') {
    $appJson.runtime = $AppJSONRuntime
}

if ($AppJSONTarget -ne '') {
    $appJson.target = $AppJSONTarget
}

if ($AppJSONShowMyCode -ne '') {
    if ([bool]($appJson.PSobject.Properties.name -match "showMyCode")) {
        $appJson.showMyCode = $AppJSONShowMyCode
    }
    else {
        $appJson | Add-Member -name "showMyCode" -value $AppJSONShowMyCode -MemberType NoteProperty
    }
}

if ($AppJSONrEPAllowDebugging -ne '' -or $AppJSONrEPAllowDownloadingSourceCode -ne '' -or $AppJSONrEPIncludeSourceInSymbolFile -ne '') {
    $Policies = New-Object -TypeName PSCustomObject
    $Policies | Add-Member -NotePropertyMembers @{
        allowDebugging            = "$AppJSONrEPAllowDebugging"
        allowDownloadingSource    = "$AppJSONrEPAllowDownloadingSourceCode"
        includeSourceInSymbolFile = "$AppJSONrEPIncludeSourceInSymbolFile"
    }

    Write-Host "Checking appJson for resourceExposurePolicy"
    if ([bool]($appJson.PSobject.Properties.name -match "resourceExposurePolicy")) {
        $appJson.resourceExposurePolicy = $Policies
    }
    else {
        Write-Host "Adding resourceExposurePolicy as NoteProperty"
        $appJson | Add-Member -name "resourceExposurePolicy" -MemberType NoteProperty -value $Policies

    }
}

if ($AppJSONPreProcessorSymbols -ne '') {

    $PreProcessorSymbols = $AppJSONPreProcessorSymbols.Split(',')

    if ([bool]($appJson.PSobject.Properties.name -match "preprocessorSymbols")) {
        $appJson.preprocessorSymbols = $PreProcessorSymbols
    }
    else {
        $appJson | Add-Member -MemberType NoteProperty -Name preprocessorSymbols -value $PreProcessorSymbols
    }
}

if ($env:VERSIONJSON -eq 'True') {
    $appJson.version = "" + $AppJSONMajor + "." + $AppJSONMinor + "." + $env:APPBUILD + "." + $env:APPREVISION
}
else {
    Write-Host "No Version.json found, using default version from app.json"
}

Write-Host "app.json built: " $appJson.GetType().Name
$appJson

$appJson | ConvertTo-Json -Depth 99 | Set-Content $appJsonFile

Write-Host
Write-Host "Task finished"