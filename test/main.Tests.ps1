$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\fixtures.ps1"
. "$here\..\src\$sut"
$paramFile = "$here\..\src\$sut"
. $paramFile

Describe 'domainNameParameter' {
    It  'Should set test domainName param' {
        (Get-Command $paramFile).Parameters['domainName'].ParameterType | Should be string
    }
}

Describe 'disableHomeAndShared' {
    It  'Should set test disableHomeAndShared param' {
        (Get-Command $paramFile).Parameters['disableHomeAndShared'].ParameterType | Should be bool
    }
}

Describe "Check-System" {
    $version = Check-System
    It "Should check if PowerShell version is 3 or higher."{
        $version[0] | Should be $true
    }

    It "Should check if Windows version is 7 or lower."{
        $version[1] | Should be $false
    }
}

# Describe "Check-Fail" {
#     It "Should fail." {
#         $pleaseFail | Should be $true
#     }
# }

