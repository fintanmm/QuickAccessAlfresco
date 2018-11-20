if ($domainName -inotmatch 'localhost' -and $PSVersionTable.PSVersion.Major -gt 2) {
    Delete-Links
    $fromUrl = Build-Url
    $listOfSites = Get-ListOfSites $fromUrl
    Generate-Config @{"switches" = $PsBoundParameters; "sites" = $listOfSites}

    Create-ScheduledTask "QuickAccessAlfresco"

    if ($disableHomeAndShared -gt 0) {
        Create-HomeAndSharedLinks
    }

    if ([System.Environment]::OSVersion.Version.Major -gt 6) {

        $shell = new-object -com shell.application
            $shell.Namespace("$env:userprofile\Alfresco").Self.InvokeVerb("pintohome")
        }

    Create-QuickAccessLinks $listOfSites -prepend $prependToLinkTitle -icon $icon -protocol $protocol
}
