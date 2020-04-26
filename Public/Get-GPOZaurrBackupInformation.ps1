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
                    $Xml.Backups.BackupInst | ForEach-Object -Process {
                        [PSCustomObject] @{
                            DisplayName      = $_.GPODisplayName.'#cdata-section'
                            DomainName       = $_.GPODomain.'#cdata-section'
                            Guid             = $_.GPOGUid.'#cdata-section' -replace '{' -replace '}'
                            DomainGuid       = $_.GPODomainGuid.'#cdata-section' -replace '{' -replace '}'
                            DomainController = $_.GPODomainController.'#cdata-section'
                            BackupTime       = [DateTime]::Parse($_.BackupTime.'#cdata-section')
                            ID               = $_.ID.'#cdata-section' -replace '{' -replace '}'
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