[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Manifest,

    [Parameter(Mandatory = $true)]
    [string]$Destination
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$script:Utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
$script:PlaceholderPattern = '\{\{([A-Z][A-Z0-9_]*)\}\}'

function Fail {
    param([string]$Message)
    throw $Message
}

function Get-AbsolutePath {
    param([string]$Path, [string]$Label)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        Fail "$Label must not be empty."
    }

    try {
        return [System.IO.Path]::GetFullPath($Path)
    }
    catch {
        Fail "$Label cannot be resolved to an absolute path."
    }
}

function Read-JsonFile {
    param([string]$Path, [string]$Label)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Fail "$Label does not exist or is not a file: $Path"
    }

    try {
        return ([System.IO.File]::ReadAllText($Path, $script:Utf8Strict) | ConvertFrom-Json)
    }
    catch {
        Fail "$Label is not valid UTF-8 JSON: $Path"
    }
}

function Get-NormalizedVersionText {
    param([string]$Path)

    try {
        $content = [System.IO.File]::ReadAllText($Path, $script:Utf8Strict)
    }
    catch {
        Fail "VERSION is not valid UTF-8 text: $Path"
    }

    return [System.Text.RegularExpressions.Regex]::Replace($content, '(?:\r\n|\r|\n)+$', '')
}

function Assert-ExactProperties {
    param(
        [object]$Object,
        [string[]]$Expected,
        [string]$Label
    )

    if ($null -eq $Object) {
        Fail "$Label must be a JSON object."
    }

    $actual = @($Object.PSObject.Properties | ForEach-Object { $_.Name })
    if ($actual.Count -ne $Expected.Count) {
        Fail "$Label must contain exactly these fields: $($Expected -join ', ')."
    }

    foreach ($field in $Expected) {
        if ($actual -notcontains $field) {
            Fail "$Label must contain exactly these fields: $($Expected -join ', ')."
        }
    }
}

function Get-RequiredString {
    param([object]$Object, [string]$Field, [string]$Label)

    $value = $Object.PSObject.Properties[$Field].Value
    if ($value -isnot [string]) {
        Fail "$Label field '$Field' must be a string."
    }
    return $value
}

function Assert-NonEmptyString {
    param([string]$Value, [string]$Field, [string]$Label)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        Fail "$Label field '$Field' must not be empty after Trim()."
    }
}

function Test-PlaceholderCandidateFile {
    param([string]$Path)

    try {
        $bytes = [System.IO.File]::ReadAllBytes($Path)
    }
    catch {
        Fail "template_read_failed: $Path"
    }

    $hasCandidate = $false
    for ($index = 0; $index -lt ($bytes.Length - 1); $index++) {
        if ($bytes[$index] -eq 0x7B -and $bytes[$index + 1] -eq 0x7B) {
            $hasCandidate = $true
            break
        }
    }

    if (-not $hasCandidate) {
        return $false
    }

    foreach ($byte in $bytes) {
        if ($byte -eq 0) {
            Fail "placeholder_candidate_binary: $Path"
        }
    }

    return $true
}

