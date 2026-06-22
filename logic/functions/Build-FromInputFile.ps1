function Build-FromInputFile {
    param(
        [System.IO.FileInfo]$InputFile,
        [System.IO.DirectoryInfo]$TargetOutputDir,
        [bool]$PreviewOnly
    )

    $boundaryName = Get-DescriptBoundaryName $InputFile
    if ([string]::IsNullOrWhiteSpace($boundaryName)) {
        $boundaryName = $InputFile.BaseName
    }

    $outputRoot = Join-Path $TargetOutputDir.FullName $boundaryName
    $baseEntries = @(Remove-DuplicateRoot (Read-DirectoryStructure $InputFile) $InputFile.BaseName)
    $descriptEntries = @(Get-DescriptSkeletonEntries $InputFile)
    $entries = New-Object System.Collections.Generic.List[object]
    $seenEntries = New-Object 'System.Collections.Generic.HashSet[string]'

    foreach ($entry in @($baseEntries + $descriptEntries)) {
        $key = [string]::Join("/", @($entry.Parts))
        if ($seenEntries.Add($key)) {
            $entries.Add($entry)
        }
    }

    $targets = New-Object System.Collections.Generic.List[string]

    if (-not $PreviewOnly) {
        New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
    }
    $targets.Add($outputRoot)

    foreach ($entry in $entries.ToArray()) {
        $target = $outputRoot
        foreach ($part in @($entry.Parts)) {
            $target = Join-Path $target $part
        }

        if ($entry.IsDirectory) {
            if (-not $PreviewOnly) {
                New-Item -ItemType Directory -Path $target -Force | Out-Null
            }
        } else {
            if (-not $PreviewOnly) {
                $parent = Split-Path -Parent $target
                New-Item -ItemType Directory -Path $parent -Force | Out-Null
                New-Item -ItemType File -Path $target -Force | Out-Null
            }
        }

        $targets.Add($target)
    }

    $directoryFile = Join-Path $outputRoot ("directory" + $InputFile.Extension.ToLowerInvariant())
    if (-not $PreviewOnly) {
        Copy-Item -LiteralPath $InputFile.FullName -Destination $directoryFile -Force
    }
    $targets.Add($directoryFile)

    return $targets.ToArray()
}
