function Check-System {
    
    $systemCheck = @{}

    $systemCheck["PS"] = if($PSVersionTable.PSVersion.Major -gt 2) {$true} else {$false}

    $systemCheck["OS"] = if([System.Environment]::OSVersion.Version.Major -gt 6) {$true} else {$false}

    return $systemCheck
}

function Create-Win10Folder {

    New-Item -ItemType directory -Path "$env:userprofile\$folderName" -Force
    $shell = New-Object -ComObject shell.application
    $shell.Namespace("$env:userprofile\$folderName").Self.InvokeVerb("pintohome")

    return $shell
}

$systemCheck = Check-System

if ($domainName -inotmatch 'localhost' -and $systemCheck["PS"]) {

    if ($systemCheck["OS"]) {

        Create-Win10Folder
        $linkBaseDir = "$env:userprofile\$folderName"
    }
    else {
    
        $linkBaseDir = "$env:userprofile\Links"
    }
    
    $appData = "$env:APPDATA\QuickAccessAlfresco"
    $fromUrl = Build-Url
    $listOfSites = Get-ListOfSites $fromUrl
    Generate-Config @{"switches" = $PsBoundParameters; "sites" = $listOfSites}
    
    #Create-ScheduledTask "QuickAccessAlfresco"

    Create-QuickAccessLinks $listOfSites -prepend $prependToLinkTitle -icon $icon -protocol $protocol

    if ($disableHomeAndShared -gt 0) {
        Create-HomeAndSharedLinks
    }
}
