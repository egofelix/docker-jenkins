#!/usr/bin/pwsh
$REVISION_NUMBER = git rev-list --count HEAD
$FULL_VERSION = "0.1.${REVISION_NUMBER}.${BUILD_NUMBER}"

Remove-Item -Path testResults/* -Force -Recurse -ErrorAction SilentlyContinue

& dotnet test -c DEBUG -v minimal --collect:"XPlat Code Coverage" --results-directory './testResults'
& dotnet exec "D:\Projects\coverage\ReportGenerator\ReportGenerator.dll" "-reports:testResults\*\*.xml" -targetDir:testResults

Get-ChildItem -Directory -Path testResults -Recurse | Foreach-object {Remove-item -Recurse -path $_.FullName }
