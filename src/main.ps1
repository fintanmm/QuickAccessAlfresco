function Check-PSversion {
    return $PSVersionTable.PSVersion.Major -gt 2
}

$psVersion = Check-PSversion
if ($domainName -inotmatch 'localhost' -and $psVersion) {
    Delete-Links
    Create-AppData
    $fromUrl = Build-Url
    $listOfSites = Get-ListOfSites $fromUrl
    Generate-Config @{"switches" = $PsBoundParameters; "sites" = $listOfSites}

    #Create-ScheduledTask "QuickAccessAlfresco"
    if (!$disableHomeAndShared) {
        Create-HomeAndSharedLinks                
    }
    Create-QuickAccessLinks $listOfSites -prepend $prependToLinkTitle -icon $icon -protocol $protocol
}
