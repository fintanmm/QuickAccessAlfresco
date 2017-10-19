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
    $webclient = new-object System.Net.WebClient
    $webclient.UseDefaultCredentials=$true
    return $webclient.DownloadString($url)  | ConvertFrom-Json
    # return Invoke-WebRequest -Uri $url -TimeoutSec 10 | ConvertFrom-Json
}

function Create-HomeAndSharedLinks {
   $links = @{}
   $links[0] = Create-Link @{"title" = "Home"; "description" = "My Files"; "shortName" = $env:UserName;} "User Homes"
   $links[1] = Create-Link @{"title" = "Shared"; "description" = "Shared Files"; "shortName" = "Shared";} "Shared"
   return $links
}

function Create-Link($link, [String] $whatPath = "Sites") {

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

function Create-QuickAccessLinks($links, $prepend="") {
    $createdLinks = @()
    for($i = 0; $i -lt $links.Count; $i++) {
        if ($prepend) {
            $links[$i]["prepend"] = $prepend
        }
        $addLink = Create-Link $links[$i]
        if ($addLink -ne "False") {
            $createdLinks += $addLink
        }
    }    
    return $createdLinks
}
