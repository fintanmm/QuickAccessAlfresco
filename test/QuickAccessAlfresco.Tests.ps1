$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\..\src\$sut"

$whoAmI = $env:UserName
$linkBaseDir = "$env:userprofile\Links"
$appData = "$env:APPDATA\QuickAccessAlfresco"
$url = "https://localhost:8443/share/proxy/alfresco/api/people/$whoAmI/sites/"
$convertedJSON = @(@{"title" = "Benchmark"; "description" = "This site is for bench marking Alfresco"; "shortName" = "benchmark";}, @{"title" = "Recruitment"; "description" = "Recruitment site"; "shortName" = "Recruitment";})
$convertedCachedJSON = @(@{"title" = "Benchmark"; "description" = "This site is for bench marking Alfresco"; "shortName" = "benchmark";}, @{"title" = "Recruitment"; "description" = "Recruitment site"; "shortName" = "Recruitment";}, @{"title" = "Recruitment"; "description" = "Recruitment site"; "shortName" = "Recruitment";}, @{"title" = "Recruitment"; "description" = "Recruitment site"; "shortName" = "Recruitment";}, @{"title" = "Recruitment"; "description" = "Recruitment site"; "shortName" = "Recruitment";})
$homeAndShared = @(@{"title" = "Home"; "description" = "My Files"; "shortName" = $env:UserName;}, @{"title" = "Shared"; "description" = "Shared Files"; "shortName" = "Shared";})

function setUp {
    New-Item -ItemType Directory -Force -Path $appData
}

function Clean-Up($links, $fileExt = ".lnk") {
    # Clean up after test
    $testLink = "$env:userprofile\Links\"
    foreach($link in $links) {
        if ($fileExt -eq ".lnk") {
            if (Test-Path "$($testLink)$($link)$($fileExt)") {
                Remove-Item "$($testLink)$($link)$($fileExt)"
            } else {
                Write-Host "Can not find $link"
            }
        } else {
            if (Test-Path "$($appData)\$($link)$($fileExt)") {
                Remove-Item "$($appData)\$($link)$($fileExt)"
            } else {
                Write-Host "Can not find $link"
            }
        }
    }
}

function Create-TestLinks {

    $shell = New-Object -comObject WScript.Shell
    $shortcut = $shell.CreateShortcut("$linkBaseDir\testMe.lnk")
    $shortcut.TargetPath = '\\alfresco\alfresco\alfresco'
    $shortcut.Save()
    $shortcut = $shell.CreateShortcut("$linkBaseDir\testMeAgain.lnk")
    $shortcut.TargetPath = '\\Alfresco\Alfresco\Alfresco'
    $shortcut.Save()
}

# Describe 'domainNameParameter' {
#     It  'Should set test domainName param' {
#         (Get-Command "$here\$sut").Parameters['domainName'].ParameterType | Should be string
#     }
# }

# Describe 'disableHomeAndShared' {
#     it  'Should set test disableHomeAndShared param' {
#         (Get-Command "$here\$sut").Parameters['disableHomeAndShared'].ParameterType | Should be bool
#     }
# }

