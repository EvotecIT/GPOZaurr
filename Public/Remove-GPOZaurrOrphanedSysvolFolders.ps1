function Remove-GPOZaurrOrphanedSysvolFolders {
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [int] $LimitProcessing = [int32]::MaxValue
    )
    Get-GPOZaurrSysvol | Where-Object {
        if ($_.Status -eq 'Orphaned GPO') {
            $_
        }
    } | Select-Object | Select-Object -First $LimitProcessing | ForEach-Object {
        Remove-Item -Recurse -Force -LiteralPath $_.Path
    }
}