function Remove-DuplicateRoot {
    param(
        [object[]]$Entries,
        [string]$RootName
    )

    if ($null -eq $Entries) {
        return @()
    }

    $entryArray = [object[]]$Entries
    if ($entryArray.Length -eq 0 -or $null -eq $entryArray[0]) {
        return @()
    }

    $first = $entryArray[0]
    $firstParts = [string[]]@($first.Parts)
    if ($first.IsDirectory -and $firstParts.Count -eq 1 -and $firstParts[0].ToLowerInvariant() -eq $RootName.ToLowerInvariant()) {
        $adjusted = New-Object System.Collections.Generic.List[object]
        for ($i = 1; $i -lt $entryArray.Length; $i++) {
            $entry = $entryArray[$i]
            $entryParts = [string[]]@($entry.Parts)
            if ($entryParts.Count -gt 1 -and $entryParts[0].ToLowerInvariant() -eq $RootName.ToLowerInvariant()) {
                $adjusted.Add([pscustomobject]@{
                    Parts = [string[]]@($entryParts | Select-Object -Skip 1)
                    IsDirectory = $entry.IsDirectory
                    SourceLine = $entry.SourceLine
                })
            } else {
                $adjusted.Add($entry)
            }
        }
        return @($adjusted.ToArray() | Where-Object { @($_.Parts).Count -gt 0 })
    }

    return @($entryArray)
}
