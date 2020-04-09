$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\fixtures.ps1"
. "$here\..\src\$sut"

Describe 'Append-ToLog' {

    It "Should append to the EventLog" {
        $appendToLog = Append-ToLog -aMessage "QuickAccessAlfresco"
        $loggedEvent = Get-EventLog -LogName "Application" -Source "QuickAccessAlfresco" -Newest 1
        $appendToLog | Should Match $loggedEvent.Message
    }
}