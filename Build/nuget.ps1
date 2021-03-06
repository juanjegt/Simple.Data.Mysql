Properties {
    $BuildDirectory = Split-Path $psake.build_script_file
    $NugetDirectory = "$BuildDirectory\..\Nuget\Simple.Data.Mysql"
    $NugetBinaryDirectory = "$NugetDirectory\lib\net40"
    $BinaryDirectory = "$BuildDirectory\..\Bin"
    $BinaryName = "Simple.Data.Mysql.dll"
    $NuspecName = "simple.data.mysql.nuspec"
    $NugetExecutable = "$BuildDirectory\..\Tools\Nuget\NuGet.exe"
    $packageName = "Simple.Data.Mysql"
}
FormatTaskName (("-"*25) + "[{0}]" + ("-"*25))

Task Default -Depends Create_nuget_package

Task CopyBinary -Depends Clean{ 
    mkdir $NugetBinaryDirectory
    Copy-Item "$BinaryDirectory\$BinaryName" "$NugetBinaryDirectory\$BinaryName"
}


Task Create_nuspec -Depends Clean, CopyBinary  {
    $nuspec = [xml] (Get-Content "$BuildDirectory\$NuspecName")
    $nuspec.package.metadata.version = $releaseVersion
    $nuspec.package.metadata.dependencies.dependency.version = $dependencyVersion
    $nuspec.Save("$NugetDirectory\$NuspecName")
}

Task Clean {
    if (Test-Path "$NugetDirectory\$NuspecName") {
        Remove-Item "$NugetDirectory\$NuspecName"
    }
    if (Test-Path $NugetBinaryDirectory) {
        rd $NugetBinaryDirectory -rec -force | Out-Null
    }
    del "$NugetDirectory\*.nupkg"
}

Task Create_nuget_package -Depends Create_nuspec, CopyBinary {
    & $NugetExecutable pack "$NugetDirectory\$NuspecName" -BasePath $NugetDirectory -OutputDirectory $NugetDirectory -verbose
}

Task Publish {
    & $NugetExecutable push "$NugetDirectory\$packageName.$releaseVersion.nupkg"
}
    
