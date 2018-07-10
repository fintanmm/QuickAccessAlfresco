$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\fixtures.ps1"
$domainName = "localhost:8443"
. "$here\..\src\$sut"

Describe 'Build-Url' {
    Mock WhoAm-I {return $whoAmI }
    
    It "Should build the URL for connecting to Alfresco." {
    Build-Url | Should Be $url
  }

  It "Should build the URL for connecting to Alfresco with paramaters prepended." {
    $urlWithParams = Build-Url "hello=world"
    $urlWithParams | Should Be "https://localhost:8443/share/proxy/alfresco/api/people/$whoAmI/sites/?hello=world"
  }
}

Describe "WhoAm-I" {
    It "Should get the case sensitive username." {     
        Mock SearchAD {return $env:UserName}

        $whoAmI = WhoAm-I
        $whoAmI | Should be $env:UserName
    }
}

Describe 'Set-SecurityProtocols' {
    It "Should set the supported security protocol" {
        $securityProtocols = 'Tls, Tls11, Tls12'
        Set-SecurityProtocols $securityProtocols
        [System.Net.ServicePointManager]::SecurityProtocol | Should Be $securityProtocols
        $resetProtocols = [System.Net.SecurityProtocolType]"Tls"
        [System.Net.ServicePointManager]::SecurityProtocol = $resetProtocols
    }
}

Describe 'Get-ListOfSites' {
    It "Should retrieve a list of sites for the currently logged in user." {
        $convertedObject = (Get-Content stub\sites.json)
        $sites = Get-ListOfSites -url $url
        $sites[0].title | Should Match $convertedObject[0].title
    }

    It "Should retrieve an empty list, if there was an unexpected error" {
        $anEmptyList = @()
        $sites = Get-ListOfSites -url "https://localhost:8444/share/proxy/alfresco/api/people/$whoAmI/sites/filenotfound.json"
        $sites.Length | Should Be $anEmptyList.Length
    }    
}