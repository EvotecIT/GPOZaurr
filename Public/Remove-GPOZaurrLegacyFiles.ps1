function Remove-GPOZaurrLegacyFiles {
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,

        [int] $LimitProcessing = [int32]::MaxValue
    )
    $Splat = @{
        Forest                    = $Forest
        IncludeDomains            = $IncludeDomains
        ExcludeDomains            = $ExcludeDomains
        ExtendedForestInformation = $ExtendedForestInformation
        Verbose                   = $VerbosePreference
    }
    Get-GPOZaurrLegacyFiles @Splat | Select-Object -First $LimitProcessing | ForEach-Object {
        try {
            Remove-Item -Path $_.FullName -ErrorAction Stop
        } catch {
            $ErrorMessage = $_.Exception.Message
            Write-Warning "Remove-GPOZaurrLegacyFiles - Failed to remove file $($_.FullName): $($ErrorMessage)."
        }
    }
}