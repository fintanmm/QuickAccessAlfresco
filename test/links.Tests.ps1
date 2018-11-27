$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\fixtures.ps1"
. "$here\..\src\user.ps1"
. "$here\..\src\config.ps1"
$mapDomain = "localhost"
. "$here\..\src\$sut"

Describe 'Create-HomeAndSharedLinks' {
    Mock WhoAm-I {return $whoAmI }

    It "Should create links for the user home and shared." {
        $createHomeAndShared = Create-HomeAndSharedLinks
        $createHomeAndShared[0].Description | Should Match $homeAndShared[0].description
        $createHomeAndShared[0].TargetPath | Should Be "\\localhost\Alfresco\User Homes\$whoAmI"
        $createHomeAndShared[1].Description | Should Match $homeAndShared[1].description
        $createHomeAndShared[1].TargetPath | Should Be "\\localhost\Alfresco\Shared"
    }

    Clean-Up @('Home', "Shared")
}

Describe 'Create-Link' {
    Mock Read-Config {return [PSCustomObject]@{"switches" =[PSCustomObject]@{"icon" = "\\some\where\over\the\rainbow\quickaccess_icon.ico";};} }
    
    It "Should create Quick Access link to Alfresco." {
        $createLink = Create-Link $convertedJSON[0]
        $result = Test-Path "$env:userprofile\Links\Benchmark.lnk"
        $createLink | Should be $result
        $createLink.Description | Should Match $convertedJSON[0].description
    }

    It "Should not create Quick Access link to Alfresco because it exists." {
        $createLink = Create-Link $convertedJSON[0]
        $createLink | Should be $false
    }

    It "Should not create an empty Quick Access link to Alfresco." {
        $createLink = Create-Link @{}
        $createLink | Should be $false
    }

    It "Should pepend text to the Quick Access link to Alfresco." {
        $prependedJSON = $convertedJSON[0..3]
        $prependedJSON[0]["prepend"] = "Alfresco - "
        $createLink = Create-Link $prependedJSON[0]
        $result = Test-Path "$env:userprofile\Links\Alfresco - Benchmark.lnk"
        $createLink | Should Not Be $false
        $createLink.Description | Should Match $prependedJSON[0].description
        $prependedJSON[0].Remove("prepend")
    }

    Clean-Up @("Benchmark", "Alfresco - Benchmark")

    It "Should set an icon for the Quick Access link to Alfresco." {
        $iconJSON = $convertedJSON[0..3]
        $iconJSON[0]["icon"] = "$appData\quickaccess_icon.ico"
        $createLink = Create-Link $iconJSON[0] "Sites" "True"
        $result = Test-Path "$env:userprofile\Links\Benchmark.lnk"
        $createLink | Should Be $result
        $createLink.Description | Should Match $iconJSON[0].description
        $iconFile = $createLink.IconLocation.split(",")[0]
        $iconFile | Should Be "$appData\quickaccess_icon.ico"
        $iconJSON[0].Remove("icon")
    }

    Clean-Up @('Benchmark')

    It "Should create a ftps Quick Access link to an Alfresco site." {
        $createLink = Create-Link $convertedJSON[0] "Sites" "ftps"
        $result = Test-Path "$env:userprofile\Links\Benchmark.lnk"
        $createLink | Should be $result
        $createLink.Description | Should Match $convertedJSON[0].description
        # $createLink.TargetPath | Should Be "ftps://localhost/Alfresco/sites/benchmark/documentLibrary"
    }

    Clean-Up @('Benchmark')

    It "Should create a ftps Quick Access link to user home." {
        $createLink = Create-Link $homeAndShared[0] "User Homes" "ftps"
        $result = Test-Path "$env:userprofile\Links\Home.lnk"
        $createLink | Should be $result
        $createLink.Description | Should Match "My Files"
    }

    It "Should create a ftps Quick Access link to Shared." {
        $createLink = Create-Link $homeAndShared[1] "shared" "ftps"
        $result = Test-Path "$env:userprofile\Links\Shared.lnk"
        $createLink | Should be $result
        $createLink.Description | Should Match "Shared Files"
    }

    It "Should create a WebDav Quick Access link to an Alfresco site." {
        $createLink = Create-Link $convertedJSON[0] "Sites" "webdav"
        $result = Test-Path "$env:userprofile\Links\Benchmark.lnk"
        $createLink | Should be $result
        $createLink.Description | Should Match $convertedJSON[0].description
        $createLink.TargetPath | Should BeLike "\\localhost:8443@SSL\alfresco\webdav\sites\benchmark\documentLibrary"
    }

    Clean-Up @('Home', "Shared", "Benchmark")

    It "Should create a WebDav Quick Access link to user home." {
        $createLink = Create-Link $homeAndShared[0] "User Homes" "webdav"
        $result = Test-Path "$env:userprofile\Links\Home.lnk"
        $createLink | Should be $result
        $createLink.Description | Should Match "My Files"
        $createLink.TargetPath | Should BeLike "\\localhost:8443@SSL\alfresco\webdav\user homes\$whoAmI"
    }

    It "Should create a WebDav Quick Access link to Shared." {
        $createLink = Create-Link $homeAndShared[1] "shared" "webdav"
        $result = Test-Path "$env:userprofile\Links\Shared.lnk"
        $createLink | Should be $result
        $createLink.Description | Should Match "Shared Files"
        $createLink.TargetPath | Should BeLike "\\localhost:8443@SSL\alfresco\webdav\Shared"
    }

    It "Should create a Sharepoint Quick Access link to an Alfresco site." {
        $createLink = Create-Link $convertedJSON[0] "Sites" "sharepoint"
        $result = Test-Path "$env:userprofile\Links\Benchmark.lnk"
        $createLink | Should be $result
        $createLink.Description | Should Match $convertedJSON[0].description
        $createLink.TargetPath | Should BeLike "\\localhost:8443@SSL\alfresco\aos\sites\benchmark\documentLibrary"
    }

    Clean-Up @('Home', "Shared", "Benchmark")

    It "Should create a Sharepoint Quick Access link to user home." {
        $createLink = Create-Link $homeAndShared[0] "User Homes" "sharepoint"
        $result = Test-Path "$env:userprofile\Links\Home.lnk"
        $createLink | Should be $result
        $createLink.Description | Should Match "My Files"
        $createLink.TargetPath | Should BeLike "\\localhost:8443@SSL\alfresco\aos\user homes\$whoAmI"
    }

    It "Should create a Sharepoint Quick Access link to Shared." {
        $createLink = Create-Link $homeAndShared[1] "shared" "sharepoint"
        $result = Test-Path "$env:userprofile\Links\Shared.lnk"
        $createLink | Should be $result
        $createLink.Description | Should Match "Shared Files"
        $createLink.TargetPath | Should BeLike "\\localhost:8443@SSL\alfresco\aos\Shared"
    }

    Clean-Up @('Home', "Shared")

    It "Should not create any link to Alfresco because the path is wrong." {
        $createLink = Create-Link $homeAndShared[1] "wrongPath"
        $createLink | Should be $false
    }
}

