Param(
    [String]$domainName = 'localhost:8443',
    [String]$mapDomain = "localhost",
    [String]$prependToLinkTitle = "",
    [String]$icon
)

$linkBaseDir = "$env:userprofile\Links"
$appData = "$env:APPDATA\QuickAccessLinks"

function Create-ScheduledTask($taskName) {

    if ((((schtasks.exe /query /tn $taskName)[4] -split ' +')[2]) -eq "Running") {

        schtasks.exe /end /tn $taskName
    }

    #schtasks.exe /create /tn "$taskName" /sc ONSTART /tr "powershell.exe -file C:\projects\quickaccessalfresco\run.ps1"

    schtasks.exe /create /tn "$taskName" /sc ONSTART /tr "c:\windows\system32\calc.exe" /f
    Write-Host "Task has been created"

    #schtasks.exe /run /tn "$taskName"
}

function Create-AppData {
    New-Item -ItemType Directory -Force -Path $appData
}

function CopyIcon($icon="") {
    $testPath = (-Not (Test-Path "$appData\$icon"))
    if ($icon -And $testPath) {
        Copy-Item $icon "$appData\"
        return "True"
    }
    return "False"
}

function Build-Url([String] $urlParams="") {
    $whoAmI = $env:UserName
    $url = "https://$domainName/share/proxy/alfresco/api/people/$whoAmI/sites/"
    
    if ($urlParams) {
        $url = "$($url)?$($urlParams)"
    }
    return $url
}

function Set-SecurityProtocols ($protocols="Tls,Tls11,Tls12") {
    $AllProtocols = [System.Net.SecurityProtocolType]$protocols
    [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
}

function Get-ListOfSites {
    Param([String] $url)
    Set-SecurityProtocols
    $webclient = new-object System.Net.WebClient
    $webclient.UseDefaultCredentials=$true
    try {
        $response = $webclient.DownloadString($url) | ConvertFrom-Json
    }
    catch {
        $response = @()
    }
    return $response
}

function Create-HomeAndSharedLinks {
   $links = @{}
   $cacheExists = CacheExists
   if (-not $cacheExists.Name.Count) {
        $links[0] = Create-Link @{"title" = "Home"; "description" = "My Files"; "shortName" = $env:UserName;} "User Homes"
        $links[1] = Create-Link @{"title" = "Shared"; "description" = "Shared Files"; "shortName" = "Shared";} "Shared"
        $cacheCreate = CacheInit
   }
   return $links
}

function Create-QuickAccessLinks($links, $prepend="", $icon="") {
    $createdLinks = @()

    $cacheSizeChanged = CacheSizeChanged
    if ($cacheSizeChanged) {    
        for($i = 0; $i -lt $links.Count; $i++) {
            if ($prepend) {
                $links[$i]["prepend"] = $prepend
            }
            if ($icon) {
                $links[$i]["icon"] = $icon
            }            
            $addLink = Create-Link $links[$i]
            if ($addLink -ne "False") {
                $createdLinks += $addLink
            }
        }
        $cacheCreate = CacheInit
    }    
    return $createdLinks
}

function Create-Link($link, [String] $whatPath = "Sites", $protocol="") {

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

    if ($protocol -eq "ftps") {
        $findPath = @{
            "Sites" = "ftps://$mapDomain/alfresco/$whatPath/" + $link.shortName + "/documentLibrary"; 
            "User Homes" = "ftps://$mapDomain/alfresco/$whatPath/" + $link.shortName;
            "Shared" = "ftps://$mapDomain/alfresco/$whatPath";
        }
    } 
    if ($protocol -eq "https") {
        $findPath = @{
            "Sites" = "https://$mapDomain/alfresco/webdav/$($whatPath.ToLower())/" + $link.shortName + "/documentLibrary"; 
            "User Homes" = "https://$mapDomain/alfresco/webdav/$($whatPath.ToLower())/" + $link.shortName;
            "Shared" = "https://$mapDomain/alfresco/webdav/$($whatPath.ToLower())";
        }
    }     

    $fullPath = $findPath.Get_Item($whatPath)

    if ($fullPath.length -eq 0) {
        return "False"
    }

    $wshShell = New-Object -ComObject WScript.Shell
    $shortcut = $wshShell.CreateShortcut("$path")

    $shortcut.TargetPath = $fullPath
    $shortcut.Description = $link.description
    if($link.contains("icon")){
        $shortcut.IconLocation = "$appData\quickaccess_icon.ico"
    }    
    $shortcut.Save()
    return $shortcut
}

function CacheInit {
    $cacheCreate = "False"
    $doesCacheExists = CacheExists

    if ($doesCacheExists.Count -ne 0) { # Check cache is current
        $cacheSizeChanged = CacheSizeChanged

        if ($cacheSizeChanged) {
            Remove-Item "$appData\*.cache"
            $cacheCreate = CacheCreate
        }        
    }
    return $cacheCreate
}

function CacheSizeChanged {
    $cacheExists = CacheExists
    $howManySitesCached = 0
    if ($cacheExists.Count -ne 0) {
        [int]$howManySitesCached = $cacheExists.Name.Split(".")[0]
    }
    $countliveSites = CacheTimeChange $cacheExists $howManySitesCached
    $cacheSizeChanged = ($countliveSites -ne $howManySitesCached)
    
    return $cacheSizeChanged
}

function CacheTimeChange($lastWriteTime, $countliveSites = 0, $index="") {

    if ($lastWriteTime -ne "") {
        $lastWriteTime = $lastWriteTime.LastWriteTime
    } else {
        $lastWriteTime = get-date
    }

    $timespan = new-timespan -minutes 10
    if (((get-date) - $lastWriteTime) -gt $timespan) {
        $url = Build-Url
        $sites = Get-ListOfSites -url "$url"
        [int]$countliveSites = $sites.Count
    }
    return $countliveSites
}

function CacheCreate {
    $cacheExists = CacheExists
    if ($cacheExists.Count -eq 0) {
        $url = Build-Url
        $sites = Get-ListOfSites -url $url
        New-Item "$appData\$($sites.Count).cache" -type file
    }
    $cacheExists = CacheExists
    return $cacheExists
}

function CacheExists {
    try {
        $cacheFile = Get-ChildItem -File "$appData\*.cache"
    }
    catch {
        
    }

    
    $cacheFile = get-childitem -File "$appData\*.cache" | Select-Object Name, LastWriteTime
    if ($cacheFile -eq $null) {
        $cacheFile = @{}
    }
    return $cacheFile
}

if ($domainName -inotmatch 'localh' -or  $domainName -inotmatch '') {
    Create-AppData
    Create-HomeAndSharedLinks
    $fromUrl = Build-Url
    $listOfSites = Get-ListOfSites $fromUrl
    Create-QuickAccessLinks $listOfSites $prependToLinkTitle $icon
}
