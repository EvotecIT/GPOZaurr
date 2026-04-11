[CmdletBinding()]
param(
    [switch]$SkipBuild,
    [string]$ArtifactsRoot = (Join-Path $PSScriptRoot '..\WebsiteArtifacts')
)

$ErrorActionPreference = 'Stop'

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$moduleName = 'GPOZaurr'
$slug = 'gpozaurr'
$toleratedBuildFailure = $false
$docsSource = Join-Path $repoRoot 'Docs'
$helpCandidates = @(
    (Join-Path $repoRoot "en-US\$moduleName-help.xml"),
    (Join-Path $repoRoot "Artefacts\Unpacked\$moduleName\en-US\$moduleName-help.xml")
)
$examplesSource = Join-Path $repoRoot 'Examples'
$placeholderMarkers = @(
    '{{ Fill in the Synopsis }}',
    '{{ Fill in the Description }}',
    '{{ Add example code here }}',
    '{{ Add example description here }}'
)

function Import-LocalPSPublishModule {
    $candidateRoots = @()

    if ($env:POWERFORGE_ROOT) {
        $candidateRoots += $env:POWERFORGE_ROOT
    }

    $candidateRoots += [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\PSPublishModule'))

    foreach ($root in $candidateRoots | Select-Object -Unique) {
        if ([string]::IsNullOrWhiteSpace($root)) {
            continue
        }

        $manifestPath = Join-Path $root 'Module\PSPublishModule.psd1'
        if (Test-Path -LiteralPath $manifestPath -PathType Leaf) {
            Import-Module $manifestPath -Force -ErrorAction Stop
            return
        }
    }

    Import-Module PSPublishModule -Force -ErrorAction Stop
}

function Find-HelpFile {
    foreach ($candidate in $helpCandidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return [System.IO.Path]::GetFullPath($candidate)
        }
    }

    return $null
}

function Test-PlaceholderContent {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    foreach ($marker in $placeholderMarkers) {
        $match = Select-String -Path $Path -Pattern $marker -SimpleMatch -List -ErrorAction SilentlyContinue
        if ($match) {
            throw "Placeholder API content detected in '$Path' ($marker)."
        }
    }
}

function Get-PlaceholderMatches {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return @()
    }

    $files = if (Test-Path -LiteralPath $Path -PathType Container) {
        Get-ChildItem -LiteralPath $Path -File -Recurse
    } else {
        Get-Item -LiteralPath $Path
    }

    foreach ($file in $files) {
        foreach ($marker in $placeholderMarkers) {
            $match = Select-String -Path $file.FullName -Pattern $marker -SimpleMatch -List -ErrorAction SilentlyContinue
            if ($match) {
                [PSCustomObject]@{
                    Path = $file.FullName
                    Marker = $marker
                }
                break
            }
        }
    }
}

function Write-CommandMetadata {
    param(
        [Parameter(Mandatory)]
        [string]$ModuleManifestPath,
        [Parameter(Mandatory)]
        [string]$OutputPath
    )

    if (-not (Test-Path -LiteralPath $ModuleManifestPath -PathType Leaf)) {
        return
    }

    $resolvedManifestPath = [System.IO.Path]::GetFullPath($ModuleManifestPath)
    Remove-Module -Name $moduleName -Force -ErrorAction SilentlyContinue
    try {
        Import-Module $resolvedManifestPath -Force -ErrorAction Stop | Out-Null
        $allCommands = @(Get-Command -Module $moduleName -ErrorAction Stop)
        $aliasesByTarget = @{}

        foreach ($aliasCommand in $allCommands | Where-Object CommandType -EQ 'Alias') {
            $targetName = $aliasCommand.ResolvedCommandName
            if ([string]::IsNullOrWhiteSpace($targetName)) {
                continue
            }

            if (-not $aliasesByTarget.ContainsKey($targetName)) {
                $aliasesByTarget[$targetName] = [System.Collections.Generic.List[string]]::new()
            }

            if (-not $aliasesByTarget[$targetName].Contains($aliasCommand.Name)) {
                $null = $aliasesByTarget[$targetName].Add($aliasCommand.Name)
            }
        }

        $commandMetadata = foreach ($command in $allCommands | Where-Object CommandType -In @('Function', 'Cmdlet', 'Filter', 'ExternalScript') | Sort-Object Name) {
            [ordered]@{
                name    = $command.Name
                kind    = if ($command.CommandType -EQ 'Cmdlet') { 'Cmdlet' } else { 'Function' }
                aliases = @($aliasesByTarget[$command.Name] | Sort-Object -Unique)
            }
        }

        $payload = [ordered]@{
            moduleName  = $moduleName
            generatedAt = (Get-Date).ToString('o')
            commands    = @($commandMetadata)
        }

        $payload | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
    } finally {
        Remove-Module -Name $moduleName -Force -ErrorAction SilentlyContinue
    }
}

