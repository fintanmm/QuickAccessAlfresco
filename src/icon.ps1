function CopyIcon($icon="") {
    $testPath = (-Not (Test-Path "$appData\$icon"))
    if ($icon -And $testPath) {
        Copy-Item $icon "$appData\"
        return $true
    }
    return $false
}