function Read-DocxRecords {
    param([System.IO.FileInfo]$InputFile)

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($InputFile.FullName)

    try {
        $entry = $zip.GetEntry("word/document.xml")
        if ($null -eq $entry) {
            $entry = @($zip.Entries | Where-Object { $_.FullName -replace '\\', '/' -match '(^|/)word/document\.xml$' } | Select-Object -First 1)[0]
        }
        if ($null -eq $entry) {
            throw "word/document.xml was not found in $($InputFile.Name)"
        }

        $stream = $entry.Open()
        try {
            $xml = New-Object System.Xml.XmlDocument
            $xml.PreserveWhitespace = $false
            $xml.Load($stream)
        } finally {
            $stream.Dispose()
        }

        $namespaceManager = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
        $namespaceManager.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
        $records = New-Object System.Collections.Generic.List[object]

        foreach ($paragraph in $xml.SelectNodes("//w:body/w:p", $namespaceManager)) {
            $textParts = @($paragraph.SelectNodes(".//w:t", $namespaceManager) | ForEach-Object { $_.InnerText })
            $text = ([string]::Join("", $textParts)).Trim()
            if ([string]::IsNullOrWhiteSpace($text)) {
                continue
            }

            $styleNode = $paragraph.SelectSingleNode("./w:pPr/w:pStyle", $namespaceManager)
            $depthHint = $null
            if ($null -ne $styleNode) {
                $styleName = $styleNode.GetAttribute("val", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
                $depthHint = Get-HeadingDepthFromStyle $styleName
            }

            $records.Add((New-LineRecord $text $depthHint))
        }

        return $records.ToArray()
    } finally {
        $zip.Dispose()
    }
}
