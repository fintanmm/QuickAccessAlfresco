$FileSystemWatcher = New-Object System.IO.FileSystemWatcher
$FileSystemWatcher.Path = (Get-Item -Path ".\src").FullName
Register-ObjectEvent -InputObject $FileSystemWatcher -EventName Changed -SourceIdentifier FileChanged -Action {
    $name = $Event.SourceEventArgs.Name
    $changeType = $Event.SourceEventArgs.ChangeType
    $timeStamp = $Event.TimeGenerated
    $check++
    if($check -lt 2) {
        Write-Host "The file '$name' was $changeType at $timeStamp" -fore Blue
        
        Psake test -verbose
        # $testResult = Invoke-Pester .\test\*.Tests.ps1 -PassThru -CodeCoverage .\src\*.ps1

        # if($testResult.FailedCount -lt 1) {
        #     Write-Host "Test SUCCESS" -fore Green
        # }
        # else{
        #     Write-Host "Test FAIL" -fore Red
        # }
        Write-Host "Build Finished" -fore Green
    }
    if($check -gt 1) {
        $check = 0
    }
}
