function Read-InputRecords {
    param([System.IO.FileInfo]$InputFile)

    switch ($InputFile.Extension.ToLowerInvariant()) {
        ".md" { return Read-TextRecords $InputFile }
        ".txt" { return Read-TextRecords $InputFile }
        ".docx" { return Read-DocxRecords $InputFile }
        ".hwpx" { return Read-HwpxRecords $InputFile }
        default { throw "unsupported input extension: $($InputFile.Extension)" }
    }
}
