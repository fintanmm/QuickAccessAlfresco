function Check-System {
    
    $system = @{}

    if($PSVersionTable.PSVersion.Major -gt 2) {
        $system[0] = $true;
    }

    if([System.Environment]::OSVersion.Version.Major -gt 6) {
        $system[1] = $true;
    }

    return $system
}

function Create-Win10Folder {

    $shell = new-object -com shell.application
    $shell.Namespace("$env:userprofile\$folderName").Self.InvokeVerb("pintohome")

}

$system = Check-System

if ($domainName -inotmatch 'localhost' -and $system[0]) {

    if ($system[1]) {

        New-Item -ItemType directory -Path "$env:userprofile\$folderName"
        Create-Win10Folder
        $linkBaseDir = "$env:userprofile\$folderName"
    }
    else {
    
        $linkBaseDir = "$env:userprofile\Links"
    }
    
    $appData = "$env:APPDATA\QuickAccessAlfresco"
    Delete-Links
    $fromUrl = Build-Url
    $listOfSites = Get-ListOfSites $fromUrl
    Generate-Config @{"switches" = $PsBoundParameters; "sites" = $listOfSites}
    Create-ScheduledTask "QuickAccessAlfresco"

    if ($disableHomeAndShared -gt 0) {
        Create-HomeAndSharedLinks
    }

    Create-QuickAccessLinks $listOfSites -prepend $prependToLinkTitle -icon $icon -protocol $protocol
}
