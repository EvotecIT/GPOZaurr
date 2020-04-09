function Get-GPOZaurrBackupInformation {
    [cmdletBinding()]
    param(
        [string[]] $BackupFolder
    )
    Begin {

    }
    Process {
        foreach ($Folder in $BackupFolder) {
            if ($Folder) {
                if ((Test-Path -LiteralPath "$Folder\manifest.xml")) {
                    [xml] $Xml = Get-Content -LiteralPath "$Folder\manifest.xml"
                    $Xml.Backups.BackupInst | ForEach-Object {
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
                } else {
                    Write-Warning "Get-GPOZaurrBackupInformation - No backup information available"
                }
            }
        }
    }
    End {

    }
}