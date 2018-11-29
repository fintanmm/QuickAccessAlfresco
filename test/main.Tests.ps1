$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\fixtures.ps1"
. "$here\..\src\$sut"

Describe "Check-System" {
    It "Should check the PowerShell Version" {
        $systemCheck = Check-System
        $systemCheck["PS"] | Should -Not -Be $null
    }

    It "Should check the Operating System Version" {
        $systemCheck = Check-System
        $systemCheck["OS"] | Should -Not -Be $null
    }
}

Describe "Create-Win10Folder" {

    It "Should create a valid shell application." {
        $shell = Create-Win10Folder
        $shell.Application | Should -BeLike "*System.__ComObject*"
    }

    It "Should create a new folder." {
        $systemCheck = Check-System
        if($systemCheck["OS"]) {
            Create-Win10Folder
            Test-Path "$env:userprofile\Sites" | Should be $true
        }
        else {
            Test-Path "$env:userprofile\Sites" | Should be $false
        }
    }

    It "Should pin folder to quick access." {
        $systemCheck = Check-System
        if($systemCheck["OS"]) {
            $shell = New-Object -ComObject shell.application
            $shell.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}").Items() | where {$_.Path -eq "$env:userprofile\Sites"} | Should -Not -Be $null
        }
    }
}
