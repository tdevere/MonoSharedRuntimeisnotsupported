#!/usr/bin/env pwsh

Write-Information "The Post Build Script Start"

$token = $env:AppCenterTokenForTest


if ($null -ne $token)
{
    Write-Information "AppCenterTokenForTest token found in environment varible."

    #appcenter login --token $AppCenterTokenForTest

    appcenter test generate uitest --platform android --output-path /Users/runner/work/1/a/GeneratedTest

    Write-Information "Seraching for all Project and Solutions in Generated Test project"

    $csproj_files = Get-ChildItem /Users/runner/work/1/a/GeneratedTest -Filter AppCenter.UITest.Android.csproj

    Write-Information "List Prject Files"
    $csproj_files

    foreach ($file in $csproj_files)
    {
        $f = Get-Content -Path $file.FullName -as [Collections.ArrayList]
        Write-Information "Original Project File Content"
        $f
        $f.Insert(15,'    <AndroidUseSharedRuntime>False</AndroidUseSharedRuntime>') # Line 3 starting from 0
        $f | Set-Content file.txt
        Write-Information "Updated Project File Content"
        $f

        
    }

    nuget restore -NonInteractive /Users/runner/work/1/a/GeneratedTest/AppCenter.UITest.Android.sln

    xbuild /Users/runner/work/1/a/GeneratedTest/AppCenter.UITest.Android.sln /p:Configuration=Release

    appcenter test prepare uitest --artifacts-dir /Users/runner/work/1/a/Artifacts --app-path /Users/runner/work/1/a/build/com.companyname.x_53577900993908.apk --build-dir /Users/runner/work/1/a/GeneratedTest/AppCenter.UITest.Android/bin/Release --debug --quiet

    appcenter test run manifest --manifest-path /Users/runner/work/1/a/Artifacts/manifest.json --app-path /Users/runner/work/1/a/build/com.companyname.x_53577900993908.apk --app AppCenterSupportDocs/ManualTestOnDevice --devices any_top_1_device --test-series launch-tests --locale en_US -p msft/test-run-origin=Build/Launch --debug --quiet --token $AppCenterTokenForTest

}
else
{
    Write-Error "AppCenterTokenForTest environment varible must be set for this script to execute."    
}

Write-Information "The Post Build Script End"