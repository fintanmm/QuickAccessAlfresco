$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\fixtures.ps1"
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
