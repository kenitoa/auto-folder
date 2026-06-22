function Get-DescriptFeatureNames {
    param([object[]]$Records)

    $features = New-Object System.Collections.Generic.List[string]
    $inFeatureSection = $false
    $featureSectionDepth = $null

    foreach ($record in $Records) {
        $line = $record.Text.Trim()
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        $heading = ConvertTo-ReportHeading $record
        $isFeatureHeading = $null -ne $heading -and $heading.Name -match '(?i)\uAE30\uB2A5|feature|function'

        if ($isFeatureHeading -and -not $inFeatureSection) {
            $inFeatureSection = $true
            $featureSectionDepth = [int]$heading.Depth
            continue
        }

        if ($inFeatureSection -and $null -ne $heading -and [int]$heading.Depth -le $featureSectionDepth) {
            break
        }

        if ($inFeatureSection -and $null -ne $heading -and [int]$heading.Depth -gt $featureSectionDepth) {
            $name = ConvertTo-SafeDirectoryName $heading.Name
            if ($null -ne $name -and -not $features.Contains($name)) {
                $features.Add($name)
            }
            continue
        }

        if ($inFeatureSection -and $line -match '^#{3,6}\s+(?<name>.+)$') {
            $name = ConvertTo-SafeDirectoryName $Matches["name"]
            if ($null -ne $name -and -not $features.Contains($name)) {
                $features.Add($name)
            }
        }
    }

    return $features.ToArray()
}
