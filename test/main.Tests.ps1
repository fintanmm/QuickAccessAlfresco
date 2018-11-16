$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\fixtures.ps1"
. "$here\..\src\$sut"

Describe "Check-PSVersion" {
    It "Should check if PowerShell version is 3 or higher."{
        $psVersion = Check-PSVersion
        $psVersion | Should be $true
    }
}

# Describe "Check-Fail" {
#     It "Should fail." {
#         $pleaseFail | Should be $true
#     }
# }
