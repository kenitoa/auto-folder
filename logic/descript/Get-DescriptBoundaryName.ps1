function Get-DescriptBoundaryName {
    param([System.IO.FileInfo]$InputFile)

    $records = @(Read-InputRecords $InputFile)
    if (-not (Test-DescriptReport $records)) {
        return $null
    }

    foreach ($record in $records) {
        $line = $record.Text.Trim()
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        $heading = ConvertTo-ReportHeading $record
        if ($null -eq $heading) {
            continue
        }

        $name = ConvertTo-SafeDirectoryName $heading.Name
        if ($null -eq $name) {
            continue
        }

        $name = $name -replace '(?i)\s*(report|proposal|plan|planning|specification)\s*$', ''
        $name = $name -replace '\s*(?:\uAC1C\uBC1C\uAE30\uD68D\uC11C|\uC0AC\uC5C5\uACC4\uD68D\uC11C|\uAE30\uD68D\uC11C|\uACC4\uD68D\uC11C|\uC81C\uC548\uC11C|\uBA85\uC138\uC11C|\uBCF4\uACE0\uC11C)\s*$', ''
        $name = $name -replace '\s+', ' '
        $name = $name.Trim().Trim(".")

        if (-not [string]::IsNullOrWhiteSpace($name)) {
            return $name
        }
    }

    return $null
}