Describe 'Create-QuickAccessLinks' {
    Mock Parse-Config {return @{"switches" = @{"icon" = "quickaccess_icon.ico";};} }
    Mock WhoAm-I {return $whoAmI }

    It "Should create all Quick Access links to sites within Alfresco" {
        $createLinks = Create-QuickAccessLinks $convertedJSON
        $createLinks[0].Description | Should Match $convertedJSON[0].description
        $createLinks[1].Description | Should Match $convertedJSON[1].description
    }
    Clean-Up @("Benchmark", "Recruitment")

    It "Should prepend text to all Quick Access links to sites within Alfresco" {
        $createLinks = Create-QuickAccessLinks $convertedJSON "Alfresco - "

        $benchmark = Test-Path "$env:userprofile\Links\Alfresco - Benchmark.lnk"
        $benchmark | Should Not Be $false
        $createLinks[0].Description | Should Match $convertedJSON[0].description
        
        $recruitment = Test-Path "$env:userprofile\Links\Alfresco - Recruitment.lnk"
        $recruitment | Should Not Be $false
        $createLinks[1].Description | Should Match $convertedJSON[1].description
    }
    Clean-Up @('Alfresco - Benchmark', "Alfresco - Recruitment")

    It "Should add an icon to all Quick Access links to sites within Alfresco" {
        $createLinks = Create-QuickAccessLinks -links $convertedJSON -icon ".\quickaccess_icon.ico"

        $benchmark = Test-Path "$env:userprofile\Links\Alfresco - Benchmark.lnk"
        $benchmark | Should Not Be $false
        $icon = $createLinks[2].IconLocation.split(",")[0]
        $icon | Should be "$appData\quickaccess_icon.ico"

        $recruitment = Test-Path "$env:userprofile\Links\Alfresco - Recruitment.lnk"
        $recruitment | Should Not Be $false
        $icon = $createLinks[1].IconLocation.split(",")[0]
        $icon | Should be "$appData\quickaccess_icon.ico"
    }
    Clean-Up @('Alfresco - Benchmark', "Alfresco - Recruitment")

    It "Should use the SharePoint protocol to setup Quick Access links to a site within Alfresco" {
        $createLinks = Create-QuickAccessLinks -links $convertedJSON -protocol "sharepoint"

        $recruitment = Test-Path "$env:userprofile\Links\Alfresco - Recruitment.lnk"
        $recruitment | Should Not Be $false
        $createLinks[1].Description | Should Match $convertedJSON[1].description
        $createLinks[1].TargetPath | Should BeLike "\\localhost:8443@SSL\alfresco\aos\sites\Recruitment\documentLibrary"
    }
    Clean-Up @('Alfresco - Benchmark', "Alfresco - Recruitment")

    It "Should use the SharePoint protocol to setup Quick Access links to one site within Alfresco" {
        $createLinks = Create-QuickAccessLinks -links @($convertedJSON[0]) -protocol "sharepoint"
        $benchmark = Test-Path "$env:userprofile\Links\Alfresco - Benchmark.lnk"
        $benchmark | Should Not Be $false
        $createLinks.Description | Should Match $convertedJSON[0].description
        $createLinks.TargetPath | Should BeLike "\\localhost:8443@SSL\alfresco\aos\sites\Benchmark\documentLibrary"
    }
    Clean-Up @('Alfresco - Benchmark')
}

Describe "Delete-Links" {
    It "Should determine the total amount of links that the user has" {
        $total = Get-ChildItem -Recurse $linkBaseDir -Include *.lnk
        $shortcuts = Delete-Links
        $shortcuts.Total.Count | Should be $total.Count
    }

    Create-TestLinks

    It "Should determine how many links point to Alfresco" {
        $shortcuts = Delete-Links
        $shortcuts.Removed | Should be 2
    }

    Create-TestLinks

    It "Should delete all the links that point to Alfresco" {
        $total = Get-ChildItem -Recurse $linkBaseDir -Include *.lnk
        $shortcuts = Delete-Links
        $shortcuts.Removed | Should be ($total.Count-$shortcuts.User)
    }

    It "Should determine that there are no links which point to Alfresco" {
        $shortcuts = Delete-Links
        $shortcuts.Removed | Should be $null
    }
}
