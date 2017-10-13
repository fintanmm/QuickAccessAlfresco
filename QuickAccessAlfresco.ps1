$domainName = "localhost:8080"

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

function Create-QuickAccessLinks {
    return "TRUE"
}