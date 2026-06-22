function New-LineRecord {
    param(
        [string]$Text,
        [Nullable[int]]$DepthHint = $null
    )

    return [pscustomobject]@{
        Text = $Text
        DepthHint = $DepthHint
    }
}
