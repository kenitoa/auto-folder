function Read-ReportStructure {
    param([object[]]$Records)

    $entries = New-Object System.Collections.Generic.List[object]
    $stack = New-Object System.Collections.Generic.List[object]
    $seen = New-Object 'System.Collections.Generic.HashSet[string]'
    $lineNumber = 0

    foreach ($record in $Records) {
        $lineNumber++
        $heading = ConvertTo-ReportHeading $record
        if ($null -eq $heading) {
            continue
        }

        $name = ConvertTo-SafeDirectoryName $heading.Name
        if ($null -eq $name) {
            continue
        }

        while ($stack.Count -gt 0 -and $stack[$stack.Count - 1].Depth -ge $heading.Depth) {
            $stack.RemoveAt($stack.Count - 1)
        }

        $fullParts = New-Object System.Collections.Generic.List[string]
        if ($stack.Count -gt 0) {
            foreach ($part in $stack[$stack.Count - 1].Parts) {
                $fullParts.Add([string]$part)
            }
        }
        $fullParts.Add($name)

        $key = [string]::Join("/", $fullParts)
        if (-not $seen.Add($key)) {
            continue
        }

        $entry = [pscustomobject]@{
            Parts = [string[]]$fullParts.ToArray()
            IsDirectory = $true
            SourceLine = $lineNumber
        }
        $entries.Add($entry)
        $stack.Add([pscustomobject]@{
            Depth = [int]$heading.Depth
            Parts = [string[]]@($entry.Parts)
        })
    }

    return $entries.ToArray()
}
