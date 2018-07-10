$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\fixtures.ps1"
. "$here\..\src\$sut"

Describe "CopyIcon" {

    $appData = "TestDrive:\"    
    It "Should copy the icon to the user appData folder." {
        $doesIconExist = Test-Path "$appData\quickaccess_icon.ico"
        $copyIcon = CopyIcon ".\quickaccess_icon.ico"
        $copyIcon | Should be $true
    }

    It "Should not copy the icon to the user appData folder." {
        $doesIconExist = Test-Path "$appData\quickaccess_icon.ico"
        $copyIcon = CopyIcon ".\quickaccess_icon.ico"
        $copyIcon | Should be $false
    }    
}