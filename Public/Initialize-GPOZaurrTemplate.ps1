function Initialize-GPOZaurrTemplate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $Name,
        [Parameter(Mandatory)][string] $Path,
        [string] $ExportPath
    )

    $Files = Get-ChildItem -Path $Path -Filter "*.admx" -Recurse -File
    $TotalFiles = $Files.Count
    $ProgressIncrement = [math]::Ceiling($TotalFiles / 10)
    $CurrentProgress = 0

    $FullList = foreach ($File in $Files) {
        $CurrentProgress++
        if ($CurrentProgress % $ProgressIncrement -eq 0) {
            Write-Verbose ("Initialize-GPOZaurrTemplate - Processing $Name, template file {0} of {1} ({2}%)" -f $CurrentProgress, $TotalFiles, [math]::Round(($CurrentProgress / $TotalFiles) * 100))
        }
        $HashInformation = Get-FileHash -LiteralPath $File.FullName
        $Directories = Get-ChildItem -Path $File.DirectoryName -Directory
        $Languages = [ordered] @{}
        foreach ($Directory in $Directories) {
            $LanguageFile = [io.path]::Combine($Directory.FullName, $File.BaseName + ".adml")
            $Item = Get-Item -Path $LanguageFile -ErrorAction SilentlyContinue
            if (Test-Path -Path $LanguageFile) {
                $HashInformation = Get-FileHash -LiteralPath $LanguageFile
                $Languages[$Directory.Name] = [PSCustomObject]@{
                    Name             = $Directory.Name
                    Hash             = $HashInformation.Hash
                    Algorithm        = $HashInformation.Algorithm
                    Size             = $Item.Length
                    CreationTimeUtc  = $Item.CreationTimeUtc
                    LastWriteTimeUtc = $Item.LastWriteTimeUtc
                }
            }
        }
        [PSCustomObject] @{
            Name               = $File.Name
            Hash               = $HashInformation.Hash
            Algorithm          = $HashInformation.Algorithm
            Size               = $File.Length
            LanguagesAvailable = $Languages.Keys
            LanguagesCount     = $Languages.Keys.Count
            CreationTimeUtc    = $File.CreationTimeUtc
            LastWriteTimeUtc   = $File.LastWriteTimeUtc
            LanguageFile       = $Languages
        }
    }

    $OutputObject = [PSCustomObject] @{
        Name      = $Name
        Path      = $Path
        Templates = $FullList
    }
    if ($ExportPath) {
        if ($ExportPath.EndsWith('.xml')) {
            $ExportType = 'XML'
        } elseif ($ExportPath.EndsWith('.json')) {
            $ExportType = 'JSON'
        } else {
            $ExportType = 'XML'
        }
        if ($ExportType -eq 'XML') {
            $OutputObject | Export-Clixml -Path $ExportPath -ErrorAction Stop
        } elseif ($ExportType -eq 'JSON') {
            $OutputObject | ConvertTo-Json -Depth 10 | Set-Content -Path $ExportPath -ErrorAction Stop
        } else {
            Write-Warning "ExportType $ExportType is not supported. Exporting to XML."
        }
    }
    $OutputObject
}