$domainName = "localhost:8080"
$mapDomain = "localhost"
$linkBaseDir = "$env:userprofile\Links"
#$userHome = "\\$mapDomain\Alfresco\User Homes\$whoAmI"
#$shared = "\\$mapDomain\Alfresco\Shared"
$prependToLinkTitle = ""

function Build-Url([String] $urlParams="") {
    $whoAmI = $env:UserName
    $url = "http://$domainName/alfresco/service/api/people/$whoAmI/sites/"
    
    if ($urlParams) {
        $url = "$($url)?$($urlParams)"
    }
    return $url
}

function Get-ListOfSites([String] $url) {
    return Invoke-WebRequest -Uri $url | ConvertFrom-Json
}

function Create-HomeAndSharedLinks {
   $links = @{}
   $links[0] = Create-QuickAccessLinks(@{"title" = "Home"; "description" = "My Files"; "shortName" = $env:UserName;})
   $links[1] = Create-QuickAccessLinks(@{"title" = "Shared"; "description" = "Shared Files"; "shortName" = "Shared";})
   return $links
}

function Create-QuickAccessLinks($link) {

    $path = "$linkBaseDir\$($link.title).lnk"

    if (Test-Path $path) {
        return "False"
    } else {
        $wshShell = New-Object -ComObject WScript.Shell
        $shortcut = $wshShell.CreateShortcut("$path")
        $shortcut.TargetPath = "\\$mapDomain\Alfresco\Sites\" + $link.shortName + "\documentLibrary"
        $shortcut.Description = $link.description
        $shortcut.Save()
        return $shortcut 
    }
}
