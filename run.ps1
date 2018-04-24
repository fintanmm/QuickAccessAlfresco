if (Test-Path ".\0)") {
    Remove-Item -Path .\0
}
$whoAmI = $env:UserName
$webDir = "share\proxy\alfresco\api\people\$whoAmI\sites\"
$webDavDir = "alfresco\webdav\Sites"
$spDir = "alfresco\aos\Sites"
New-Item -ItemType Directory -Force -Path $webDir 
New-Item -ItemType Directory -Force -Path $webDavDir
New-Item -ItemType Directory -Force -Path $spvDir
Copy-Item "stub\sites.json" "$webDavDir\index.json"
Copy-Item "stub\sites.json" "$spDir\index.json"
Copy-Item "stub\sites.json" "$webDir\index.json"
Copy-Item "stub\sites.json" "$webDir\sites.json"
New-Item -Name quickaccess_icon.ico  -Force -ItemType File
Start-Process -FilePath "powershell.exe" -ArgumentList "-NoExit", "$pwd\server.ps1" -Verb runas
$whoAmI = $env:UserName
Invoke-WebRequest "https://localhost:8443/share/proxy/alfresco/api/people/$whoAmI/sites/sites.json"
Invoke-Pester .\QuickAccessAlfresco.Tests.ps1 -CodeCoverage .\QuickAccessAlfresco.ps1