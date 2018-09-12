function Create-HomeAndSharedLinks {
    $links = @{}
    $links[0] = Create-Link @{"title" = "Home"; "description" = "My Files"; "shortName" = WhoAm-I;} "User Homes" -protocol $protocol
    $links[1] = Create-Link @{"title" = "Shared"; "description" = "Shared Files"; "shortName" = "Shared";} "Shared" -protocol $protocol
    return $links
}

function Create-QuickAccessLinks([array]$links, $prepend="", $icon="", $protocol="") {
    $createdLinks = @()

    if (![string]::IsNullOrEmpty($icon)) {
        copyIcon -icon $icon
        $icon = "$appData\$icon"
    }

    for($i = 0; $i -lt $links.Count; $i++) {
        if (![string]::IsNullOrEmpty($prepend)) {
            Add-Member -InputObject $links[$i] -MemberType NoteProperty -Name prepend -Value $prepend -Force
        }
        if (![string]::IsNullOrEmpty($icon)) {
            Add-Member -InputObject $links[$i] -MemberType NoteProperty -Name icon -Value $icon -Force
        }
        $addLink = Create-Link $links[$i] -protocol $protocol
            if ($addLink -ne $false) {
                $createdLinks += $addLink
            }
    }
    return $createdLinks
}

function CopyIcon($icon="") {
    $testPath = (-Not (Test-Path "$appData\$icon"))
    if ($icon -And $testPath) {
        Copy-Item $icon "$appData\"
        return $true
    }
    return $false
}

function Create-Link($link, [String] $whatPath = "Sites", $protocol="") {

    if ($link.Count -eq 0) {
        return $false
    }

    $path = "$linkBaseDir\$($link.title).lnk"

    if($link.prepend){
        $path = "$linkBaseDir\$($link.prepend)$($link.title).lnk"
    }

    if (Test-Path $path) {
        return $false
    }

    $findPath = @{
        "Sites" = "\\$mapDomain\Alfresco\$whatPath\" + $link.shortName + "\documentLibrary"; 
        "User Homes" = "\\$mapDomain\Alfresco\$whatPath\" + $link.shortName;
        "Shared" = "\\$mapDomain\Alfresco\$whatPath";
    }

    if ($protocol -eq "ftps") {
        $findPath = @{
            "Sites" = "ftps://$mapDomain/alfresco/$whatPath/" + $link.shortName + "/documentLibrary"; 
            "User Homes" = "ftps://$mapDomain/alfresco/$whatPath/" + $link.shortName;
            "Shared" = "ftps://$mapDomain/alfresco/$whatPath";
        }
    }
    if ($protocol -eq "webdav") {
        $pathToLower = $whatPath.ToLower()
        $findPath = @{
            "Sites" = "\\$domainName@SSL\alfresco\webdav\$pathToLower\" + $link.shortName + "\documentLibrary"; 
            "User Homes" = "\\$domainName@SSL\alfresco\webdav\$pathToLower\" + $link.shortName;
            "Shared" = "\\$domainName@SSL\alfresco\webdav\$pathToLower";
        }
    }
    if ($protocol -eq "sharepoint") {
        $pathToLower = $whatPath.ToLower()
        $findPath = @{
            "Sites" = "\\$domainName@SSL\alfresco\aos\$pathToLower\" + $link.shortName + "\documentLibrary"; 
            "User Homes" = "\\$domainName@SSL\alfresco\aos\$pathToLower\" + $link.shortName;
            "Shared" = "\\$domainName@SSL\alfresco\aos\$pathToLower";
        }
    }

    $targetPath = $findPath.Get_Item($whatPath)

    if ($targetPath.length -eq 0) {
        return $false
    }

    $wshShell = New-Object -ComObject WScript.Shell
    $shortcut = $wshShell.CreateShortcut("$path")

    $shortcut.TargetPath = $targetPath
    $shortcut.Description = $link.description
    if($link.icon){
        $iconLocation = "$appData\{0}" -f $link.icon.Split('\')[-1]
        $shortcut.IconLocation = $iconLocation
    }
    $shortcut.Save()
    return $shortcut
}

function Delete-Links {
    $shortcuts = @{}
    $shortcuts.Total = Get-ChildItem -Recurse $linkBaseDir -Include *.lnk
    $shell = New-Object -ComObject WScript.Shell

    foreach ($shortcut in $shortcuts.Total) {
        if ($shell.CreateShortcut($shortcut).targetpath -like "*\*lfresco\*") {
            $shortcuts.Removed++
            Remove-Item $shortcut
        }
        else {
            $shortcuts.User++
        }
    }

    [Runtime.InteropServices.Marshal]::ReleaseComObject($shell) | Out-Null

    return $shortcuts
}
