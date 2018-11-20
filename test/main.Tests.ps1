$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\fixtures.ps1"
. "$here\..\src\$sut"

# Describe "Check-System" {
#     It "Should " {
#         $ = Check-System
#         $ | Should be
#     }
# }

# Describe "Create-Win10Folder" {
#     It "Should fail." {
#         $ = Create-Win10Folder
#         $ | Should be $true
#     }
# }
