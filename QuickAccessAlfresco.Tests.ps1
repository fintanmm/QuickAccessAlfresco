$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

.".\QuickAccessAlfresco.ps1"

$whoAmI = $env:UserName
$linkBaseDir = "$env:userprofile\Links"
$url = "http://localhost:8080/alfresco/service/api/people/$whoAmI/sites/"
$convertedJSON = @{0 = @{"title" = "Benchmark"; "description" = "This site is for bench marking Alfresco"; "shortName" = "benchmark";};1 = @{"title" = "Recruitment"; "description" = "Recruitment site"; "shortName" = "Recruitment";};}
$homeAndShared = @{0 = @{"title" = "Home"; "description" = "My Files"; "shortName" = $env:UserName;};1 = @{"title" = "Shared"; "description" = "Shared Files"; "shortName" = "Shared";};}

function Clean-Up($links, $fileExt = ".lnk") {
    # Clean up after test
    $testLink = "$env:userprofile\Links\"
    foreach($link in $links) {
        if (Test-Path "$($testLink)$($link)$($fileExt)") {
            Remove-Item "$($testLink)$($link)$($fileExt)"
        } else {
            Write-Host "Can not find $link"
        }
    }
}

Describe 'Build-Url' {
  It "Should build the URL for connecting to Alfresco." {
    Build-Url | Should -Be $url
  }

  It "Should build the URL for connecting to Alfresco with paramaters prepended." {
    $urlWithParams = Build-Url "hello=world"
    $urlWithParams | Should -Be "http://localhost:8080/alfresco/service/api/people/$whoAmI/sites/?hello=world"
  }
}

Describe 'Get-ListOfSites' {
    It "Should retrieve a list of sites for the currently logged in user." {
        $convertedObject = (Get-Content stub\sites.json)
        Get-ListOfSites -url "$url/index.json" | Should Match $convertedJSON[0].title
    }
}

Describe 'Create-HomeAndSharedLinks' {
    It "Should create links for the user home and shared" {
        $createHomeAndShared = Create-HomeAndSharedLinks 
        $createHomeAndShared[0].Description | Should Match $homeAndShared[0].description
        $createHomeAndShared[0].TargetPath | Should Be "\\localhost\Alfresco\User Homes\$whoAmI"
        $createHomeAndShared[1].Description | Should Match $homeAndShared[1].description
        $createHomeAndShared[1].TargetPath | Should Be "\\localhost\Alfresco\Shared"
    }
}

Describe 'Create-Link' {
    It "Should create Quick Access link to Alfresco." {
        $createLink = Create-Link $convertedJSON[0]
        $result = Test-Path "$env:userprofile\Links\Benchmark.lnk"       
        $createLink | Should be $result
        $createLink.Description | Should Match $convertedJSON[0].description
    }

    It "Should not create Quick Access link to Alfresco because it exists." {
        $createLink = Create-Link $convertedJSON[0]
        $createLink | Should be "False"
    }

    It "Should not create an empty Quick Access link to Alfresco." {
        $createLink = Create-Link @{}
        $createLink | Should be "False"
    }

    Clean-Up @("Home", "Shared", "Benchmark")

    It "Should pepend text to the Quick Access link to Alfresco." {
        $prependedJSON = $convertedJSON[0..3]
        $prependedJSON[0]["prepend"] = "Alfresco - "
        $createLink = Create-Link $prependedJSON[0]
        $result = Test-Path "$env:userprofile\Links\Alfresco - Benchmark.lnk"
        $createLink | Should Not Be "False"
        $createLink.Description | Should Match $prependedJSON[0].description
    }    

    Clean-Up @('Alfresco - Benchmark')

    # FIXME: There is a side effect here, the title is prepended to when it shouldn't be
    It "Should create a ftp Quick Access link to Alfresco." {
        $createLink = Create-Link $convertedJSON[0] "Sites" "True"
        $result = Test-Path "$env:userprofile\Links\Alfresco - Benchmark.lnk"       
        $createLink | Should be $result
        $createLink.Description | Should Match $convertedJSON[0].description
    }

    Clean-Up @('Alfresco - Benchmark')
}

    
Describe 'Create-QuickAccessLinks' {
    It "Should create all Quick Access links to sites within Alfresco" {
        $createLinks = Create-QuickAccessLinks $convertedJSON
        $createLinks[0].Description | Should Match $convertedJSON[0].description
        $createLinks[1].Description | Should Match $convertedJSON[1].description
    }
    Clean-Up @('Alfresco - Benchmark', "Benchmark", "Recruitment")
    
    It "Should pepend text to all Quick Access links to sites within Alfresco" {
        $createLinks = Create-QuickAccessLinks $convertedJSON "Alfresco - "
        
        $benchmark = Test-Path "$env:userprofile\Links\Alfresco - Benchmark.lnk"
        $benchmark | Should Not Be "False"
        $createLinks[0].Description | Should Match $convertedJSON[0].description
        
        $recruitment = Test-Path "$env:userprofile\Links\Alfresco - Recruitment.lnk"
        $recruitment | Should Not Be "False"
        $createLinks[1].Description | Should Match $convertedJSON[1].description
    }
    Clean-Up @('Alfresco - Benchmark', "Alfresco - Recruitment")
}

Describe 'CreateCache' {
    It "Should create cache if it doesn't exists." {
        $createCache = CreateCache
        $createCache.Count | Should be 2
    }
    Clean-Up @('5') ".cache"
}

Describe 'CacheExists' {
    It "Should test that the cache doesn't exists." {
        $cacheExists = CacheExists
        $cacheExists.Count | Should be 0
    }

    It "Should test that the cache does exists." {
        New-Item "$linkBaseDir\5.cache" -type file
        $cacheExists = CacheExists
        $cacheExists.Name | Should be "5.cache"
    }
}

Describe 'CacheRemove' {
    It "Should remove the cache if cache size changes." {
        $cacheRemove = CacheRemove
        $cacheRemove | Should be "True"
    }
    Clean-Up @('5') ".cache"
}