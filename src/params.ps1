Param(
    [String]$domainName = 'localhost:8443',
    [String]$mapDomain = "localhost",
    [String]$prependToLinkTitle = "",
    [String]$icon,
    [String]$protocol = "",
    [Boolean]$disableHomeAndShared = $false
)

if ([System.Environment]::OSVersion.Version.Major -gt 6) {

	New-Item -ItemType directory -Path "$env:userprofile\Alfresco"
	$linkBaseDir = "$env:userprofile\Alfresco"
}
else {

	$linkBaseDir = "$env:userprofile\Links"
}

$appData = "$env:APPDATA\QuickAccessAlfresco"
