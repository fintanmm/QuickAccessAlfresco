$domainName = "localhost:8080"
$mapDomain = "localhost"
$linkBaseDir = "$env:userprofile\Links"
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

function Create-Link($link, [String] $whatPath = "Sites") {

    $path = "$linkBaseDir\$($link.title).lnk"

    if (Test-Path $path) {
        return "False"
    }
    $wshShell = New-Object -ComObject WScript.Shell
    $shortcut = $wshShell.CreateShortcut("$path")

    $findPath = @{
        "Sites" = "\\$mapDomain\Alfresco\$whatPath\" + $link.shortName + "\documentLibrary"; 
        "User Homes" = "\\$mapDomain\Alfresco\$whatPath\" + $link.shortName;
        "Shared" = "\\$mapDomain\Alfresco\$whatPath";
    }
    $shortcut.TargetPath = $findPath.Get_Item($whatPath)
    $shortcut.Description = $link.description
    $shortcut.Save()
    return $shortcut
}

function Create-QuickAccessLinks($links) {
    $createdLinks = @()
    foreach ($link in $links) {
        $addLink = Create-Link $link
        if (-not $addLink) {
            $createdLinks += $addLink
        }
    }    
    return $createdLinks
}