function Get-TemplateInventory {
    param([string]$Root, [string]$Layer)

    if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
        Fail "$Layer template directory does not exist: $Root"
    }

    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd('\', '/')
    $items = New-Object System.Collections.Generic.List[object]
    $sourceItems = @(Get-ChildItem -LiteralPath $rootFull -Force -Recurse)

    foreach ($item in $sourceItems) {
        if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            Fail "$Layer template contains an unsupported reparse point: $($item.FullName)"
        }

        $relative = $item.FullName.Substring($rootFull.Length).TrimStart('\', '/')
        if ([string]::IsNullOrWhiteSpace($relative)) {
            Fail "$Layer template contains an invalid relative path."
        }

        $items.Add([pscustomobject]@{
                Layer = $Layer
                RelativePath = $relative.Replace('\', '/')
                SourcePath = $item.FullName
                IsDirectory = $item.PSIsContainer
                HasPlaceholderCandidate = (-not $item.PSIsContainer) -and (Test-PlaceholderCandidateFile -Path $item.FullName)
            })
    }

    return @($items | Sort-Object -Property @{ Expression = { $_.RelativePath.ToLowerInvariant() } }, @{ Expression = { $_.RelativePath } })
}

function Assert-CompositionIsSafe {
    param([object[]]$Inventory)

    $seen = New-Object 'System.Collections.Generic.Dictionary[string, object]' ([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($entry in $Inventory) {
        if ($seen.ContainsKey($entry.RelativePath)) {
            $previous = $seen[$entry.RelativePath]
            if ($previous.IsDirectory -and $entry.IsDirectory) {
                continue
            }
            Fail "composition_collision: '$($entry.RelativePath)' exists in both $($previous.Layer) and $($entry.Layer)."
        }
        $seen.Add($entry.RelativePath, $entry)
    }

    foreach ($entry in $Inventory) {
        $segments = $entry.RelativePath.Split('/')
        for ($index = 1; $index -lt $segments.Count; $index++) {
            $ancestor = ($segments[0..($index - 1)] -join '/')
            if ($seen.ContainsKey($ancestor) -and -not $seen[$ancestor].IsDirectory) {
                Fail "composition_collision: file '$ancestor' conflicts with descendant '$($entry.RelativePath)'."
            }
        }
    }

    foreach ($reserved in @('FOUNDATION.lock', '.git')) {
        foreach ($entry in $Inventory) {
            if ($entry.RelativePath.Equals($reserved, [System.StringComparison]::OrdinalIgnoreCase) -or
                $entry.RelativePath.StartsWith($reserved + '/', [System.StringComparison]::OrdinalIgnoreCase)) {
                Fail "composition_collision: reserved generated path '$reserved' is present in $($entry.Layer)."
            }
        }
    }
}

function Get-ProcessedText {
    param([string]$Path, [hashtable]$Values)

    try {
        $content = $script:Utf8Strict.GetString([System.IO.File]::ReadAllBytes($Path))
    }
    catch {
        Fail "text_template_invalid_utf8: $Path"
    }

    if ($content.IndexOf([char]0) -ge 0) {
        Fail "placeholder_candidate_binary: $Path"
    }

    $replaceMatch = [System.Text.RegularExpressions.MatchEvaluator]{
        param($match)

        switch ($match.Groups[1].Value) {
            'PROJECT_NAME' { return [string]$Values.PROJECT_NAME }
            'PROJECT_DESCRIPTION' { return [string]$Values.PROJECT_DESCRIPTION }
            'PROJECT_SLUG' { return [string]$Values.PROJECT_SLUG }
            default { Fail "unresolved_placeholder: $Path" }
        }
    }

    $content = [System.Text.RegularExpressions.Regex]::Replace($content, "`r`n?", "`n")
    return [System.Text.RegularExpressions.Regex]::Replace($content, $script:PlaceholderPattern, $replaceMatch) -replace "`r`n?", "`n"
}

function Write-FailureReport {
    param(
        [string]$Category,
        [string]$Stage,
        [bool]$DestinationCreated,
        [string]$FinalPath,
        [string]$Message
    )

    $partialState = if ($DestinationCreated) { 'true' } else { 'false' }
    $reportedDestination = if ([string]::IsNullOrWhiteSpace($FinalPath)) { '<unresolved>' } else { $FinalPath }
    Write-Error "category=$Category; stage=$Stage; $Message" -ErrorAction Continue
    Write-Error "partial_state=$partialState" -ErrorAction Continue
    Write-Error "destination=$reportedDestination" -ErrorAction Continue
    Write-Error "failed_stage=$Stage" -ErrorAction Continue
}

function Write-Utf8NoBomFile {
    param([string]$Path, [string]$Content)

    [System.IO.File]::WriteAllText($Path, $Content, $script:Utf8NoBom)
}

function New-FoundationLockContent {
    param([string]$FoundationVersion, [string]$Profile, [string]$GovernanceLevel)

    $lock = [ordered]@{
        schema_version = '1.0'
        foundation_version = $FoundationVersion
        profile = $Profile
        governance_level = $GovernanceLevel
        created_at = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ', [System.Globalization.CultureInfo]::InvariantCulture)
    }
    return (($lock | ConvertTo-Json) -replace "`r`n", "`n") + "`n"
}

$stage = 'initialization'
$failureCategory = 'prewrite_validation_failed'
$destinationCreated = $false
$finalPath = $null

try {
    $stage = 'foundation_root'
    $foundationRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
    $versionPath = Join-Path $foundationRoot 'VERSION'
    if (-not (Test-Path -LiteralPath $versionPath -PathType Leaf)) {
        Fail "foundation_invalid: VERSION does not exist: $versionPath"
    }
    $foundationVersion = Get-NormalizedVersionText -Path $versionPath
    if ([string]::IsNullOrWhiteSpace($foundationVersion)) {
        Fail 'foundation_invalid: VERSION contains no non-whitespace characters.'
    }

    $stage = 'manifest'
    $failureCategory = 'manifest_invalid'
    $manifestPath = Get-AbsolutePath -Path $Manifest -Label 'Manifest'
    $manifestObject = Read-JsonFile -Path $manifestPath -Label 'Manifest'
    $manifestFields = @('schema_version', 'project_name', 'project_slug', 'description', 'foundation_version', 'profile', 'governance_level')
    Assert-ExactProperties -Object $manifestObject -Expected $manifestFields -Label 'Manifest'

    $manifestValues = @{}
    foreach ($field in $manifestFields) {
        $manifestValues[$field] = Get-RequiredString -Object $manifestObject -Field $field -Label 'Manifest'
    }
    if ($manifestValues.schema_version -ne '1.0') { Fail "Manifest field 'schema_version' must be '1.0'." }
    Assert-NonEmptyString -Value $manifestValues.project_name -Field 'project_name' -Label 'Manifest'
    Assert-NonEmptyString -Value $manifestValues.description -Field 'description' -Label 'Manifest'
    if ($manifestValues.project_slug -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') { Fail "Manifest field 'project_slug' is invalid." }
    if ($manifestValues.profile -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') { Fail "Manifest field 'profile' is invalid." }
    if ($manifestValues.governance_level -notin @('light', 'standard', 'critical')) { Fail "Manifest field 'governance_level' is invalid." }
    if ($manifestValues.foundation_version -ne $foundationVersion) { Fail "Manifest field 'foundation_version' must exactly match VERSION." }

    $stage = 'profile'
    $failureCategory = 'profile_invalid'
    $profileRoot = Join-Path (Join-Path $foundationRoot 'profiles') $manifestValues.profile
    $profileJsonPath = Join-Path $profileRoot 'profile.json'
    $profileTemplatePath = Join-Path $profileRoot 'template'
    $profileObject = Read-JsonFile -Path $profileJsonPath -Label 'Profile metadata'
    $profileFields = @('schema_version', 'id', 'name', 'description')
    Assert-ExactProperties -Object $profileObject -Expected $profileFields -Label 'Profile metadata'
    foreach ($field in $profileFields) {
        $null = Get-RequiredString -Object $profileObject -Field $field -Label 'Profile metadata'
    }
    if ($profileObject.schema_version -ne '1.0') { Fail "Profile metadata field 'schema_version' must be '1.0'." }
    if ($profileObject.id -ne $manifestValues.profile -or $profileObject.id -ne (Split-Path -Leaf $profileRoot)) { Fail "Profile metadata field 'id' must match its directory and manifest profile." }
    Assert-NonEmptyString -Value $profileObject.name -Field 'name' -Label 'Profile metadata'
    Assert-NonEmptyString -Value $profileObject.description -Field 'description' -Label 'Profile metadata'
    if (-not (Test-Path -LiteralPath $profileTemplatePath -PathType Container)) { Fail "Profile template directory does not exist: $profileTemplatePath" }

    $stage = 'governance'
    $failureCategory = 'governance_invalid'
    $governanceTemplatePath = Join-Path (Join-Path (Join-Path $foundationRoot 'governance') $manifestValues.governance_level) 'template'
    if (-not (Test-Path -LiteralPath $governanceTemplatePath -PathType Container)) { Fail "Governance template directory does not exist: $governanceTemplatePath" }

    $stage = 'destination'
    $failureCategory = 'destination_invalid'
    $destinationPath = Get-AbsolutePath -Path $Destination -Label 'Destination'
    if (-not (Test-Path -LiteralPath $destinationPath -PathType Container)) { Fail "Destination does not exist or is not a directory: $destinationPath" }
    $finalPath = [System.IO.Path]::GetFullPath((Join-Path $destinationPath $manifestValues.project_slug))
    $destinationPrefix = $destinationPath.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    if (-not $finalPath.StartsWith($destinationPrefix, [System.StringComparison]::OrdinalIgnoreCase)) { Fail 'project_slug escapes Destination.' }
    if (Test-Path -LiteralPath $finalPath) { Fail "Final destination already exists: $finalPath" }

    $stage = 'git_availability'
    $failureCategory = 'environment_invalid'
    $gitCommand = Get-Command git -CommandType Application -ErrorAction SilentlyContinue
    if ($null -eq $gitCommand) { Fail 'git is not available on PATH.' }

    $stage = 'composition'
    $failureCategory = 'composition_invalid'
    $baseInventory = Get-TemplateInventory -Root (Join-Path $foundationRoot 'templates\base') -Layer 'Base'
    $profileInventory = Get-TemplateInventory -Root $profileTemplatePath -Layer 'Profile'
    $governanceInventory = Get-TemplateInventory -Root $governanceTemplatePath -Layer 'Governance'
    $inventory = @($baseInventory + $profileInventory + $governanceInventory)
    Assert-CompositionIsSafe -Inventory $inventory

    $stage = 'placeholder_prevalidation'
    $placeholders = @{
        PROJECT_NAME = $manifestValues.project_name
        PROJECT_DESCRIPTION = $manifestValues.description
        PROJECT_SLUG = $manifestValues.project_slug
    }
    foreach ($entry in $inventory | Where-Object { $_.HasPlaceholderCandidate }) {
        $null = Get-ProcessedText -Path $entry.SourcePath -Values $placeholders
    }

    $stage = 'create_destination'
    $failureCategory = 'generation_failed'
    New-Item -ItemType Directory -Path $finalPath | Out-Null
    $destinationCreated = $true

    $stage = 'copy_templates'
    foreach ($entry in $inventory) {
        $targetPath = Join-Path $finalPath ($entry.RelativePath.Replace('/', [System.IO.Path]::DirectorySeparatorChar))
        if ($entry.IsDirectory) {
            if (-not (Test-Path -LiteralPath $targetPath -PathType Container)) {
                New-Item -ItemType Directory -Path $targetPath | Out-Null
            }
        }
        else {
            $parentPath = Split-Path -Parent $targetPath
            if (-not (Test-Path -LiteralPath $parentPath -PathType Container)) {
                New-Item -ItemType Directory -Path $parentPath | Out-Null
            }
            if (Test-Path -LiteralPath $targetPath) { Fail "copy_conflict: target already exists: $targetPath" }
            if ($entry.HasPlaceholderCandidate) {
                Write-Utf8NoBomFile -Path $targetPath -Content (Get-ProcessedText -Path $entry.SourcePath -Values $placeholders)
            }
            else {
                [System.IO.File]::Copy($entry.SourcePath, $targetPath, $false)
            }
        }
    }

    $stage = 'foundation_lock'
    $lockPath = Join-Path $finalPath 'FOUNDATION.lock'
    Write-Utf8NoBomFile -Path $lockPath -Content (New-FoundationLockContent -FoundationVersion $foundationVersion -Profile $manifestValues.profile -GovernanceLevel $manifestValues.governance_level)

    $stage = 'git_init'
    & $gitCommand.Source init --initial-branch main $finalPath
    if ($LASTEXITCODE -ne 0) { Fail "git init failed with exit code $LASTEXITCODE." }

    $stage = 'verification'
    $failureCategory = 'verification_failed'
    foreach ($entry in $inventory) {
        $expectedPath = Join-Path $finalPath ($entry.RelativePath.Replace('/', [System.IO.Path]::DirectorySeparatorChar))
        if (-not (Test-Path -LiteralPath $expectedPath)) { Fail "verification_missing_path: $expectedPath" }
    }
    $lockObject = Read-JsonFile -Path $lockPath -Label 'FOUNDATION.lock'
    Assert-ExactProperties -Object $lockObject -Expected @('schema_version', 'foundation_version', 'profile', 'governance_level', 'created_at') -Label 'FOUNDATION.lock'
    if ($lockObject.schema_version -ne '1.0' -or $lockObject.foundation_version -ne $foundationVersion -or $lockObject.profile -ne $manifestValues.profile -or $lockObject.governance_level -ne $manifestValues.governance_level) { Fail 'FOUNDATION.lock values are invalid.' }
    if ($lockObject.created_at -notmatch '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{7}Z$') { Fail 'FOUNDATION.lock created_at is not UTC RFC 3339.' }
    foreach ($entry in $inventory | Where-Object { $_.HasPlaceholderCandidate }) {
        $generatedPath = Join-Path $finalPath ($entry.RelativePath.Replace('/', [System.IO.Path]::DirectorySeparatorChar))
        $generatedContent = $script:Utf8Strict.GetString([System.IO.File]::ReadAllBytes($generatedPath))
        $expectedContent = Get-ProcessedText -Path $entry.SourcePath -Values $placeholders
        if ($generatedContent -cne $expectedContent) { Fail "verification_placeholder_content_mismatch: $generatedPath" }
    }
    if (-not (Test-Path -LiteralPath (Join-Path $finalPath '.git') -PathType Container)) { Fail 'verification_missing_git_directory.' }
    $gitStatus = & $gitCommand.Source -C $finalPath status --short
    if ($LASTEXITCODE -ne 0) { Fail "git status --short failed with exit code $LASTEXITCODE." }

    Write-Output 'project_created=true'
    Write-Output "destination=$finalPath"
    Write-Output "foundation_version=$foundationVersion"
    Write-Output "profile=$($manifestValues.profile)"
    Write-Output "governance_level=$($manifestValues.governance_level)"
    Write-Output 'stages=manifest,profile,governance,destination,composition,copy,foundation_lock,git_init,verification'
    if ($gitStatus) { $gitStatus | Write-Output }
    exit 0
}
catch {
    $message = $_.Exception.Message
    Write-FailureReport -Category $failureCategory -Stage $stage -DestinationCreated $destinationCreated -FinalPath $finalPath -Message $message
    exit 1
}
