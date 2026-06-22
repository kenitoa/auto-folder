function ConvertTo-SafeDirectoryName {
    param([string]$RawName)

    $name = (Remove-InlineComment $RawName).Trim()
    $name = $name -replace '^[#\s]+', ''
    $name = $name -replace '[<>:"\\|?*\x00-\x1f]', ' '
    $name = $name -replace '\s+', ' '
    $name = $name.Trim().Trim(".")

    if ([string]::IsNullOrWhiteSpace($name) -or $name -eq "." -or $name -eq "..") {
        return $null
    }

    if ($name.Length -gt 80) {
        $name = $name.Substring(0, 80).Trim()
    }

    return $name
}
