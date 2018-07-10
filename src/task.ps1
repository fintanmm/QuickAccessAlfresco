function Create-ScheduledTask($taskName) {
    $config = Parse-Config
    $taskFile = ($PSScriptRoot + "\QuickAccessAlfresco.ps1 $($config["switches"])")
    $taskIsRunning = schtasks.exe /query /tn $taskName 2>&1

    if ($taskIsRunning -match "ERROR") {
        $createTask = schtasks.exe /create /tn "$taskName" /sc HOURLY /tr "powershell.exe -executionpolicy bypass -Noninteractive -Command $taskFile" /f 2>&1

        if ($createTask -match "SUCCESS") {
            return $createTask
        }
    }
    return $false
}