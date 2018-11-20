function Build-Url([String] $urlParams="") {
    $whoAmI = WhoAm-I
    $url = "https://$domainName/share/proxy/alfresco/api/people/$whoAmI/sites/"

    if ($urlParams) {
        $url = "$($url)?$($urlParams)"
    }
    return $url
}

function WhoAm-I {
    return SearchAD
}

function SearchAD {
    $user = $env:UserName
    $searchAD = [adsisearcher]"(&(objectCategory=person)(objectClass=user)(samaccountname=$user))"
    $whoAmI = $searchAD.FindOne()
    return $whoAmI.Properties.samaccountname
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

function Set-SecurityProtocols ($protocols="Tls,Tls11,Tls12") {
    $AllProtocols = [System.Net.SecurityProtocolType]$protocols
    [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
}
