$whoAmI = $env:UserName
$linkBaseDir = "$env:userprofile\Links"
$appData = "$env:APPDATA\QuickAccessAlfresco"
$url = "https://localhost:8443/share/proxy/alfresco/api/people/$whoAmI/sites/"
$convertedJSON = @(@{"title" = "Benchmark"; "description" = "This site is for bench marking Alfresco"; "shortName" = "benchmark";}, @{"title" = "Recruitment"; "description" = "Recruitment site"; "shortName" = "Recruitment";})
$convertedCachedJSON = @(@{"title" = "Benchmark"; "description" = "This site is for bench marking Alfresco"; "shortName" = "benchmark";}, @{"title" = "Recruitment"; "description" = "Recruitment site"; "shortName" = "Recruitment";}, @{"title" = "Recruitment"; "description" = "Recruitment site"; "shortName" = "Recruitment";}, @{"title" = "Recruitment"; "description" = "Recruitment site"; "shortName" = "Recruitment";}, @{"title" = "Recruitment"; "description" = "Recruitment site"; "shortName" = "Recruitment";})
$homeAndShared = @(@{"title" = "Home"; "description" = "My Files"; "shortName" = $env:UserName;}, @{"title" = "Shared"; "description" = "Shared Files"; "shortName" = "Shared";})

$domainName = "localhost:8443"
function setUp {
    New-Item -ItemType Directory -Force -Path $appData
}

function Clean-Up($links, $fileExt = ".lnk") {
    # Clean up after test
    $testLink = "$env:userprofile\Links\"
    foreach($link in $links) {
        if ($fileExt -eq ".lnk") {
            if (Test-Path "$($testLink)$($link)$($fileExt)") {
                Remove-Item "$($testLink)$($link)$($fileExt)"
            } else {
                Write-Host "Can not find $link"
            }
        } else {
            if (Test-Path "$($appData)\$($link)$($fileExt)") {
                Remove-Item "$($appData)\$($link)$($fileExt)"
            } else {
                Write-Host "Can not find $link"
            }
        }
    }
}

function Create-TestLinks {

    $shell = New-Object -comObject WScript.Shell
    $shortcut = $shell.CreateShortcut("$linkBaseDir\testMe.lnk")
    $shortcut.TargetPath = '\\alfresco\alfresco\alfresco'
    $shortcut.Save()
    $shortcut = $shell.CreateShortcut("$linkBaseDir\testMeAgain.lnk")
    $shortcut.TargetPath = '\\Alfresco\Alfresco\Alfresco'
    $shortcut.Save()
}
