function ConvertTo-LineEntry {
    param([string]$Line)

    $raw = $Line.TrimEnd()
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return $null
    }

    $branch = [char]0x251C
    $corner = [char]0x2514
    $pipe = [char]0x2502
    $treeDash = [char]0x2500
    $connectorIndex = -1

    for ($i = 0; $i -lt $raw.Length; $i++) {
        if ($raw[$i] -eq $branch -or $raw[$i] -eq $corner) {
            $connectorIndex = $i
            break
        }
    }

    if ($connectorIndex -lt 0) {
        foreach ($connector in @("+--", ([string]([char]96) + "--"), "---")) {
            $index = $raw.IndexOf($connector, [System.StringComparison]::Ordinal)
            if ($index -ge 0 -and ($connectorIndex -lt 0 -or $index -lt $connectorIndex)) {
                $connectorIndex = $index
            }
        }
    }

    if ($connectorIndex -ge 0) {
        $prefix = $raw.Substring(0, $connectorIndex)
        $restIndex = $connectorIndex + 1
        while ($restIndex -lt $raw.Length -and ($raw[$restIndex] -eq " " -or $raw[$restIndex] -eq "-" -or $raw[$restIndex] -eq $treeDash)) {
            $restIndex++
        }

        $pipeCount = 0
        foreach ($char in $prefix.ToCharArray()) {
            if ($char -eq $pipe -or $char -eq "|") {
                $pipeCount++
            }
        }

        $indentOnly = $prefix.Replace([string]$pipe, "").Replace("|", "").Replace("`t", "    ")
        $spaceDepth = [Math]::Floor($indentOnly.Length / 4)
        $prefixDepth = $pipeCount + $spaceDepth

        return [pscustomobject]@{
            Depth = $prefixDepth + 1
            RawName = $raw.Substring($restIndex)
        }
    }

    $bulletMatch = [regex]::Match($raw, '^(?<indent>\s*)(?:[-*+]|\d+[.)])\s+')
    if ($bulletMatch.Success) {
        $indent = $bulletMatch.Groups["indent"].Value.Replace("`t", "    ")
        return [pscustomobject]@{
            Depth = [Math]::Floor($indent.Length / 2)
            RawName = $raw.Substring($bulletMatch.Length)
        }
    }

    $stripped = $raw.Trim()
    if ($stripped -match '^[A-Za-z][A-Za-z0-9+.-]*://') {
        return $null
    }

    if ($stripped -match "[/\\]" -and $stripped -notmatch "\s") {
        return [pscustomobject]@{
            Depth = 0
            RawName = $stripped
        }
    }

    return $null
}
