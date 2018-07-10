$whoAmI = $env:UserName
$webDir = "share\proxy\alfresco\api\people\$whoAmI\sites\"
$webDavDir = "alfresco\webdav\Sites"
$spDir = "alfresco\aos\Sites"

TaskSetup {
    "Executing task setup"
    New-Item -ItemType Directory -Force -Path $webDir 
    New-Item -ItemType Directory -Force -Path $webDavDir
    New-Item -ItemType Directory -Force -Path $spDir
    Copy-Item "stub\sites.json" "$webDavDir\index.json"
    Copy-Item "stub\sites.json" "$spDir\index.json"
    Copy-Item "stub\sites.json" "$webDir\index.json"
    Copy-Item "stub\sites.json" "$webDir\sites.json"
    New-Item -Name quickaccess_icon.ico -Force -ItemType File    
}
  
TaskTearDown {
    "Executing task tear down"
    # Remove-Item -Path "$webDavDir"
    # Remove-Item -Path "$spDir"
    # Remove-Item -Path "$webDir"
    # Get-Process | Where-Object { $_.Name -eq "server.ps1" } | Select-Object -First 1 | Stop-Process
}

Task default -depends Test

Task -Name RunWebServer -Description "Run web server"{
    Start-Process -InformationVariable -FilePath "powershell.exe" -ArgumentList "-NoExit", "$pwd\server.ps1" -Verb runas    
}

Task Test -depends GetSiteJson{
    "Invoke Pester with Coverage"
    Invoke-Pester .\QuickAccessAlfresco.Tests.ps1 -CodeCoverage .\QuickAccessAlfresco.ps1
}

Task GetSiteJson {
    "GetSiteJson executed"
    Invoke-WebRequest "https://localhost:8443/share/proxy/alfresco/api/people/$whoAmI/sites/sites.json"    
}

Task Lint {
    "Linting"
    Invoke-ScriptAnalyzer -Path .\QuickAccessAlfresco.ps1 -Setting .\ScriptAnalyzerSettings.psd1
}

Task -Name Format -Description "Format code" {
    Invoke-Formatter .\QuickAccessAlfresco.ps1 -Settings .\ScriptAnalyzerSettings.psd1
}

Task -Name ConCat -Depends InvokePester -Description "Concatenates files into one file"{
    # cat params.ps1,user.ps1,links.ps1,task.ps1,icon.ps1,config.ps1,main.ps1 | sc .\QuickAccessAlfresco.ps1
}

Task -Name Watch -Description "Watch directory for changes" {
    $FileSystemWatcher = New-Object System.IO.FileSystemWatcher
    $FileSystemWatcher | Get-Member -Type Properties,Event 
}