$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

.".\QuickAccessAlfresco.ps1"

$url = "http://localhost:8080/alfresco/service/api/people/fintan/sites/"
$convertedJSON = @{0 = @{"title" = "Benchmark"; "description" = "This site is for bench marking Alfresco"; "shortName" = "benchmark";};}

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
        Get-ListOfSites $url | Should Match $convertedJSON[0].title
    }
}

Describe 'Create-QuickAccessLinks' {
    It "Should create Quick Access link to Alfresco." {
        $createLink = Create-QuickAccessLinks $convertedJSON[0]
        $result = Test-Path "$env:userprofile\Links\Benchmark.lnk"       
        $createLink | Should be $result
        $createLink.Description | Should Match $convertedJSON[0].description
    }
}

Describe 'Create-QuickAccessLinks' {
    It "Should not create Quick Access link to Alfresco because it exists." {
        $createLink = Create-QuickAccessLinks $convertedJSON[0]
        $createLink | Should be "False"
    }
}
# Clean up after tests
Remove-Item "$env:userprofile\Links\Benchmark.lnk"