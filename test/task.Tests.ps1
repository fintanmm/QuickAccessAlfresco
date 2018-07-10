$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\fixtures.ps1"
. "$here\..\src\config.ps1"
. "$here\..\src\$sut"

Describe "Create-ScheduledTask" {
    
    Mock Parse-Config {return @{"switches" = "-domainName 'localhost:8443' -disableHomeAndShared 'False' -mapDomain 'localhost' -prependToLinkTitle 'Alfresco Sites - '";}}
    It "Should create a scheduled task" {
        $createScheduledTask = Create-ScheduledTask("quickAccessAlfresco")
        $createScheduledTask | Should BeLike "SUCCESS*"
    }

    It "Should check that the scheduled task is not already running" {
        $createScheduledTask = Create-ScheduledTask("quickAccessAlfresco")
        $createScheduledTask | Should be $false
    }
    schtasks.exe /delete /tn quickAccessAlfresco /f 2>&1
}