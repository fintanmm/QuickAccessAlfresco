Param(
    [String]$domainName = 'localhost:8443',
    [String]$mapDomain = "localhost",
    [String]$prependToLinkTitle = "",
    [String]$icon,
    [String]$protocol = "",
    [Boolean]$disableHomeAndShared = $false
)

function Check-System {
    $system = @{}
    $system[0] = $PSVersionTable.PSVersion.Major -gt 2
    $system[1] = [System.Environment]::OSVersion.Version.Major -gt 6
    return $system
}

$version = Check-System

if ($version[1]) {

	New-Item -ItemType directory -Path "$env:userprofile\Alfresco"
	$linkBaseDir = "$env:userprofile\Alfresco"
}
else {

	$linkBaseDir = "$env:userprofile\Links"
}

$appData = "$env:APPDATA\QuickAccessAlfresco"

if ($domainName -inotmatch 'localhost' -and $version[0]) {
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
