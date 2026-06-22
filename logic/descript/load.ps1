$descriptFiles = @(
    "New-DescriptEntry.ps1",
    "Get-DescriptReportText.ps1",
    "Get-DescriptBoundaryName.ps1",
    "Test-DescriptReport.ps1",
    "Get-DescriptFeatureNames.ps1",
    "Get-DescriptDeliverableNames.ps1",
    "Get-DescriptSkeletonEntries.ps1"
)

foreach ($descriptFile in $descriptFiles) {
    . (Join-Path $PSScriptRoot $descriptFile)
}
