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

function Get-ListOfSites {
    Param([String] $url)
    $webclient = new-object System.Net.WebClient
    $webclient.UseDefaultCredentials=$true
    $response = $webclient.DownloadString($url) | ConvertFrom-Json
    return $response
}

function Create-HomeAndSharedLinks {
   $links = @{}
   $cacheExists = CacheExists
   if (-not $cacheExists.Name.Count) {
        $links[0] = Create-Link @{"title" = "Home"; "description" = "My Files"; "shortName" = $env:UserName;} "User Homes"
        $links[1] = Create-Link @{"title" = "Shared"; "description" = "Shared Files"; "shortName" = "Shared";} "Shared"
        $createCache = CacheInit
   }
   return $links
}

function Create-QuickAccessLinks($links, $prepend="") {
    $createdLinks = @()

    $cacheExists = CacheExists
    if (-not $cacheExists.Name.Count) {    
        for($i = 0; $i -lt $links.Count; $i++) {
            if ($prepend) {
                $links[$i]["prepend"] = $prepend
            }
            $addLink = Create-Link $links[$i]
            if ($addLink -ne "False") {
                $createdLinks += $addLink
            }
        }
        $createCache = CacheInit
    }    
    return $createdLinks
}

function Create-Link($link, [String] $whatPath = "Sites", $useFTP="False") {

    if ($link.Count -eq 0) {
        return "False"
    }

    $path = "$linkBaseDir\$($link.title).lnk"

    if($link.contains("prepend")){
        $path = "$linkBaseDir\$($link.prepend)$($link.title).lnk"
    }
 
    if (Test-Path $path) {
        return "False"
    }

    $findPath = @{
        "Sites" = "\\$mapDomain\Alfresco\$whatPath\" + $link.shortName + "\documentLibrary"; 
        "User Homes" = "\\$mapDomain\Alfresco\$whatPath\" + $link.shortName;
        "Shared" = "\\$mapDomain\Alfresco\$whatPath";
    }

    if ($useFTP -eq "True") {
        $findPath = @{
            "Sites" = "ftps://$mapDomain/Alfresco/$whatPath/" + $link.shortName + "/documentLibrary"; 
            "User Homes" = "ftps://$mapDomain/Alfresco/$whatPath" + $link.shortName;
            "Shared" = "ftps://$mapDomain/Alfresco/$whatPath";
        }
    } 

    $wshShell = New-Object -ComObject WScript.Shell
    $shortcut = $wshShell.CreateShortcut("$path")

    $shortcut.TargetPath = $findPath.Get_Item($whatPath)
    $shortcut.Description = $link.description
    if($link.contains("icon")){
        $shortcut.IconLocation = "$linkBaseDir\alfresco_careers_icon.ico"
    }    
    $shortcut.Save()
    return $shortcut
}

function CacheInit {
    $createCache = "False"
    $cacheExists = CacheExists

    if ($cacheExists.Name.Count -ne 0) { # Check cache is current
        $cacheSizeChanged = CacheSizeChanged

        if ($cacheSizeChanged) {
            Remove-Item "$linkBaseDir\*.cache"
            $createCache = CreateCache
        }        
    }
    return $createCache
}

function CacheSizeChanged {
    $url = Build-Url
    $sites = Get-ListOfSites -url "$url/index.json"
    $cacheExists = CacheExists
    [int]$howManySitesCached = $cacheExists.Name.Split(".")[0]
    [int]$countliveSites = $sites.Count

    $cacheSizeChanged = ($countliveSites -ne $howManySitesCached)
    
    return $cacheSizeChanged
}

function CreateCache {
    $cacheExists = CacheExists
    if ($cacheExists.Name.Count -eq 0) {
        $url = Build-Url
        $sites = Get-ListOfSites -url $url
        New-Item "$linkBaseDir\$($sites.Count).cache" -type file
    }
    $cacheExists = CacheExists
    return $cacheExists
}

function CacheExists {
    $cacheFile = get-childitem "$linkBaseDir\*.cache" | Select-Object Name
    return $cacheFile
}