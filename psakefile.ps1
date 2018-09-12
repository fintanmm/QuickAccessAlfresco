Add-Type @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            ServicePointManager.ServerCertificateValidationCallback +=
                delegate
                (
                    Object obj,
                    X509Certificate certificate,
                    X509Chain chain,
                    SslPolicyErrors errors
                )
                {
                    return true;
                };
        }
    }
"@

[ServerCertificateValidationCallback]::Ignore();

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
    # Cannot query running processes for a different user, server must be launched as admin to work hence the credentials request
    #$serverRunning = Get-WmiObject Win32_Process -Filter "Name='powershell.exe' AND CommandLine LIKE '%server.ps1%'"
    #if(!$serverRunning) {
        Start-Process -FilePath "powershell.exe" -ArgumentList "-noexit -executionpolicy bypass", "$pwd\server.ps1" -Credential (Get-Credential)
        Start-Sleep 4
    #}
}

Task Test -depends GetSiteJson {
    "Invoke Pester with Coverage"
    $testResult = Invoke-Pester .\test\*.Tests.ps1 -PassThru -CodeCoverage .\src\*.ps1
    if ($testResult.FailedCount -gt 0) {
        throw "$($testResult.FailedCount) tests failed"
    }
}

Task GetSiteJson {
    "GetSiteJson executed"
    Invoke-WebRequest "https://127.0.0.1:8443/share/proxy/alfresco/api/people/$whoAmI/sites/sites.json"
}

Task Lint {
    "Linting"
    Invoke-ScriptAnalyzer -Path .\src\*.ps1 -Setting .\ScriptAnalyzerSettings.psd1
}

Task -Name Format -Description "Format code" {
    Invoke-Formatter .\src\*.ps1 -Settings .\ScriptAnalyzerSettings.psd1
}

Task -Name ConCat -Description "Concatenates files into one file"{
    New-Item -Path .\target -ItemType Directory -Force
    Get-Content src/params.ps1,src/user.ps1,src/links.ps1,src/task.ps1,src/icon.ps1,src/config.ps1,src/main.ps1 | Set-Content target\QuickAccessAlfresco.ps1
}

# Watch method to trigger build process on file change
# Task -Name Watch -Description "Watch directory for changes" {
#     $FileSystemWatcher = New-Object System.IO.FileSystemWatcher
#     $FileSystemWatcher.Path = ".\src"
#     Register-ObjectEvent $FileSystemWatcher Changed -SourceIdentifier FileChanged -Action {
#         $name = $Event.SourceEventArgs.Name
#         $changeType = $Event.SourceEventArgs.ChangeType
#         $timeStamp = $Event.TimeGenerated
#         Write-Host "The file '$name' was $changeType at $timeStamp" -fore Blue
#         Invoke-Psake test
#         Write-Host "Rebuild finished!"
#     }
#     $FileSystemWatcher | Get-Member -Type Properties,Event
# }
