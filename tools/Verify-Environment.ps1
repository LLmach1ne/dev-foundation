param(
    [string]$Profile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-CheckResult {
    param(
        [ValidateSet('PASS', 'WARN', 'FAIL')]
        [string]$Status,
        [string]$Id,
        [string]$Message
    )

    return [pscustomobject]@{
        Status = $Status
        Id = $Id
        Message = $Message
    }
}

function Add-CheckResult {
    param(
        [System.Collections.Generic.List[object]]$Results,
        [ValidateSet('PASS', 'WARN', 'FAIL')]
        [string]$Status,
        [string]$Id,
        [string]$Message
    )

    $Results.Add((New-CheckResult -Status $Status -Id $Id -Message $Message))
}

function Get-PolicyValue {
    param(
        [object[]]$PolicyEntries,
        [string]$Scope
    )

    $entry = @($PolicyEntries | Where-Object { $_.Scope -eq $Scope } | Select-Object -First 1)
    if ($entry.Count -eq 0 -or $null -eq $entry[0].ExecutionPolicy) {
        return 'Undefined'
    }

    return [string]$entry[0].ExecutionPolicy
}

function Get-ExecutionPolicyCheckResult {
    param(
        [object[]]$PolicyEntries,
        [string]$EffectivePolicy
    )

    $machinePolicy = Get-PolicyValue -PolicyEntries $PolicyEntries -Scope 'MachinePolicy'
    $userPolicy = Get-PolicyValue -PolicyEntries $PolicyEntries -Scope 'UserPolicy'
    $details = "effective=$EffectivePolicy; MachinePolicy=$machinePolicy; UserPolicy=$userPolicy"

    if ($EffectivePolicy -eq 'Restricted' -or $machinePolicy -ne 'Undefined' -or $userPolicy -ne 'Undefined') {
        return New-CheckResult -Status 'WARN' -Id 'core.execution_policy' -Message "$details. Revisao ou correcao e humana; politicas corporativas nao devem ser contornadas."
    }

    return New-CheckResult -Status 'PASS' -Id 'core.execution_policy' -Message $details
}

function Get-RequiredDotnetSdkVersion {
    param([string]$FoundationRoot)

    $globalJsonPath = Join-Path $FoundationRoot 'profiles\dotnet-web\template\global.json'
    if (-not (Test-Path -LiteralPath $globalJsonPath -PathType Leaf)) {
        throw "global.json does not exist: $globalJsonPath"
    }

    $utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
    try {
        $globalJson = [System.IO.File]::ReadAllText($globalJsonPath, $utf8Strict) | ConvertFrom-Json
    }
    catch {
        throw "global.json is not valid UTF-8 JSON: $globalJsonPath"
    }

    if ($null -eq $globalJson.sdk -or $globalJson.sdk.version -isnot [string] -or [string]::IsNullOrWhiteSpace($globalJson.sdk.version)) {
        throw "global.json must contain a non-empty sdk.version string: $globalJsonPath"
    }

    return $globalJson.sdk.version.Trim()
}

function Test-DotnetSdkInstalled {
    param(
        [string[]]$SdkOutput,
        [string]$RequiredVersion
    )

    foreach ($line in $SdkOutput) {
        if ($line -match '^\s*([^\s]+)\s+\[' -and $Matches[1] -eq $RequiredVersion) {
            return $true
        }
    }

    return $false
}

function Write-CheckResults {
    param([object[]]$Results)

    foreach ($result in $Results) {
        [Console]::Out.WriteLine(('{0} {1}: {2}' -f $result.Status, $result.Id, $result.Message))
    }

    $passCount = @($Results | Where-Object { $_.Status -eq 'PASS' }).Count
    $warnCount = @($Results | Where-Object { $_.Status -eq 'WARN' }).Count
    $failCount = @($Results | Where-Object { $_.Status -eq 'FAIL' }).Count
    [Console]::Out.WriteLine(('summary: pass={0} warn={1} fail={2}' -f $passCount, $warnCount, $failCount))

    if ($failCount -gt 0) {
        return 1
    }

    return 0
}

function Invoke-VerifyEnvironment {
    param(
        [string]$Profile,
        [bool]$ProfileSpecified = $false
    )

    $results = New-Object 'System.Collections.Generic.List[object]'
    $foundationRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))

    if ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT) {
        Add-CheckResult -Results $results -Status 'PASS' -Id 'core.windows_native' -Message 'Windows detected.'
    }
    else {
        Add-CheckResult -Results $results -Status 'FAIL' -Id 'core.windows_native' -Message 'Windows was not detected.'
    }

    $edition = if ($PSVersionTable.ContainsKey('PSEdition')) { [string]$PSVersionTable.PSEdition } else { 'unknown' }
    $version = [string]$PSVersionTable.PSVersion
    if ($PSVersionTable.PSVersion.Major -eq 5 -and $PSVersionTable.PSVersion.Minor -eq 1 -and $edition -ne 'Core') {
        Add-CheckResult -Results $results -Status 'PASS' -Id 'core.powershell_baseline' -Message "edition=$edition; version=$version"
    }
    else {
        Add-CheckResult -Results $results -Status 'WARN' -Id 'core.powershell_baseline' -Message "edition=$edition; version=$version. Windows PowerShell 5.1 is the exercised baseline."
    }

    $gitCommand = Get-Command git -CommandType Application -ErrorAction SilentlyContinue
    if ($null -eq $gitCommand) {
        Add-CheckResult -Results $results -Status 'FAIL' -Id 'core.git_path' -Message 'git is not available on PATH.'
        Add-CheckResult -Results $results -Status 'FAIL' -Id 'core.git_initial_branch' -Message 'git support could not be inspected because git is not available on PATH.'
    }
    else {
        $gitVersionOutput = @(& $gitCommand.Source --version 2>&1)
        $gitVersionExitCode = $LASTEXITCODE
        if ($gitVersionExitCode -eq 0) {
            Add-CheckResult -Results $results -Status 'PASS' -Id 'core.git_path' -Message ("path={0}; {1}" -f $gitCommand.Source, (($gitVersionOutput | Out-String).Trim()))

            $gitHelpOutput = @(& $gitCommand.Source init -h 2>&1)
            $gitHelpText = $gitHelpOutput | Out-String
            if ($gitHelpText -match '--initial-branch') {
                Add-CheckResult -Results $results -Status 'PASS' -Id 'core.git_initial_branch' -Message 'git init -h advertises --initial-branch.'
            }
            else {
                Add-CheckResult -Results $results -Status 'FAIL' -Id 'core.git_initial_branch' -Message 'git init -h did not advertise --initial-branch or its help could not be inspected.'
            }
        }
        else {
            Add-CheckResult -Results $results -Status 'FAIL' -Id 'core.git_path' -Message "path=$($gitCommand.Source); git --version exited with code $gitVersionExitCode."
            Add-CheckResult -Results $results -Status 'FAIL' -Id 'core.git_initial_branch' -Message 'git support could not be inspected because git --version did not succeed.'
        }
    }

    try {
        $policyEntries = @(Get-ExecutionPolicy -List)
        $effectivePolicy = [string](Get-ExecutionPolicy)
        if ($policyEntries.Count -eq 0 -or [string]::IsNullOrWhiteSpace($effectivePolicy)) {
            throw 'Execution Policy returned no usable state.'
        }
        $results.Add((Get-ExecutionPolicyCheckResult -PolicyEntries $policyEntries -EffectivePolicy $effectivePolicy))
    }
    catch {
        Add-CheckResult -Results $results -Status 'FAIL' -Id 'core.execution_policy' -Message "Execution Policy state could not be collected: $($_.Exception.Message)"
    }

    if (-not $ProfileSpecified) {
        return (Write-CheckResults -Results $results)
    }

    if ($Profile -ne 'dotnet-web') {
        Add-CheckResult -Results $results -Status 'FAIL' -Id 'profile.selection' -Message "Unsupported profile '$Profile'. Only dotnet-web is defined for this verifier."
        return (Write-CheckResults -Results $results)
    }

    $requiredSdkVersion = $null
    try {
        $requiredSdkVersion = Get-RequiredDotnetSdkVersion -FoundationRoot $foundationRoot
        Add-CheckResult -Results $results -Status 'PASS' -Id 'profile.dotnet-web.contract' -Message "sdk.version=$requiredSdkVersion; source=profiles/dotnet-web/template/global.json"
    }
    catch {
        Add-CheckResult -Results $results -Status 'FAIL' -Id 'profile.dotnet-web.contract' -Message $_.Exception.Message
    }

    $dotnetCommand = Get-Command dotnet -CommandType Application -ErrorAction SilentlyContinue
    if ($null -eq $dotnetCommand) {
        Add-CheckResult -Results $results -Status 'FAIL' -Id 'profile.dotnet-web.dotnet_path' -Message 'dotnet is not available on PATH.'
        Add-CheckResult -Results $results -Status 'FAIL' -Id 'profile.dotnet-web.sdk' -Message 'SDK availability could not be checked because dotnet is not available on PATH.'
    }
    else {
        Add-CheckResult -Results $results -Status 'PASS' -Id 'profile.dotnet-web.dotnet_path' -Message "path=$($dotnetCommand.Source)"
        if ($null -eq $requiredSdkVersion) {
            Add-CheckResult -Results $results -Status 'FAIL' -Id 'profile.dotnet-web.sdk' -Message 'SDK availability could not be checked because sdk.version could not be derived from global.json.'
        }
        else {
            $sdkOutput = @(& $dotnetCommand.Source --list-sdks 2>&1)
            $sdkExitCode = $LASTEXITCODE
            if ($sdkExitCode -ne 0) {
                Add-CheckResult -Results $results -Status 'FAIL' -Id 'profile.dotnet-web.sdk' -Message "dotnet --list-sdks exited with code $sdkExitCode."
            }
            elseif (Test-DotnetSdkInstalled -SdkOutput $sdkOutput -RequiredVersion $requiredSdkVersion) {
                Add-CheckResult -Results $results -Status 'PASS' -Id 'profile.dotnet-web.sdk' -Message "required=$requiredSdkVersion; installed=true"
            }
            else {
                Add-CheckResult -Results $results -Status 'FAIL' -Id 'profile.dotnet-web.sdk' -Message "required=$requiredSdkVersion; installed=false"
            }
        }
    }

    return (Write-CheckResults -Results $results)
}

if ($MyInvocation.InvocationName -ne '.') {
    $profileSpecified = $PSBoundParameters.ContainsKey('Profile')
    exit (Invoke-VerifyEnvironment -Profile $Profile -ProfileSpecified $profileSpecified)
}
