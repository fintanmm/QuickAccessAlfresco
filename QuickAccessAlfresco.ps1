Param(
    [String]$domainName = 'localhost:8443',
    [String]$mapDomain = "localhost",
    [String]$prependToLinkTitle = "",
    [String]$icon,
    [String]$protocol = "",
    [Boolean]$disableHomeAndShared = $false
)

$linkBaseDir = "$env:userprofile\Links"
$appData = "$env:APPDATA\QuickAccessAlfresco"

function Create-ScheduledTask($taskName) {

    $taskFile = ($PSScriptRoot + "\QuickAccessAlfresco.ps1")
    $taskIsRunning = schtasks.exe /query /tn $taskName 2>&1

    if ($taskIsRunning -match "ERROR") {
        $createTask = schtasks.exe /create /tn "$taskName" /sc HOURLY /tr "powershell.exe $taskFile" /f 2>&1

        if ($createTask -match "SUCCESS") {
            return $createTask
        }
    }
    return $false
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
        [array]$response = $webclient.DownloadString($url) | ConvertFrom-Json
    }
    catch {
        [array]$response = @()
    }
    return $response
}

function Create-HomeAndSharedLinks {
   $links = @{}
   $cacheExists = CacheExists
   if ($cacheExists.Count -eq 0) {
        $links[0] = Create-Link @{"title" = "Home"; "description" = "My Files"; "shortName" = $env:UserName;} "User Homes" -protocol $protocol
        $links[1] = Create-Link @{"title" = "Shared"; "description" = "Shared Files"; "shortName" = "Shared";} "Shared" -protocol $protocol
       
   }
   return $links
}

function Create-QuickAccessLinks($links, $prepend="", $icon="", $protocol="") {
    $createdLinks = @()

    if (![string]::IsNullOrEmpty($icon)) {
        copyIcon -icon $icon
        $icon = "$appData\quickaccess_icon.ico"
    }   

    $cacheSizeChanged = CacheSizeChanged
    if ($cacheSizeChanged -eq $false) {
        for($i = 0; $i -lt $links.Count; $i++) {
            if (![string]::IsNullOrEmpty($prepend)) {
                Add-Member -InputObject $links[$i] -MemberType NoteProperty -Name prepend -Value $prepend -Force
            }
            if (![string]::IsNullOrEmpty($icon)) {
                Add-Member -InputObject $links[$i] -MemberType NoteProperty -Name icon -Value $icon -Force
            }            
            $addLink = Create-Link $links[$i] -protocol $protocol
            if ($addLink -ne $false) {
                $createdLinks += $addLink
            }
        }
        $cacheCreate = CacheInit
    }    
    return $createdLinks
}

function CopyIcon($icon="") {
    $testPath = (-Not (Test-Path "$appData\$icon"))
    if ($icon -And $testPath) {
        Copy-Item $icon "$appData\"
        return $true
    }
    return $false
}
 
function Create-Link($link, [String] $whatPath = "Sites", $protocol="") {

    if ($link.Count -eq 0) {
        return $false
    }

    $path = "$linkBaseDir\$($link.title).lnk"

    if($link.prepend){
        $path = "$linkBaseDir\$($link.prepend)$($link.title).lnk"
    }
 
    if (Test-Path $path) {
        return $false
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
    if ($protocol -eq "webdav") {
        $findPath = @{
            "Sites" = "file://$domainName/alfresco/webdav/$($whatPath.ToLower())/" + $link.shortName + "/documentLibrary"; 
            "User Homes" = "file://$domainName/alfresco/webdav/$($whatPath.ToLower())/" + $link.shortName;
            "Shared" = "file://$domainName/alfresco/webdav/$($whatPath.ToLower())";
        }
    }     
    if ($protocol -eq "sharepoint") {
        $findPath = @{
            "Sites" = "file://$domainName/alfresco/aos/$($whatPath.ToLower())/" + $link.shortName + "/documentLibrary"; 
            "User Homes" = "file://$domainName/alfresco/aos/$($whatPath.ToLower())/" + $link.shortName;
            "Shared" = "file://$domainName/alfresco/aos/$($whatPath.ToLower())";
        }
    }         

    $fullPath = $findPath.Get_Item($whatPath)
    
    if ($fullPath.length -eq 0) {
        return $false
    }

    $wshShell = New-Object -ComObject WScript.Shell
    $shortcut = $wshShell.CreateShortcut("$path")

    $shortcut.TargetPath = $fullPath
    $shortcut.Description = $link.description
    if($link.icon){
        $shortcut.IconLocation = "$appData\quickaccess_icon.ico"
    }    
    $shortcut.Save()
    return $shortcut
}

function CacheInit {
<<<<<<< HEAD
    $cacheCreate = $false
    $doesCacheExists = CacheExists

    if ($doesCacheExists.Count -gt 0) { # Check cache is current
        $cacheSizeChanged = CacheSizeChanged

        if ($cacheSizeChanged -or ($doesCacheExists.Count -gt 0)) {
            Remove-Item "$appData\*.cache"
            $cacheCreate = CacheCreate
        }        
    }
=======
    $cacheCreate = CacheCreate
    
    if (CacheSizeChanged -eq $true) {
        Remove-Item "$appData\*.cache"
        $cacheCreate = CacheCreate 
    }        
>>>>>>> 3195d0224d3087df7bfbe71110172c1659cba6e4
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

    if ($lastWriteTime.Count -ne 0) {
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
        $cacheExists = CacheExists
    }
    return $cacheExists
}

function CacheExists {
    $cacheFile = get-childitem -File "$appData\*.cache" | Select-Object Name, LastWriteTime
    if ($cacheFile -eq $null) {
        $cacheFile = @{}
    }
    return $cacheFile
}

function Create-AppData {
    New-Item -ItemType Directory -Force -Path $appData
}

function Generate-Config ($fromParams=@{}) {
    $doesConfigExist = Test-Path "$appData\config.json"
    if(!$doesConfigExist){
        $fromParams | ConvertTo-Json | Set-Content "$appData\config.json"
        return $true
    }
    return $false
}

function Parse-Config {
    $getConfigContent = Read-Config
    $switches = $getConfigContent["switches"]
    $parseSwitches = ""
    $parseSwitches += $switches.Keys | ForEach-Object { 
        $value = $switches.Item($_)
        if(![string]::IsNullOrEmpty($value)){
            "-{0} '{1}'" -f $_, $value
        } 
    }
    return @{"switches" = $parseSwitches;}
}
function Read-Config {
    $getConfigContent = Get-Content -Path "$appData\config.json" | ConvertFrom-Json
    return $getConfigContent    
}

if ($domainName -inotmatch 'localh' -or  $domainName -inotmatch '') {
    Create-AppData
    if (!$disableHomeAndShared) {
        Create-HomeAndSharedLinks                
    }
    $fromUrl = Build-Url
    $listOfSites = Get-ListOfSites $fromUrl
    Create-QuickAccessLinks $listOfSites -prepend $prependToLinkTitle -icon $icon -protocol $protocol
}