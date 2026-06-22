function New-DescriptEntry {
    param(
        [string[]]$Parts,
        [bool]$IsDirectory = $true
    )

    return [pscustomobject]@{
        Parts = [string[]]$Parts
        IsDirectory = $IsDirectory
        SourceLine = 0
    }
}
