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

$FileSystemWatcher = New-Object System.IO.FileSystemWatcher
$FileSystemWatcher.Path = (Get-Item -Path ".\src").FullName
Register-ObjectEvent -InputObject $FileSystemWatcher -EventName Changed -SourceIdentifier FileChanged -Action {
    $whoAmI = $env:UserName
    $name = $Event.SourceEventArgs.Name
    $changeType = $Event.SourceEventArgs.ChangeType
    $timeStamp = $Event.TimeGenerated
    $check++
    if($check -lt 2) {
        Write-Host "The file '$name' was $changeType at $timeStamp" -fore Blue

        $serverRunning = Get-WmiObject Win32_Process -Filter "Name='powershell.exe' AND CommandLine LIKE '%server.ps1%'"

        if(!$serverRunning) {
            Start-Process -FilePath "powershell.exe" -ArgumentList "-noexit -executionpolicy bypass", "$pwd\server.ps1" -Verb runas
            Start-Sleep 2
        }

        Invoke-WebRequest "https://127.0.0.1:8443/share/proxy/alfresco/api/people/$whoAmI/sites/sites.json"

        $testResult = Invoke-Pester .\test\*.Tests.ps1 -PassThru -CodeCoverage .\src\*.ps1

        if($testResult.FailedCount -lt 1) {
            Write-Host "Test SUCCESS" -fore Green
        }
        else{
            Write-Host "Test FAIL" -fore Red
        }

        Write-Host "Build Finished" -fore Green
    }
    if($check -gt 1) {
        $check = 0
    }
}

Write-Host `n "Listening for changes!" -fore Green
