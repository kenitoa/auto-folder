function Get-HeadingDepthFromStyle {
    param([string]$StyleName)

    if ([string]::IsNullOrWhiteSpace($StyleName)) {
        return $null
    }

    if ($StyleName -match '(?i)heading\s*([1-6])') {
        return [int]$Matches[1] - 1
    }

    if ($StyleName -match '\p{IsHangulSyllables}{2}\s*([1-6])') {
        return [int]$Matches[1] - 1
    }

    return $null
}
