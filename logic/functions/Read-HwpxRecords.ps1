function Read-HwpxRecords {
    param([System.IO.FileInfo]$InputFile)

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($InputFile.FullName)

    try {
        $records = New-Object System.Collections.Generic.List[object]
        $xmlEntries = @($zip.Entries | Where-Object {
            $_.FullName -match '\.xml$' -and ($_.FullName -match 'Contents/' -or $_.FullName -match 'section')
        } | Sort-Object FullName)

        foreach ($entry in $xmlEntries) {
            $stream = $entry.Open()
            try {
                $xml = New-Object System.Xml.XmlDocument
                $xml.PreserveWhitespace = $false
                $xml.Load($stream)
            } catch {
                continue
            } finally {
                $stream.Dispose()
            }

            foreach ($paragraph in $xml.SelectNodes("//*[local-name()='p']")) {
                $textParts = @($paragraph.SelectNodes(".//*[local-name()='t']") | ForEach-Object { $_.InnerText })
                $text = ([string]::Join("", $textParts)).Trim()
                if (-not [string]::IsNullOrWhiteSpace($text)) {
                    $records.Add((New-LineRecord $text))
                }
            }
        }

        return $records.ToArray()
    } finally {
        $zip.Dispose()
    }
}
