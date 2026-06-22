function Get-DescriptReportText {
    param([object[]]$Records)

    return [string]::Join("`n", @($Records | ForEach-Object { $_.Text }))
}