if (-not (Get-Command Invoke-ModuleBuild -ErrorAction SilentlyContinue)) {
    Import-LocalPSPublishModule
}

$helpPath = Find-HelpFile
if (-not $helpPath -and -not $SkipBuild) {
    $docsPlaceholders = @(Get-PlaceholderMatches -Path $docsSource)
    if ($docsPlaceholders.Count -gt 0) {
        $sample = ($docsPlaceholders | Select-Object -First 5 | ForEach-Object { "$($_.Path) [$($_.Marker)]" }) -join '; '
        Write-Warning "Docs still contain placeholder markdown from a previous generation pass. Continuing with module build so fresh external help can be regenerated. Sample matches: $sample"
    }

    try {
        & (Join-Path $PSScriptRoot 'Manage-Module.ps1') -SkipPublish
    } catch {
        $helpPath = Find-HelpFile
        if (-not $helpPath) {
            throw
        }

        Write-Warning "Manage-Module.ps1 reported a build failure after external help was generated. Continuing website artifact export with the refreshed help output. Original error: $($_.Exception.Message)"
        $toleratedBuildFailure = $true
    }

    $helpPath = Find-HelpFile
}

if (-not $helpPath) {
    throw "Unable to find $moduleName external help. Run .\Build\Manage-Module.ps1 first."
}

Test-PlaceholderContent -Path $helpPath

$resolvedArtifactsRoot = [System.IO.Path]::GetFullPath($ArtifactsRoot)
$apiRoot = Join-Path $resolvedArtifactsRoot 'apidocs\powershell'
$examplesTarget = Join-Path $apiRoot 'examples'

if (Test-Path -LiteralPath $apiRoot) {
    Remove-Item -LiteralPath $apiRoot -Recurse -Force
}

New-Item -ItemType Directory -Path $apiRoot -Force | Out-Null
Copy-Item -LiteralPath $helpPath -Destination (Join-Path $apiRoot "$moduleName-help.xml") -Force

$psd1Path = Join-Path $repoRoot "$moduleName.psd1"
if (Test-Path -LiteralPath $psd1Path -PathType Leaf) {
    Copy-Item -LiteralPath $psd1Path -Destination (Join-Path $apiRoot "$moduleName.psd1") -Force
    Write-CommandMetadata -ModuleManifestPath $psd1Path -OutputPath (Join-Path $apiRoot 'command-metadata.json')
}

if (Test-Path -LiteralPath $examplesSource -PathType Container) {
    Copy-Item -LiteralPath $examplesSource -Destination $examplesTarget -Recurse -Force
}

$version = $null
if (Test-Path -LiteralPath $psd1Path -PathType Leaf) {
    $version = (Import-PowerShellDataFile -Path $psd1Path).ModuleVersion.ToString()
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$manifest = [ordered]@{
    slug = $slug
    name = $moduleName
    description = 'GPOZaurr helps inspect, report on, and remediate Group Policy environments with PowerShell.'
    mode = 'hub-full'
    contentMode = 'hybrid'
    status = 'active'
    listed = $true
    version = $version
    generatedAt = (Get-Date).ToString('o')
    commit = $commit
    links = [ordered]@{
        source = 'https://github.com/EvotecIT/GPOZaurr'
    }
    surfaces = [ordered]@{
        docs = $true
        apiPowerShell = $true
        apiDotNet = $false
        examples = $true
    }
    artifacts = [ordered]@{
        api = 'WebsiteArtifacts/apidocs'
        docs = 'Website/content/project-docs'
        examples = 'Website/content/examples'
    }
}

$manifestPath = Join-Path $resolvedArtifactsRoot 'project-manifest.json'
New-Item -ItemType Directory -Path $resolvedArtifactsRoot -Force | Out-Null
$manifest | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $manifestPath -Encoding UTF8

Write-Host "Exported website artifacts -> $resolvedArtifactsRoot" -ForegroundColor Green

if ($toleratedBuildFailure -and $global:LASTEXITCODE -ne 0) {
    $global:LASTEXITCODE = 0
}
