function Read-DirectoryStructure {
    param([System.IO.FileInfo]$InputFile)

    $entries = New-Object System.Collections.Generic.List[object]
    $stack = New-Object System.Collections.Generic.List[object]
    $seen = New-Object 'System.Collections.Generic.HashSet[string]'
    $records = @(Read-InputRecords $InputFile)

    for ($i = 0; $i -lt $records.Count; $i++) {
        $lineEntry = ConvertTo-LineEntry $records[$i].Text
        if ($null -eq $lineEntry) {
            continue
        }

        $cleaned = ConvertTo-EntryName $lineEntry.RawName
        if ($null -eq $cleaned) {
            continue
        }

        while ($stack.Count -gt 0 -and $stack[$stack.Count - 1].Depth -ge $lineEntry.Depth) {
            $stack.RemoveAt($stack.Count - 1)
        }

        $fullParts = New-Object System.Collections.Generic.List[string]
        if ($stack.Count -gt 0) {
            foreach ($part in $stack[$stack.Count - 1].Parts) {
                $fullParts.Add([string]$part)
            }
        }
        foreach ($part in $cleaned.Parts) {
            $fullParts.Add([string]$part)
        }

        $key = [string]::Join("/", $fullParts)
        if (-not $seen.Add($key)) {
            continue
        }

        $entry = [pscustomobject]@{
            Parts = [string[]]$fullParts.ToArray()
            IsDirectory = [bool]$cleaned.IsDirectory
            SourceLine = $i + 1
        }
        $entries.Add($entry)

        if ($entry.IsDirectory) {
            $stack.Add([pscustomobject]@{
                Depth = $lineEntry.Depth
                Parts = [string[]]@($entry.Parts)
            })
        }
    }

    return $entries.ToArray()
}
