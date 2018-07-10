$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\fixtures.ps1"
. "$here\..\src\user.ps1"
. "$here\..\src\$sut"


Describe 'CacheCreate' {
    $appData = "TestDrive:\"
    Mock WhoAm-I {return $whoAmI }    
    It "Should create cache if it doesn't exists." {
        $createCache = CacheCreate
        $createCache.Name | Should be "5.cache"
    }

    It "Should return empty cache if it does exists." {
        Mock Get-ListOfSites {return [PSCustomObject]@{} } 
        rm "$appData\*.cache"
        $createCache = CacheCreate
        $createCache.Name | Should be "0.cache"
        rm "$appData\*.cache"
    }  

    It "Should return the cache if it does exists." {
        New-Item "$appData\5.cache" -type file -Force
        $createCache = CacheCreate
        $createCache.Name | Should be "5.cache"
    }  
}

Describe 'CacheExists' {  
    $appData = "TestDrive:\"
    It "Should test that the cache doesn't exists." {
        $cacheExists = CacheExists
        $cacheExists.Count | Should be 0
    }

    It "Should test that the cache does exists." {
        New-Item "$appData\5.cache" -type file
        $cacheExists = CacheExists
        $cacheExists.Name | Should be "5.cache"
    }
}

Describe 'CacheInit' {
    $cacheFile = @{'Name' = '5.cache';}
    Mock CacheCreate {return $cacheFile}

    It "Should create cache if cache doesn't exist." {
        Mock CacheSizeChanged {return $false}
        $CacheInit = CacheInit
        $CacheInit.Name | Should Match "5.cache"
    }

    It "Should not remove the cache if cache size doesn't change." {
        Mock CacheSizeChanged {return $false}
        $CacheInit = CacheInit
        $CacheInit.Name | Should Match "5.cache"
    }    

    It "Should remove the cache if cache size does change." {
        Mock CacheSizeChanged {return $true}
        $CacheInit = CacheInit
        $CacheInit.Name | Should Match "5.cache"
    }        
}

Describe 'CacheSizeChanged' {
    $appData = "TestDrive:\"
    It "Should detect if there is a change in the size of the cache." {
        Mock CacheTimeChange {return 5}
        New-Item "$appData\4.cache" -type file -Force
        $cacheSizeChanged = CacheSizeChanged
        $cacheSizeChanged | Should Match "True"       
    }
    Clean-Up @('*') ".cache"

    It "Should detect if the cache is the same size." {
        New-Item "$appData\5.cache" -type file
        $cacheSizeChanged = CacheSizeChanged
        $cacheSizeChanged | Should Match $false       
    }
    Clean-Up @('*') ".cache"
}

Describe "CacheTimeChange" {
    Mock WhoAm-I {return $whoAmI }
    
    It "Should detect if the cache has been modified in the last 10 minutes. If so do a web request." {
        $lastWriteTime = @{"LastWriteTime" = [datetime]"1/2/14 00:00:00";}
        $cacheTimeChange = CacheTimeChange $lastWriteTime 5
        $cacheTimeChange | Should Be 5
    }

    It "Should detect if the cache has not been modified in the last 10 minutes. If so do not do a web request." {
        $lastWriteTime = @{"LastWriteTime" = get-date;}
        $cacheTimeChange = CacheTimeChange $lastWriteTime
        $cacheTimeChange | Should Be 0
    }    

    It "Should detect if no date is passed to the function. If so do not do a web request." {
        $cacheTimeChange = CacheTimeChange @{}
        $cacheTimeChange | Should Be 0
    }    
}
