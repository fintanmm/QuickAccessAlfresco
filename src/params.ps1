Param(
    [String]$domainName = 'localhost:8443',
    [String]$mapDomain = "localhost",
    [String]$prependToLinkTitle = "",
    [String]$icon,
    [String]$protocol = "",
    [Boolean]$disableHomeAndShared = $false
)

$linkBaseDir = "$env:userprofile\Links"
$appData = "$env:APPDATA\QuickAccessAlfresco"
