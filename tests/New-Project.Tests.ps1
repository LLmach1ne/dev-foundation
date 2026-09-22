$ErrorActionPreference = 'Stop'

$script:RepositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$script:GeneratorPath = Join-Path $script:RepositoryRoot 'tools\New-Project.ps1'
$script:WindowsPowerShell = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
$script:Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$script:Utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
$script:TestRoot = $null

function New-TestRoot {
    $path = Join-Path $env:TEMP ('dev-foundation-new-project-tests-' + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $path | Out-Null
    return $path
}

function New-TestDestination {
    $path = Join-Path $script:TestRoot 'destination'
    New-Item -ItemType Directory -Path $path | Out-Null
    return $path
}

function Get-CurrentFoundationVersion {
    $versionPath = Join-Path $script:RepositoryRoot 'VERSION'
    $content = [System.IO.File]::ReadAllText($versionPath, $script:Utf8Strict)
    return [System.Text.RegularExpressions.Regex]::Replace($content, '(?:\r\n|\r|\n)+$', '')
}

function Write-TestManifest {
    param(
        [string]$Path,
        [string]$ProjectSlug,
        [string]$Profile = 'dotnet-web',
        [string]$GovernanceLevel = 'standard',
        [string]$FoundationVersion = (Get-CurrentFoundationVersion),
        [string]$ProjectName = 'Bootstrap Test Project',
        [string]$Description = 'Description used by the bootstrap test suite.',
        [bool]$AddExtraField = $false
    )

    $manifest = [ordered]@{
        schema_version = '1.0'
        project_name = $ProjectName
        project_slug = $ProjectSlug
        description = $Description
        foundation_version = $FoundationVersion
        profile = $Profile
        governance_level = $GovernanceLevel
    }
    if ($AddExtraField) {
        $manifest.extra_field = 'must be rejected'
    }

    [System.IO.File]::WriteAllText($Path, ($manifest | ConvertTo-Json), $script:Utf8NoBom)
}

function Invoke-NewProject {
    param(
        [string]$Generator,
        [string]$Manifest,
        [string]$Destination
    )

    $previousErrorActionPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $output = @(& $script:WindowsPowerShell -NoProfile -ExecutionPolicy Bypass -File $Generator -Manifest $Manifest -Destination $Destination 2>&1)
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    return [pscustomobject]@{
        ExitCode = $exitCode
        Output = ($output | Out-String)
    }
}

function Copy-IsolatedFoundationFixture {
    $fixture = Join-Path $script:TestRoot 'foundation-fixture'
    New-Item -ItemType Directory -Path $fixture, (Join-Path $fixture 'tools'), (Join-Path $fixture 'templates'), (Join-Path $fixture 'profiles'), (Join-Path $fixture 'governance') | Out-Null

    Copy-Item -LiteralPath (Join-Path $script:RepositoryRoot 'VERSION') -Destination (Join-Path $fixture 'VERSION')
    Copy-Item -LiteralPath (Join-Path $script:RepositoryRoot 'tools\New-Project.ps1') -Destination (Join-Path $fixture 'tools\New-Project.ps1')
    Copy-Item -LiteralPath (Join-Path $script:RepositoryRoot 'templates\base') -Destination (Join-Path $fixture 'templates\base') -Recurse
    Copy-Item -LiteralPath (Join-Path $script:RepositoryRoot 'profiles\dotnet-web') -Destination (Join-Path $fixture 'profiles\dotnet-web') -Recurse
    foreach ($level in @('light', 'standard', 'critical')) {
        Copy-Item -LiteralPath (Join-Path $script:RepositoryRoot (Join-Path 'governance' $level)) -Destination (Join-Path $fixture (Join-Path 'governance' $level)) -Recurse
    }

    return $fixture
}

function Test-Utf8Bom {
    param([byte[]]$Bytes)
    return $Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF
}

function Test-CrLf {
    param([byte[]]$Bytes)
    for ($index = 0; $index -lt ($Bytes.Length - 1); $index++) {
        if ($Bytes[$index] -eq 13 -and $Bytes[$index + 1] -eq 10) {
            return $true
        }
    }
    return $false
}

Describe 'New-Project bootstrap' {
    BeforeEach {
        $script:TestRoot = New-TestRoot
    }

    AfterEach {
        if ($null -ne $script:TestRoot -and (Test-Path -LiteralPath $script:TestRoot)) {
            Remove-Item -LiteralPath $script:TestRoot -Recurse -Force
        }
        $script:TestRoot = $null
    }

    It 'generates a valid standard dotnet-web project with its contract artifacts' {
        $destination = New-TestDestination
        $manifestPath = Join-Path $script:TestRoot 'manifest.json'
        Write-TestManifest -Path $manifestPath -ProjectSlug 'valid-standard'

        $result = Invoke-NewProject -Generator $script:GeneratorPath -Manifest $manifestPath -Destination $destination
        $projectPath = Join-Path $destination 'valid-standard'

        $result.ExitCode | Should Be 0
        Test-Path -LiteralPath $projectPath -PathType Container | Should Be $true
        Test-Path -LiteralPath (Join-Path $projectPath 'AGENTS.md') -PathType Leaf | Should Be $true
        Test-Path -LiteralPath (Join-Path $projectPath 'src\App\App.csproj') -PathType Leaf | Should Be $true
        Test-Path -LiteralPath (Join-Path $projectPath 'docs\GOVERNANCE.md') -PathType Leaf | Should Be $true

        $readme = [System.IO.File]::ReadAllText((Join-Path $projectPath 'README.md'), $script:Utf8Strict)
        $readme | Should Match 'Bootstrap Test Project'
        $readme | Should Match 'Description used by the bootstrap test suite.'
        $readme | Should Not Match '\{\{PROJECT_NAME\}\}'
        $readme | Should Not Match '\{\{PROJECT_DESCRIPTION\}\}'
        $readme | Should Match '\[STATUS_ATUAL_DO_PROJETO\]'

        $lockPath = Join-Path $projectPath 'FOUNDATION.lock'
        $lock = [System.IO.File]::ReadAllText($lockPath, $script:Utf8Strict) | ConvertFrom-Json
        @($lock.PSObject.Properties.Name).Count | Should Be 5
        foreach ($field in @('schema_version', 'foundation_version', 'profile', 'governance_level', 'created_at')) {
            (@($lock.PSObject.Properties.Name) -contains $field) | Should Be $true
        }
        $lock.schema_version | Should Be '1.0'
        $lock.foundation_version | Should Be (Get-CurrentFoundationVersion)
        $lock.profile | Should Be 'dotnet-web'
        $lock.governance_level | Should Be 'standard'
        $lock.created_at | Should Match '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{7}Z$'
        Test-Path -LiteralPath (Join-Path $projectPath '.git') -PathType Container | Should Be $true
        & git -C $projectPath status --short | Out-Null
        $LASTEXITCODE | Should Be 0
    }

    It 'rejects a nonexistent profile before creating the final destination' {
        $destination = New-TestDestination
        $manifestPath = Join-Path $script:TestRoot 'manifest.json'
        Write-TestManifest -Path $manifestPath -ProjectSlug 'missing-profile' -Profile 'not-present'

        $result = Invoke-NewProject -Generator $script:GeneratorPath -Manifest $manifestPath -Destination $destination

        $result.ExitCode | Should Be 1
        $result.Output | Should Match 'partial_state=false'
        Test-Path -LiteralPath (Join-Path $destination 'missing-profile') | Should Be $false
    }

    It 'rejects an invalid governance level before creating the final destination' {
        $destination = New-TestDestination
        $manifestPath = Join-Path $script:TestRoot 'manifest.json'
        Write-TestManifest -Path $manifestPath -ProjectSlug 'invalid-governance' -GovernanceLevel 'unsupported'

        $result = Invoke-NewProject -Generator $script:GeneratorPath -Manifest $manifestPath -Destination $destination

        $result.ExitCode | Should Be 1
        $result.Output | Should Match 'partial_state=false'
        Test-Path -LiteralPath (Join-Path $destination 'invalid-governance') | Should Be $false
    }

    It 'rejects an incompatible Foundation version before creating the final destination' {
        $destination = New-TestDestination
        $manifestPath = Join-Path $script:TestRoot 'manifest.json'
        Write-TestManifest -Path $manifestPath -ProjectSlug 'wrong-version' -FoundationVersion 'incompatible-version'

        $result = Invoke-NewProject -Generator $script:GeneratorPath -Manifest $manifestPath -Destination $destination

        $result.ExitCode | Should Be 1
        $result.Output | Should Match 'partial_state=false'
        Test-Path -LiteralPath (Join-Path $destination 'wrong-version') | Should Be $false
    }

    It 'refuses an existing nonempty final destination without changing its content' {
        $destination = New-TestDestination
        $projectPath = Join-Path $destination 'existing-project'
        New-Item -ItemType Directory -Path $projectPath | Out-Null
        $sentinelPath = Join-Path $projectPath 'sentinel.txt'
        [System.IO.File]::WriteAllText($sentinelPath, 'preserve this content', $script:Utf8NoBom)
        $manifestPath = Join-Path $script:TestRoot 'manifest.json'
        Write-TestManifest -Path $manifestPath -ProjectSlug 'existing-project'

        $result = Invoke-NewProject -Generator $script:GeneratorPath -Manifest $manifestPath -Destination $destination

        $result.ExitCode | Should Be 1
        $result.Output | Should Match 'partial_state=false'
        [System.IO.File]::ReadAllText($sentinelPath, $script:Utf8Strict) | Should Be 'preserve this content'
    }

    It 'rejects a path traversal project slug without creating a directory outside Destination' {
        $destination = New-TestDestination
        $outsidePath = Join-Path $script:TestRoot 'escape'
        $manifestPath = Join-Path $script:TestRoot 'manifest.json'
        Write-TestManifest -Path $manifestPath -ProjectSlug '../escape'

        $result = Invoke-NewProject -Generator $script:GeneratorPath -Manifest $manifestPath -Destination $destination

        $result.ExitCode | Should Be 1
        $result.Output | Should Match 'partial_state=false'
        Test-Path -LiteralPath $outsidePath | Should Be $false
    }

    It 'rejects an unknown placeholder from an isolated Foundation fixture before creating the destination' {
        $fixture = Copy-IsolatedFoundationFixture
        $destination = New-TestDestination
        $templatePath = Join-Path $fixture 'templates\base\unknown.html'
        [System.IO.File]::WriteAllText($templatePath, '<p>{{UNKNOWN_PLACEHOLDER}}</p>', $script:Utf8NoBom)
        $manifestPath = Join-Path $script:TestRoot 'manifest.json'
        Write-TestManifest -Path $manifestPath -ProjectSlug 'unknown-placeholder'

        $result = Invoke-NewProject -Generator (Join-Path $fixture 'tools\New-Project.ps1') -Manifest $manifestPath -Destination $destination

        $result.ExitCode | Should Be 1
        $result.Output | Should Match 'partial_state=false'
        Test-Path -LiteralPath (Join-Path $destination 'unknown-placeholder') | Should Be $false
    }

    It 'fails the second generation in the same destination and preserves the first generation' {
        $destination = New-TestDestination
        $manifestPath = Join-Path $script:TestRoot 'manifest.json'
        Write-TestManifest -Path $manifestPath -ProjectSlug 'second-run'

        $first = Invoke-NewProject -Generator $script:GeneratorPath -Manifest $manifestPath -Destination $destination
        $readmePath = Join-Path $destination 'second-run\README.md'
        $firstReadme = [System.IO.File]::ReadAllText($readmePath, $script:Utf8Strict)
        $second = Invoke-NewProject -Generator $script:GeneratorPath -Manifest $manifestPath -Destination $destination

        $first.ExitCode | Should Be 0
        $second.ExitCode | Should Be 1
        $second.Output | Should Match 'partial_state=false'
        [System.IO.File]::ReadAllText($readmePath, $script:Utf8Strict) | Should Be $firstReadme
    }

    It 'rejects a manifest with an extra field before writing' {
        $destination = New-TestDestination
        $manifestPath = Join-Path $script:TestRoot 'manifest.json'
        Write-TestManifest -Path $manifestPath -ProjectSlug 'extra-field' -AddExtraField $true

        $result = Invoke-NewProject -Generator $script:GeneratorPath -Manifest $manifestPath -Destination $destination

        $result.ExitCode | Should Be 1
        $result.Output | Should Match 'partial_state=false'
        Test-Path -LiteralPath (Join-Path $destination 'extra-field') | Should Be $false
    }

    It 'does not mask significant whitespace in foundation_version' {
        $destination = New-TestDestination
        $manifestPath = Join-Path $script:TestRoot 'manifest.json'
        Write-TestManifest -Path $manifestPath -ProjectSlug 'version-whitespace' -FoundationVersion ((Get-CurrentFoundationVersion) + ' ')

        $result = Invoke-NewProject -Generator $script:GeneratorPath -Manifest $manifestPath -Destination $destination

        $result.ExitCode | Should Be 1
        $result.Output | Should Match 'foundation_version'
        Test-Path -LiteralPath (Join-Path $destination 'version-whitespace') | Should Be $false
    }

    It 'substitutes a placeholder in an extension outside the original allowlist using an isolated fixture' {
        $fixture = Copy-IsolatedFoundationFixture
        $destination = New-TestDestination
        $templatePath = Join-Path $fixture 'templates\base\placeholder.ps1'
        [System.IO.File]::WriteAllText($templatePath, "Write-Output '{{PROJECT_NAME}}'`r`n", $script:Utf8NoBom)
        $manifestPath = Join-Path $script:TestRoot 'manifest.json'
        Write-TestManifest -Path $manifestPath -ProjectSlug 'extension-placeholder' -ProjectName 'Script Placeholder Project'

        $result = Invoke-NewProject -Generator (Join-Path $fixture 'tools\New-Project.ps1') -Manifest $manifestPath -Destination $destination
        $generatedPath = Join-Path $destination 'extension-placeholder\placeholder.ps1'

        $result.ExitCode | Should Be 0
        [System.IO.File]::ReadAllText($generatedPath, $script:Utf8Strict) | Should Be "Write-Output 'Script Placeholder Project'`n"
    }

    It 'keeps a placeholder-shaped manifest value literal without cascading expansion' {
        $destination = New-TestDestination
        $manifestPath = Join-Path $script:TestRoot 'manifest.json'
        Write-TestManifest -Path $manifestPath -ProjectSlug 'literal-placeholder' -ProjectName '{{PROJECT_SLUG}}'

        $result = Invoke-NewProject -Generator $script:GeneratorPath -Manifest $manifestPath -Destination $destination
        $readme = [System.IO.File]::ReadAllText((Join-Path $destination 'literal-placeholder\README.md'), $script:Utf8Strict)

        $result.ExitCode | Should Be 0
        $literalPlaceholderPattern = [System.Text.RegularExpressions.Regex]::Escape('{{PROJECT_SLUG}}')
        $readme | Should Match $literalPlaceholderPattern
        $readme | Should Not Match '# literal-placeholder'
    }

    It 'writes FOUNDATION.lock as UTF-8 without BOM, LF-only, and UTC RFC3339' {
        $destination = New-TestDestination
        $manifestPath = Join-Path $script:TestRoot 'manifest.json'
        Write-TestManifest -Path $manifestPath -ProjectSlug 'lock-encoding'

        $result = Invoke-NewProject -Generator $script:GeneratorPath -Manifest $manifestPath -Destination $destination
        $lockPath = Join-Path $destination 'lock-encoding\FOUNDATION.lock'
        $lockBytes = [System.IO.File]::ReadAllBytes($lockPath)
        $lock = [System.IO.File]::ReadAllText($lockPath, $script:Utf8Strict) | ConvertFrom-Json

        $result.ExitCode | Should Be 0
        Test-Utf8Bom -Bytes $lockBytes | Should Be $false
        Test-CrLf -Bytes $lockBytes | Should Be $false
        $lock.created_at | Should Match '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{7}Z$'
    }

    It 'reports explicit prewrite state, destination, and failed stage' {
        $destination = New-TestDestination
        $manifestPath = Join-Path $script:TestRoot 'manifest.json'
        Write-TestManifest -Path $manifestPath -ProjectSlug 'prewrite-report' -AddExtraField $true

        $result = Invoke-NewProject -Generator $script:GeneratorPath -Manifest $manifestPath -Destination $destination

        $result.ExitCode | Should Be 1
        $result.Output | Should Match 'partial_state=false'
        $result.Output | Should Match 'destination=<unresolved>'
        $result.Output | Should Match 'failed_stage=manifest'
    }

    It 'composes light, standard, and critical governance overlays' {
        $destination = New-TestDestination
        foreach ($level in @('light', 'standard', 'critical')) {
            $manifestPath = Join-Path $script:TestRoot ("$level.json")
            $slug = "governance-$level"
            Write-TestManifest -Path $manifestPath -ProjectSlug $slug -GovernanceLevel $level

            $result = Invoke-NewProject -Generator $script:GeneratorPath -Manifest $manifestPath -Destination $destination
            $governanceContent = [System.IO.File]::ReadAllText((Join-Path $destination "$slug\docs\GOVERNANCE.md"), $script:Utf8Strict)
            $levelName = $level.Substring(0, 1).ToUpperInvariant() + $level.Substring(1)
            $governancePattern = "n.vel de governan.a \*\*$levelName"

            $result.ExitCode | Should Be 0
            $governanceContent | Should Match $governancePattern
        }
    }
}
