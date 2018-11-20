function Create-ScheduledTask($taskName) {
    $config = Parse-Config
    $taskFile = ($PSScriptRoot + "\QuickAccessAlfresco.ps1 $($config["switches"])")
    $taskIsRunning = schtasks.exe /query /tn $taskName

    if($taskIsRunning) {
        schtasks.exe /end /tn $taskName
        schtasks.exe /delete /tn $taskName /f
    }

    $createTask = schtasks.exe /create /tn "$taskName" /sc HOURLY /tr "powershell.exe -executionpolicy bypass -Noninteractive -Command $taskFile" /f

    return $createTask
}
