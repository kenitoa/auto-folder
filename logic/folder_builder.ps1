param(
    [string]$InputDir = (Join-Path (Split-Path -Parent $PSScriptRoot) "Input"),
    [string]$OutputDir = ([Environment]::GetFolderPath([Environment+SpecialFolder]::DesktopDirectory)),
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$SupportedInputExtensions = @(".md", ".txt", ".docx", ".hwpx")

. (Join-Path $PSScriptRoot "functions\load.ps1")

if (-not (Test-Path -LiteralPath $InputDir -PathType Container)) {
    throw "input folder does not exist: $InputDir"
}

if (-not $DryRun -and -not (Test-Path -LiteralPath $OutputDir -PathType Container)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$inputFiles = @(Get-ChildItem -LiteralPath $InputDir -File | Where-Object {
    $SupportedInputExtensions -contains $_.Extension.ToLowerInvariant()
} | Sort-Object Name)

if ($inputFiles.Count -eq 0) {
    Write-Output "No .md, .txt, .docx, or .hwpx files found in $InputDir"
    exit 0
}

$outputInfo = [System.IO.DirectoryInfo](Get-Item -LiteralPath $OutputDir)
foreach ($inputFile in $inputFiles) {
    Write-Output "[$($inputFile.Name)]"
    $targets = Build-FromInputFile $inputFile $outputInfo ([bool]$DryRun)
    foreach ($target in $targets) {
        Write-Output "  $target"
    }
}
