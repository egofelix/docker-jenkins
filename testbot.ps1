#!/usr/bin/pwsh
Remove-Item -Path testResults/* -Force -Recurse -ErrorAction SilentlyContinue

& dotnet test -c DEBUG -v minimal --collect:"XPlat Code Coverage" --results-directory './testResults'
& dotnet exec "/tools/ReportGenerator/tools/netcoreapp3.0/ReportGenerator.dll" "-reports:testResults\*\*.xml" -targetDir:testResults

Get-ChildItem -Directory -Path testResults -Recurse | Foreach-object {Remove-item -Recurse -path $_.FullName }
