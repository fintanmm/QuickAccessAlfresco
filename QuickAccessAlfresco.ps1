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