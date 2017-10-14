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
   $links[0] = Create-Link @{"title" = "Home"; "description" = "My Files"; "shortName" = $env:UserName;} "User Homes"
   $links[1] = Create-Link @{"title" = "Shared"; "description" = "Shared Files"; "shortName" = "Shared";} "Shared"
   return $links
}

function Create-Link($link, [String] $sitePath = "Sites") {

    $path = "$linkBaseDir\$($link.title).lnk"

    if (Test-Path $path) {
        return "False"
    } else {
        $wshShell = New-Object -ComObject WScript.Shell
        $shortcut = $wshShell.CreateShortcut("$path")

        if ($sitePath -eq "Sites") {
            $shortcut.TargetPath = "\\$mapDomain\Alfresco\" + $sitePath + "\" + $link.shortName + "\documentLibrary"
        } else {
            $shortcut.TargetPath = "\\$mapDomain\Alfresco\" + $sitePath + "\" + $link.shortName
        }
        $shortcut.Description = $link.description
        $shortcut.Save()
        return $shortcut 
    }
}
