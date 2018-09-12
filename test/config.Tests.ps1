$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\fixtures.ps1"
. "$here\..\src\$sut"

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
