$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

.".\QuickAccessAlfresco.ps1"

$url = "http://localhost:8080/alfresco/service/api/people/fintan/sites/"
$json

Describe 'Build-Url' {
  It "Should build the URL for connecting to Alfresco." {
    Build-Url | Should -Be $url
  }
}

Describe 'Build-Url' {
  It "Should build the URL for connecting to Alfresco with paramaters prepended." {
    $urlWithParams = Build-Url "hello=world"
    $urlWithParams | Should -Be "http://localhost:8080/alfresco/service/api/people/fintan/sites/?hello=world"
  }
}

Describe 'Get-ListOfSites' {
    It "Should retrieve a list of sites for the currently logged in user." {
        $convertedObject = (Get-Content stub\sites.json)
        Get-ListOfSites $url | Should Match '"title": "Marketing"'
    }
}

Describe 'Create-QuickAccessLinks' {
    It "Should create Quick Access links to Alfresco." {
        Create-QuickAccessLinks | Should be "TRUE"
    }
}