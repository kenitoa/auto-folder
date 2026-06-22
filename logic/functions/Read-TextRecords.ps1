function Read-TextRecords {
    param([System.IO.FileInfo]$InputFile)

    return @([System.IO.File]::ReadAllLines($InputFile.FullName, [System.Text.Encoding]::UTF8) | ForEach-Object {
        New-LineRecord $_
    })
}
