$functionFiles = @(
    "Remove-InlineComment.ps1",
    "ConvertTo-EntryName.ps1",
    "ConvertTo-LineEntry.ps1",
    "New-LineRecord.ps1",
    "Get-HeadingDepthFromStyle.ps1",
    "Read-TextRecords.ps1",
    "Read-DocxRecords.ps1",
    "Read-HwpxRecords.ps1",
    "Read-InputRecords.ps1",
    "ConvertTo-SafeDirectoryName.ps1",
    "ConvertTo-ReportHeading.ps1",
    "Read-ReportStructure.ps1",
    "Read-DirectoryStructure.ps1",
    "Remove-DuplicateRoot.ps1",
    "Build-FromInputFile.ps1"
)

foreach ($functionFile in $functionFiles) {
    . (Join-Path $PSScriptRoot $functionFile)
}

. (Join-Path (Split-Path -Parent $PSScriptRoot) "descript\load.ps1")
