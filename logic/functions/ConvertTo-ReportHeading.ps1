function ConvertTo-ReportHeading {
    param([object]$Record)

    $line = $Record.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($line)) {
        return $null
    }

    if ($null -ne $Record.DepthHint) {
        return [pscustomobject]@{
            Depth = [int]$Record.DepthHint
            Name = $line
        }
    }

    $markdownHeading = [regex]::Match($line, '^(?<marks>#{1,6})\s+(?<title>.+)$')
    if ($markdownHeading.Success) {
        return [pscustomobject]@{
            Depth = $markdownHeading.Groups["marks"].Value.Length - 1
            Name = $markdownHeading.Groups["title"].Value
        }
    }

    $numberedHeading = [regex]::Match($line, '^(?<number>\d+(?:\.\d+)*)(?:[.)])?\s+(?<title>.+)$')
    if ($numberedHeading.Success) {
        $depth = @($numberedHeading.Groups["number"].Value.Split(".") | Where-Object { $_ -ne "" }).Count - 1
        return [pscustomobject]@{
            Depth = $depth
            Name = $numberedHeading.Groups["title"].Value
        }
    }

    $romanHeading = [regex]::Match($line, '^(?:[IVXLCDM]+|[\u2160-\u2169]+)[.)]\s+(?<title>.+)$')
    if ($romanHeading.Success) {
        return [pscustomobject]@{
            Depth = 0
            Name = $romanHeading.Groups["title"].Value
        }
    }

    $koreanHeading = [regex]::Match($line, '^\p{IsHangulSyllables}[.)]\s+(?<title>.+)$')
    if ($koreanHeading.Success) {
        return [pscustomobject]@{
            Depth = 1
            Name = $koreanHeading.Groups["title"].Value
        }
    }

    return $null
}
