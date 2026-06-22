function Test-DescriptReport {
    param([object[]]$Records)

    $text = Get-DescriptReportText $Records
    $numberedSectionCount = @($Records | Where-Object { $_.Text.Trim() -match '^#{1,6}\s*\d+(?:[.)]|\s)' }).Count
    $tableRowCount = @($Records | Where-Object { $_.Text.Trim() -match '^\|' }).Count
    $hasTechSignal = $text -match 'Java|Spring|React|Python|PostgreSQL|Redis|Docker|Nginx|API|CRM|SaaS|WBS'

    return ($numberedSectionCount -ge 3) -or ($numberedSectionCount -ge 1 -and $hasTechSignal) -or ($tableRowCount -ge 3 -and $hasTechSignal)
}
