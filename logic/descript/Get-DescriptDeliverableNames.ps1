function Get-DescriptDeliverableNames {
    param([object[]]$Records)

    $deliverables = New-Object System.Collections.Generic.List[string]
    $inDeliverables = $false
    $deliverableSectionDepth = $null

    foreach ($record in $Records) {
        $line = $record.Text.Trim()
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        $heading = ConvertTo-ReportHeading $record
        $isDeliverableHeading = $null -ne $heading -and $heading.Name -match '(?i)\uC0B0\uCD9C\uBB3C|deliverable|output'

        if ($isDeliverableHeading -and -not $inDeliverables) {
            $inDeliverables = $true
            $deliverableSectionDepth = [int]$heading.Depth
            continue
        }

        if ($inDeliverables -and $null -ne $heading -and [int]$heading.Depth -le $deliverableSectionDepth) {
            break
        }

        if ($inDeliverables -and $line -match '^(?:[-*+]|\d+[.)])\s+(?<name>.+)$') {
            $name = ConvertTo-SafeDirectoryName $Matches["name"]
            if ($null -ne $name -and -not $deliverables.Contains($name)) {
                $deliverables.Add($name)
            }
        }
    }

    return $deliverables.ToArray()
}
