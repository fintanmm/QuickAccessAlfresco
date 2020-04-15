function Generate-Config ($fromParams=@{}) {
    $doesConfigExist = Test-Path "$appData\config.json"
    if(!$doesConfigExist) {
        New-Item -Path $appData -ItemType "directory"
        $fromParams | ConvertTo-Json | Set-Content "$appData\config.json"
        return $true
    }
    return $false
}

function Parse-Config {
    $getConfigContent = Read-Config
    $switches = $getConfigContent.switches
    $parseSwitches = ""
    $switches.psobject.properties.name | ForEach-Object{
        $parseSwitches += "-{0} '{1}' " -f $_, $switches.$_
    }

    $sites = $getConfigContent.sites
    $parseSites = @(0) * $sites.Count
    for ($i = 0; $i -lt $sites.Count; $i++) {
        if ($sites[$i].title) {
            $parseSites[$i] = $sites[$i].title
        }
    }
    return @{"switches" = $parseSwitches; "sites" = $parseSites;}
}

function Read-Config {
    $getConfigContent = Get-Content -Path "$appData\config.json" | Out-String | ConvertFrom-Json
    return $getConfigContent
}
