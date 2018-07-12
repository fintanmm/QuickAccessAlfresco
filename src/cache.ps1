function CacheInit {
    $cacheCreate = CacheCreate

    if (CacheSizeChanged -eq $true) {
        Remove-Item "$appData\*.cache"
        $cacheCreate = CacheCreate
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
        $fromUrl = Build-Url
        $sites = Get-ListOfSites $fromUrl
        $count = $(If ($sites.Count) {$sites.Count} Else {0})
        New-Item "$appData\$($count).cache" -type file -Force | Out-Null
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
