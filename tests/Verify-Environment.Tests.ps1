$ErrorActionPreference = 'Stop'

$script:RepositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$script:VerifierPath = Join-Path $script:RepositoryRoot 'tools\Verify-Environment.ps1'
$script:WindowsPowerShell = Join-Path $PSHOME 'powershell.exe'
$script:TestRoot = $null

function New-TestRoot {
    $path = Join-Path $env:TEMP ('dev-foundation-verify-environment-tests-' + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $path | Out-Null
    return $path
}

function New-CommandFixture {
    param(
        [string]$GitHelp = '--initial-branch',
        [int]$GitHelpExitCode = 129,
        [int]$GitVersionExitCode = 0,
        [string]$DotnetSdks = '99.9.9 [C:\fake-sdk]',
        [switch]$WithoutGit,
        [switch]$WithoutDotnet
    )

    $bin = Join-Path $script:TestRoot 'bin'
    New-Item -ItemType Directory -Path $bin | Out-Null

    if (-not $WithoutGit) {
        $gitContent = "@echo off`r`nif `"%1`"==`"--version`" (`r`n  echo git version fixture`r`n  exit /b $GitVersionExitCode`r`n)`r`nif `"%1`"==`"init`" if `"%2`"==`"-h`" (`r`n  echo $GitHelp`r`n  exit /b $GitHelpExitCode`r`n)`r`nexit /b 2`r`n"
        [System.IO.File]::WriteAllText((Join-Path $bin 'git.cmd'), $gitContent, [System.Text.Encoding]::ASCII)
    }

    if (-not $WithoutDotnet) {
        $dotnetContent = "@echo off`r`nif `"%1`"==`"--list-sdks`" (`r`n  echo DOTNET_CALLED`r`n  echo $DotnetSdks`r`n  exit /b 0`r`n)`r`nexit /b 2`r`n"
        [System.IO.File]::WriteAllText((Join-Path $bin 'dotnet.cmd'), $dotnetContent, [System.Text.Encoding]::ASCII)
    }

    return $bin
}

function New-FoundationFixture {
    param(
        [string]$GlobalJson = '{"sdk":{"version":"99.9.9"}}',
        [switch]$WithoutGlobalJson
    )

    $fixture = Join-Path $script:TestRoot 'foundation'
    $toolsPath = Join-Path $fixture 'tools'
    $profileTemplatePath = Join-Path $fixture 'profiles\dotnet-web\template'
    New-Item -ItemType Directory -Path $toolsPath, $profileTemplatePath | Out-Null
    Copy-Item -LiteralPath $script:VerifierPath -Destination (Join-Path $toolsPath 'Verify-Environment.ps1')
    if (-not $WithoutGlobalJson) {
        [System.IO.File]::WriteAllText((Join-Path $profileTemplatePath 'global.json'), $GlobalJson, [System.Text.Encoding]::UTF8)
    }
    return $fixture
}

function Invoke-Verifier {
    param(
        [string]$Verifier,
        [string]$Bin,
        [string]$Profile
    )

    $previousPath = $env:PATH
    try {
        $env:PATH = "$Bin;$env:WINDIR\System32"
        $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $Verifier)
        if (-not [string]::IsNullOrWhiteSpace($Profile)) {
            $arguments += @('-Profile', $Profile)
        }
        $output = @(& $script:WindowsPowerShell @arguments 2>&1)
        $exitCode = $LASTEXITCODE
    }
    finally {
        $env:PATH = $previousPath
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Output = ($output | Out-String)
    }
}