Describe "Create-ScheduledTask" {

    Mock Parse-Config {return @{"switches" = "-domainName 'localhost:8443' -disableHomeAndShared 'False' -mapDomain 'localhost' -prependToLinkTitle 'Alfresco Sites - '";}}
    It "Should create a scheduled task" {
        $createScheduledTask = Create-ScheduledTask("quickAccessAlfresco")
        $createScheduledTask | Should BeLike "SUCCESS*"
    }

    It "Should check that the scheduled task is not already running" {
        $createScheduledTask = Create-ScheduledTask("quickAccessAlfresco")
        $createScheduledTask | Should be $false
    }
    schtasks.exe /delete /tn quickAccessAlfresco /f
}

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

    It "Should pepend text to all Quick Access links to sites within Alfresco" {
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

Describe "CopyIcon" {

    $appData = "TestDrive:\"
    It "Should copy the icon to the user appData folder." {
        $doesIconExist = Test-Path "$appData\quickaccess_icon.ico"
        $copyIcon = CopyIcon ".\quickaccess_icon.ico"
        $copyIcon | Should be $true
    }

    It "Should not copy the icon to the user appData folder." {
        $doesIconExist = Test-Path "$appData\quickaccess_icon.ico"
        $copyIcon = CopyIcon ".\quickaccess_icon.ico"
        $copyIcon | Should be $false
    }
}

Describe "Create-AppData" {
    $appData = "TestDrive:\QAA"
    It "Should create the AppData folder for QuickAccessAlfresco" {
        $createAppData = Create-AppData
        $doesAppDataExist = Test-Path $appData
        $createAppData | Should be $doesAppDataExist
    }
    # Remove-Item "$($appData)"
}

Describe "Generate-Config" {
    $appData = "TestDrive:\"
    $mockParams = @{"sites" = $convertedJSON; "switches" = @{"domainName" = 'localhost:8443'; "mapDomain" = "localhost"; "prependToLinkTitle" = "Alfresco Sites - "; "icon" = ""; "protocol" = ""; "disableHomeAndShared" = $false};}

    It "Should generate config file" {
        $generateConfig = Generate-Config $mockParams
        $doesConfigFileExist = Test-Path "$appData\config.json"
        $generateConfig | Should be $doesConfigFileExist
    }

    It "Should not generate config file" {
        $generateConfig = Generate-Config $mockParams
        $generateConfig | Should be $false
    }
    Clean-Up @('*') ".json"

    It "Should convert params to json" {
        $generateConfig = Generate-Config $mockParams
        $doesConfigFileExist = Test-Path "$appData\config.json"
        $getConfigContent = Get-Content -Path "$appData\config.json" | ConvertFrom-Json
        $generateConfig | Should be $doesConfigFileExist
        $getConfigContent | Should Be $getConfigContent
    }
}

Describe "Read-Config" {
    $appData = "TestDrive:\"

    It "Should read the config file" {
        $mockConfig = [PSCustomObject]@{"sites" = $convertedJSON; "switches" = @{"domainName" = 'localhost:8443'; "mapDomain" = "localhost"; "prependToLinkTitle" = "Alfresco Sites - "; "icon" = ""; "protocol" = ""; "disableHomeAndShared" = $false};}
        $mockConfig | ConvertTo-Json -depth 1 | Set-Content -Path "$appData\config.json"
        $mockConfigContent = Get-Content -Path "$appData\config.json" | ConvertFrom-Json
        $readConfig = Read-Config
        $readConfig.switches | Should Match $mockConfigContent.switches
        $readConfig.sites | Should Be $mockConfigContent.sites
    }
}

Describe "Parse-Config" {
    $appData = "TestDrive:\"

    It "Should parse the config file, even when empty" {
        $mockConfig = @{"sites" = @(); "switches" = @{};}
        Mock Read-Config {return $mockConfig}
        $parseConfig = Parse-Config
        $parseConfig["switches"] | Should Match ""
        $parseConfig["sites"] | Should Match @()
    }

    $mockConfig = [PSCustomObject]@{"sites" = [PSCustomObject]$convertedJSON; "switches" = [PSCustomObject]@{"domainName" = 'localhost:8443'; "mapDomain" = "localhost"; "prependToLinkTitle" = "Alfresco Sites - "; "icon" = ""; "protocol" = ""; "disableHomeAndShared" = $false};}

    It "Should parse the switches from the config file" {
        Mock Read-Config {return $mockConfig}
        $parseConfig = Parse-Config
        $parseConfig["switches"] | Should Match "-domainName 'localhost:8443' -mapDomain 'localhost' -prependToLinkTitle 'Alfresco Sites - ' -icon '' -protocol '' -disableHomeAndShared 'False' "
    }

    It "Should parse the sites from the config file" {
        Mock Read-Config {return $mockConfig}
        $parseConfig = Parse-Config
        $parseConfig["sites"] | Should Be @("Benchmark", "Recruitment")
    }
}

Describe "Check-PSVersion" {
    It "Should check if PowerShell version is 3 or higher."{
        $psVersion = Check-PSVersion
        $psVersion | Should be $true
    }
}
