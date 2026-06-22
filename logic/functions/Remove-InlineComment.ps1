function Remove-InlineComment {
    param([string]$Line)

    $index = $Line.IndexOf(" #", [System.StringComparison]::Ordinal)
    if ($index -ge 0) {
        return $Line.Substring(0, $index).TrimEnd()
    }

    return $Line.TrimEnd()
}