Describe 'Verify-Environment' {
    BeforeEach {
        $script:TestRoot = New-TestRoot
    }

    AfterEach {
        if ($null -ne $script:TestRoot -and (Test-Path -LiteralPath $script:TestRoot)) {
            Remove-Item -LiteralPath $script:TestRoot -Recurse -Force
        }
        $script:TestRoot = $null
    }

    It 'parses in Windows PowerShell 5.1 syntax' {
        $tokens = $null
        $errors = $null
        [void][System.Management.Automation.Language.Parser]::ParseFile($script:VerifierPath, [ref]$tokens, [ref]$errors)
        $errors.Count | Should Be 0
    }

    It 'is not an advanced script and exposes only the contracted Profile parameter' {
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($script:VerifierPath, [ref]$tokens, [ref]$errors)
        $command = Get-Command -Name $script:VerifierPath
        $commonParameters = @('Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable')

        $errors.Count | Should Be 0
        @($ast.ParamBlock.Attributes | Where-Object { $_.TypeName.FullName -eq 'CmdletBinding' }).Count | Should Be 0
        $command.Parameters.Count | Should Be 1
        $command.Parameters.ContainsKey('Profile') | Should Be $true
        foreach ($commonParameter in $commonParameters) {
            $command.Parameters.ContainsKey($commonParameter) | Should Be $false
        }
    }

    It 'reports a healthy core with no FAIL and exit code zero in a controlled command environment' {
        $bin = New-CommandFixture
        $result = Invoke-Verifier -Verifier $script:VerifierPath -Bin $bin

        $result.ExitCode | Should Be 0
        $result.Output | Should Match 'PASS core.windows_native:'
        $result.Output | Should Match 'PASS core.powershell_baseline:'
        $result.Output | Should Match 'PASS core.git_path:'
        $result.Output | Should Match 'PASS core.git_initial_branch:'
        $result.Output | Should Match 'summary: pass=\d+ warn=\d+ fail=0'
    }

    It 'fails coherently when git is unavailable' {
        $bin = New-CommandFixture -WithoutGit
        $result = Invoke-Verifier -Verifier $script:VerifierPath -Bin $bin

        $result.ExitCode | Should Be 1
        $result.Output | Should Match 'FAIL core.git_path:'
        $result.Output | Should Match 'FAIL core.git_initial_branch:'
    }

    It 'fails when git help does not advertise initial branch support' {
        $bin = New-CommandFixture -GitHelp 'usage: git init' -GitHelpExitCode 0
        $result = Invoke-Verifier -Verifier $script:VerifierPath -Bin $bin

        $result.ExitCode | Should Be 1
        $result.Output | Should Match 'FAIL core.git_initial_branch:'
    }

    It 'does not report Git branch support when git version already fails' {
        $bin = New-CommandFixture -GitVersionExitCode 2
        $result = Invoke-Verifier -Verifier $script:VerifierPath -Bin $bin

        $result.ExitCode | Should Be 1
        $result.Output | Should Match 'FAIL core.git_path:'
        $result.Output | Should Match 'FAIL core.git_initial_branch:'
        $result.Output | Should Not Match 'PASS core.git_initial_branch:'
    }

    It 'accepts advertised Git support even when git init help exits 129' {
        $bin = New-CommandFixture -GitHelp '--initial-branch' -GitHelpExitCode 129
        $result = Invoke-Verifier -Verifier $script:VerifierPath -Bin $bin

        $result.ExitCode | Should Be 0
        $result.Output | Should Match 'PASS core.git_initial_branch:'
    }

    It 'does not consult dotnet when no profile is requested' {
        $bin = New-CommandFixture
        $result = Invoke-Verifier -Verifier $script:VerifierPath -Bin $bin

        $result.ExitCode | Should Be 0
        $result.Output | Should Not Match 'DOTNET_CALLED'
        $result.Output | Should Not Match 'profile\.dotnet-web\.'
    }

    It 'derives the dotnet SDK requirement from the fixture global json' {
        $fixture = New-FoundationFixture -GlobalJson '{"sdk":{"version":"99.9.9"}}'
        $bin = New-CommandFixture -DotnetSdks '99.9.9 [C:\fake-sdk]'
        $result = Invoke-Verifier -Verifier (Join-Path $fixture 'tools\Verify-Environment.ps1') -Bin $bin -Profile 'dotnet-web'

        $result.ExitCode | Should Be 0
        $result.Output | Should Match 'PASS profile.dotnet-web.contract: sdk.version=99.9.9'
        $result.Output | Should Match 'PASS profile.dotnet-web.dotnet_path:'
        $result.Output | Should Match 'PASS profile.dotnet-web.sdk: required=99.9.9; installed=true'
    }

    It 'fails when the required dotnet SDK is absent' {
        $fixture = New-FoundationFixture -GlobalJson '{"sdk":{"version":"99.9.9"}}'
        $bin = New-CommandFixture -DotnetSdks '10.0.401 [C:\fake-sdk]'
        $result = Invoke-Verifier -Verifier (Join-Path $fixture 'tools\Verify-Environment.ps1') -Bin $bin -Profile 'dotnet-web'

        $result.ExitCode | Should Be 1
        $result.Output | Should Match 'FAIL profile.dotnet-web.sdk: required=99.9.9; installed=false'
    }

    It 'fails dotnet checks when dotnet is unavailable for the requested profile' {
        $fixture = New-FoundationFixture -GlobalJson '{"sdk":{"version":"99.9.9"}}'
        $bin = New-CommandFixture -WithoutDotnet
        $result = Invoke-Verifier -Verifier (Join-Path $fixture 'tools\Verify-Environment.ps1') -Bin $bin -Profile 'dotnet-web'

        $result.ExitCode | Should Be 1
        $result.Output | Should Match 'FAIL profile.dotnet-web.dotnet_path:'
        $result.Output | Should Match 'FAIL profile.dotnet-web.sdk:'
    }

    It 'fails the profile contract when global json is absent' {
        $fixture = New-FoundationFixture -WithoutGlobalJson
        $bin = New-CommandFixture
        $result = Invoke-Verifier -Verifier (Join-Path $fixture 'tools\Verify-Environment.ps1') -Bin $bin -Profile 'dotnet-web'

        $result.ExitCode | Should Be 1
        $result.Output | Should Match 'FAIL profile.dotnet-web.contract:'
    }

    It 'fails the profile contract when global json is malformed' {
        $fixture = New-FoundationFixture -GlobalJson '{not-json'
        $bin = New-CommandFixture
        $result = Invoke-Verifier -Verifier (Join-Path $fixture 'tools\Verify-Environment.ps1') -Bin $bin -Profile 'dotnet-web'

        $result.ExitCode | Should Be 1
        $result.Output | Should Match 'FAIL profile.dotnet-web.contract:'
    }

    It 'fails an unknown profile with the defined result id and exit code' {
        $bin = New-CommandFixture
        $result = Invoke-Verifier -Verifier $script:VerifierPath -Bin $bin -Profile 'unknown'

        $result.ExitCode | Should Be 1
        $result.Output | Should Match 'FAIL profile.selection:'
        $result.Output | Should Not Match 'DOTNET_CALLED'
    }

    It 'classifies execution policy without changing the real policy' {
        . $script:VerifierPath
        $passEntries = @(
            [pscustomobject]@{ Scope = 'MachinePolicy'; ExecutionPolicy = 'Undefined' },
            [pscustomobject]@{ Scope = 'UserPolicy'; ExecutionPolicy = 'Undefined' }
        )
        $warnEntries = @(
            [pscustomobject]@{ Scope = 'MachinePolicy'; ExecutionPolicy = 'AllSigned' },
            [pscustomobject]@{ Scope = 'UserPolicy'; ExecutionPolicy = 'Undefined' }
        )

        (Get-ExecutionPolicyCheckResult -PolicyEntries $passEntries -EffectivePolicy 'RemoteSigned').Status | Should Be 'PASS'
        (Get-ExecutionPolicyCheckResult -PolicyEntries $passEntries -EffectivePolicy 'Restricted').Status | Should Be 'WARN'
        (Get-ExecutionPolicyCheckResult -PolicyEntries $warnEntries -EffectivePolicy 'RemoteSigned').Status | Should Be 'WARN'
    }

    It 'keeps the normal verifier fixture files unchanged' {
        $fixture = New-FoundationFixture -GlobalJson '{"sdk":{"version":"99.9.9"}}'
        $verifier = Join-Path $fixture 'tools\Verify-Environment.ps1'
        $globalJson = Join-Path $fixture 'profiles\dotnet-web\template\global.json'
        $beforeVerifier = (Get-FileHash -LiteralPath $verifier -Algorithm SHA256).Hash
        $beforeGlobalJson = (Get-FileHash -LiteralPath $globalJson -Algorithm SHA256).Hash
        $bin = New-CommandFixture -DotnetSdks '99.9.9 [C:\fake-sdk]'

        $result = Invoke-Verifier -Verifier $verifier -Bin $bin -Profile 'dotnet-web'

        $result.ExitCode | Should Be 0
        (Get-FileHash -LiteralPath $verifier -Algorithm SHA256).Hash | Should Be $beforeVerifier
        (Get-FileHash -LiteralPath $globalJson -Algorithm SHA256).Hash | Should Be $beforeGlobalJson
    }

    It 'calculates summary counts and exit code from result statuses' {
        $bin = New-CommandFixture -WithoutGit
        $result = Invoke-Verifier -Verifier $script:VerifierPath -Bin $bin
        $lines = @($result.Output -split "`r?`n" | Where-Object { $_ -match '^(PASS|WARN|FAIL) ' })
        $passCount = @($lines | Where-Object { $_ -match '^PASS ' }).Count
        $warnCount = @($lines | Where-Object { $_ -match '^WARN ' }).Count
        $failCount = @($lines | Where-Object { $_ -match '^FAIL ' }).Count

        $result.Output | Should Match ("summary: pass={0} warn={1} fail={2}" -f $passCount, $warnCount, $failCount)
        $result.ExitCode | Should Be 1
    }
}
