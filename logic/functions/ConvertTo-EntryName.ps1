function ConvertTo-EntryName {
    param([string]$RawName)

    $name = (Remove-InlineComment $RawName).Trim()
    if ([string]::IsNullOrWhiteSpace($name) -or $name.StartsWith("#")) {
        return $null
    }

    $isDirectory = $name.EndsWith("/")
    $name = $name.TrimEnd("/").Trim().Trim([char]96).Trim()
    if ([string]::IsNullOrWhiteSpace($name) -or $name -eq "." -or $name -eq "..") {
        return $null
    }

    if ($name -match "\s" -and $name -notmatch "[/\\]" -and -not $isDirectory) {
        return $null
    }

    if ([System.IO.Path]::IsPathRooted($name) -or $name -match "^[A-Za-z]:") {
        throw "absolute paths are not allowed: $name"
    }

    $parts = @(($name -split "[/\\]+") | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_.Trim() })
    $unsafePartCount = @($parts | Where-Object { $_ -eq "." -or $_ -eq ".." }).Count
    if ($parts.Count -eq 0 -or $unsafePartCount -gt 0) {
        throw "unsafe relative path: $name"
    }

    foreach ($part in $parts) {
        if ($part -match '[<>:"\\|?*\x00-\x1f]') {
            throw "invalid Windows path character in: $name"
        }
    }

    $lastPart = $parts[$parts.Count - 1]
    if (-not $isDirectory -and [string]::IsNullOrEmpty([System.IO.Path]::GetExtension($lastPart))) {
        $isDirectory = $true
    }

    return [pscustomobject]@{
        Parts = [string[]]$parts
        IsDirectory = $isDirectory
    }
}
