function Get-DescriptSkeletonEntries {
    param([System.IO.FileInfo]$InputFile)

    $records = @(Read-InputRecords $InputFile)
    if (-not (Test-DescriptReport $records)) {
        return @()
    }

    $text = Get-DescriptReportText $records
    $entries = New-Object System.Collections.Generic.List[object]
    $seen = New-Object 'System.Collections.Generic.HashSet[string]'

    function Add-DescriptPath {
        param(
            [string[]]$Parts,
            [bool]$IsDirectory = $true
        )

        $key = [string]::Join("/", $Parts)
        if ($seen.Add($key)) {
            $entries.Add((New-DescriptEntry $Parts $IsDirectory))
        }
    }

    Add-DescriptPath -Parts @("docs")
    Add-DescriptPath -Parts @("docs", "README.md") -IsDirectory $false
    Add-DescriptPath -Parts @("docs", "requirements.md") -IsDirectory $false
    Add-DescriptPath -Parts @("docs", "functional-spec.md") -IsDirectory $false
    Add-DescriptPath -Parts @("docs", "screen-design.md") -IsDirectory $false
    Add-DescriptPath -Parts @("docs", "api-spec.md") -IsDirectory $false
    Add-DescriptPath -Parts @("docs", "db-design.md") -IsDirectory $false
    Add-DescriptPath -Parts @("docs", "test-plan.md") -IsDirectory $false
    Add-DescriptPath -Parts @("docs", "operation-manual.md") -IsDirectory $false

    Add-DescriptPath -Parts @("modules")
    foreach ($feature in @(Get-DescriptFeatureNames $records)) {
        Add-DescriptPath -Parts @("modules", $feature)
        Add-DescriptPath -Parts @("modules", $feature, "README.md") -IsDirectory $false
        Add-DescriptPath -Parts @("modules", $feature, "requirements.md") -IsDirectory $false
        Add-DescriptPath -Parts @("modules", $feature, "api.md") -IsDirectory $false
        Add-DescriptPath -Parts @("modules", $feature, "screens.md") -IsDirectory $false
        Add-DescriptPath -Parts @("modules", $feature, "tests.md") -IsDirectory $false
    }

    $hasBackend = $text -match 'Spring|Java|API|Server|Backend'
    $hasFrontend = $text -match 'React|Frontend|UI/UX|Dashboard'
    $hasAi = $text -match 'AI|Python|ML|Machine\s*Learning|Model|Analysis|Prediction|Recommendation'
    $hasDatabase = $text -match 'PostgreSQL|DB|Database|Redis|Cache'
    $hasInfra = $text -match 'Docker|Nginx|Monitoring|Deploy|Infrastructure|Redis'

    if ($hasBackend) {
        Add-DescriptPath -Parts @("backend")
        Add-DescriptPath -Parts @("backend", "src")
        Add-DescriptPath -Parts @("backend", "src", "main")
        Add-DescriptPath -Parts @("backend", "src", "test")
        Add-DescriptPath -Parts @("backend", "config")
        Add-DescriptPath -Parts @("backend", "README.md") -IsDirectory $false
        Add-DescriptPath -Parts @("backend", "build.gradle") -IsDirectory $false
    }

    if ($hasFrontend) {
        Add-DescriptPath -Parts @("frontend")
        Add-DescriptPath -Parts @("frontend", "src")
        Add-DescriptPath -Parts @("frontend", "src", "components")
        Add-DescriptPath -Parts @("frontend", "src", "pages")
        Add-DescriptPath -Parts @("frontend", "src", "services")
        Add-DescriptPath -Parts @("frontend", "tests")
        Add-DescriptPath -Parts @("frontend", "README.md") -IsDirectory $false
        Add-DescriptPath -Parts @("frontend", "package.json") -IsDirectory $false
    }

    if ($hasAi) {
        Add-DescriptPath -Parts @("ai")
        Add-DescriptPath -Parts @("ai", "models")
        Add-DescriptPath -Parts @("ai", "pipelines")
        Add-DescriptPath -Parts @("ai", "notebooks")
        Add-DescriptPath -Parts @("ai", "tests")
        Add-DescriptPath -Parts @("ai", "README.md") -IsDirectory $false
        Add-DescriptPath -Parts @("ai", "requirements.txt") -IsDirectory $false
    }

    if ($hasDatabase) {
        Add-DescriptPath -Parts @("database")
        Add-DescriptPath -Parts @("database", "migrations")
        Add-DescriptPath -Parts @("database", "seeds")
        Add-DescriptPath -Parts @("database", "schemas")
        Add-DescriptPath -Parts @("database", "README.md") -IsDirectory $false
    }

    if ($hasInfra) {
        Add-DescriptPath -Parts @("infra")
        Add-DescriptPath -Parts @("infra", "docker")
        Add-DescriptPath -Parts @("infra", "nginx")
        Add-DescriptPath -Parts @("infra", "monitoring")
        Add-DescriptPath -Parts @("infra", "README.md") -IsDirectory $false
        Add-DescriptPath -Parts @("infra", "docker-compose.yml") -IsDirectory $false
    }

    Add-DescriptPath -Parts @("tests")
    Add-DescriptPath -Parts @("tests", "unit")
    Add-DescriptPath -Parts @("tests", "integration")
    Add-DescriptPath -Parts @("tests", "e2e")
    Add-DescriptPath -Parts @("tests", "performance")
    Add-DescriptPath -Parts @("tests", "security")
    Add-DescriptPath -Parts @("tests", "README.md") -IsDirectory $false

    Add-DescriptPath -Parts @("operations")
    Add-DescriptPath -Parts @("operations", "deployment")
    Add-DescriptPath -Parts @("operations", "manuals")
    Add-DescriptPath -Parts @("operations", "logs")
    Add-DescriptPath -Parts @("operations", "README.md") -IsDirectory $false

    $deliverables = @(Get-DescriptDeliverableNames $records)
    if ($deliverables.Count -gt 0) {
        Add-DescriptPath -Parts @("docs", "deliverables")
        foreach ($deliverable in $deliverables) {
            Add-DescriptPath -Parts @("docs", "deliverables", ($deliverable + ".md")) -IsDirectory $false
        }
    }

    return $entries.ToArray()
}
