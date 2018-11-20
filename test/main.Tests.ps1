$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\fixtures.ps1"
. "$here\..\src\$sut"

# Describe "Check-Fail" {
#     It "Should fail." {
#         $pleaseFail | Should be $true
#     }
# }
