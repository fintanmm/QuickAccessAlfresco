$whoAmI = $env:UserName
$webDir = "alfresco\service\api\people\%whoAmI%\sites\"
New-Item -ItemType Directory -Force -Path $webDir
Copy-Item "stub\sites.json" "$webDir\index.json"
New-Item -Name quickaccess_icon.ico  -Force -ItemType File
Start-Process -FilePath "powershell.exe" -ArgumentList "-NoExit", "$pwd\server.ps1" -Verb runas
Invoke-Pester .\QuickAccessAlfresco.Tests.ps1 -CodeCoverage .\QuickAccessAlfresco.ps1
