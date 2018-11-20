Param(
    [String]$domainName = 'localhost:8443',
    [String]$mapDomain = "localhost",
    [String]$prependToLinkTitle = "",
    [String]$icon,
    [String]$protocol = "",
    [String]$disableHomeAndShared = ""
)

if ([System.Environment]::OSVersion.Version.Major -gt 6) {

	New-Item -ItemType directory -Path "$env:userprofile\Alfresco"
	$linkBaseDir = "$env:userprofile\Alfresco"
}
else {

	$linkBaseDir = "$env:userprofile\Links"
}

$appData = "$env:APPDATA\QuickAccessAlfresco"
