function Get-GPOZaurrBackupInformation {
    [cmdletBinding()]
    param(
        [string] $BackupFolder
    )
    if ($BackupFolder) {
        if ((Test-Path -LiteralPath "$BackupFolder\manifest.xml")) {
            [xml] $Xml = Get-Content -LiteralPath "$BackupFolder\manifest.xml"
            [Array] $BackupInformation = $Xml.Backups.BackupInst | ForEach-Object {
                [PSCustomObject] @{
                    DisplayName      = $_.GPODisplayName.'#cdata-section'
                    Domain           = $_.GPODomain.'#cdata-section'
                    Guid             = $_.GPOGUid.'#cdata-section'
                    DomainGuid       = $_.GPODomainGuid.'#cdata-section'
                    DomainController = $_.GPODomainController.'#cdata-section'
                    BackupTime       = $_.BackupTime.'#cdata-section'
                    ID               = $_.ID.'#cdata-section'
                    Comment          = $_.Comment.'#cdata-section'
                }
            }
            $BackupInformation
        } else {
            Write-Warning "Get-GPOZaurrBackupInformation - No backup information available"
        }
    }
}