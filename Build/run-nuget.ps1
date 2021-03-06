param (
    [switch]$publish
)

function GetVersion($filepath, $binary)
{
    $initialVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($filepath).FileVersion
    $userProvidedVersion = Read-Host -Prompt "Version for $binary (default: $initialVersion) leave blank to keep default"
    if ($userProvidedVersion) {
        return $userProvidedVersion
    }
    return $initialVersion
}

function AcceptOrDie($releaseVersion, $dependencyVersion) {
    $accept = Read-Host -Prompt "Releasing nuget package with `r`n`r`nRelease version $releaseVersion `r`nSimple.Data dependency $dependencyVersion `r`n`r`nType ok to continue"
    if ($accept -eq "ok") {
        return
    }
    Write-Host "Canceled"
    exit 99
}

$buildDirectory = split-path -parent $MyInvocation.MyCommand.Definition
$binDir = "$buildDirectory\..\Bin"
$mainBinary = "$binDir\Simple.Data.Mysql.dll"
$mainDependency = "$binDir\Simple.Data.Ado.dll"
$releaseVersion = GetVersion $mainBinary "this release"
$dependencyVersion = GetVersion $mainDependency "simple.data dependency"
AcceptOrDie $releaseVersion $dependencyVersion

Write-Host "Invoking nupack making.."
& "$buildDirectory\psake.ps1" "$buildDirectory\nuget.ps1" -parameters @{"releaseVersion"="$releaseVersion"; "dependencyVersion"="$dependencyVersion"}
if ($publish) {
    Write-Host "Publishing.."
    & "$buildDirectory\psake.ps1" "$buildDirectory\nuget.ps1" Publish -parameters @{"releaseVersion"="$releaseVersion"; "dependencyVersion"="$dependencyVersion"}
}

