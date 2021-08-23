function ConvertTo-XMLFolderRedirection {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [switch] $SingleObject
    )
    # Redirection types a stored as GUID in GPOs. This hash is used to translate into readable text.
    $FolderID = @{
        "{1777F761-68AD-4D8A-87BD-30B759FA33DD}" = "Favorites"
        "{FDD39AD0-238F-46AF-ADB4-6C85480369C7}" = "Documents"
        "{33E28130-4E1E-4676-835A-98395C3BC3BB}" = "Pictures"
        "{4BD8D571-6D19-48D3-BE97-422220080E43}" = "Music"
        "{18989B1D-99B5-455B-841C-AB7C74E4DDFC}" = "Videos"
        "{3EB685DB-65F9-4CF6-A03A-E3EF65729F3D}" = "AppDataRoaming"
        "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" = "Desktop"
        "{625B53C3-AB48-4EC1-BA1F-A1EF4146FC19}" = "StartMenu"
        "{374DE290-123F-4565-9164-39C4925E467B}" = "Downloads"
        "{4C5C32FF-BB9D-43B0-B5B4-2D72E54EAAA4}" = "Saved Games"
        "{56784854-C6CB-462B-8169-88E350ACB882}" = "Contacts"
        "{7D1D3A04-DEBB-4115-95CF-2F29DA2920DA}" = "Searches"
        "{BFB9D5E0-C6A9-404C-B2B2-AE6DB6AF4968}" = "Links"
    }
    if ($SingleObject) {
        $CreateGPO = [ordered]@{
            DisplayName = $GPO.DisplayName
            DomainName  = $GPO.DomainName
            GUID        = $GPO.GUID
            GpoType     = $GPO.GpoType
            #GpoCategory = $GPOEntry.GpoCategory
            #GpoSettings = $GPOEntry.GpoSettings
            Count       = 0
            Settings    = $null
        }
        [Array] $CreateGPO['Settings'] = foreach ($Folder in $GPO.DataSet) {
            foreach ($Location in $Folder.Location) {
                [PSCustomObject] @{
                    FolderType                = $FolderID[$Folder.Id]
                    DestinationPath           = $Location.DestinationPath
                    SecuritySID               = $Location.SecurityGroup.SID.'#text'
                    SecurityName              = $Location.SecurityGroup.Name.'#text'
                    GrantExclusiveRights      = if ($Folder.GrantExclusiveRights -eq 'true') { $true } else { $false }
                    MoveContents              = if ($Folder.MoveContents -eq 'true') { $true } else { $false }
                    FollowParent              = if ($Folder.FollowParent -eq 'true') { $true } else { $false }
                    ApplyToDownLevel          = if ($Folder.ApplyToDownLevel -eq 'true') { $true } else { $false }
                    DoNotCare                 = if ($Folder.DoNotCare -eq 'true') { $true } else { $false }
                    RedirectToLocal           = if ($Folder.RedirectToLocal -eq 'true') { $true } else { $false }
                    PolicyRemovalBehavior     = $Folder.PolicyRemovalBehavior     # : LeaveContents
                    ConfigurationControl      = if ($Folder.ConfigurationControl -eq 'GP') { 'Group Policy' } else { $Folder.ConfigurationControl }      # : GP
                    PrimaryComputerEvaluation = $Folder.PrimaryComputerEvaluation # : PrimaryComputerPolicyDisabled
                }
            }
        }
        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($Folder in $GPO.DataSet) {
            foreach ($Location in $Folder.Location) {
                $CreateGPO = [ordered]@{
                    DisplayName               = $GPO.DisplayName
                    DomainName                = $GPO.DomainName
                    GUID                      = $GPO.GUID
                    GpoType                   = $GPO.GpoType
                    FolderType                = $FolderID[$Folder.Id]
                    Id                        = $Folder.Id
                    DestinationPath           = $Location.DestinationPath
                    SecuritySID               = $Location.SecurityGroup.SID.'#text'
                    SecurityName              = $Location.SecurityGroup.Name.'#text'
                    GrantExclusiveRights      = if ($Folder.GrantExclusiveRights -eq 'true') { $true } else { $false }
                    MoveContents              = if ($Folder.MoveContents -eq 'true') { $true } else { $false }
                    FollowParent              = if ($Folder.FollowParent -eq 'true') { $true } else { $false }
                    ApplyToDownLevel          = if ($Folder.ApplyToDownLevel -eq 'true') { $true } else { $false }
                    DoNotCare                 = if ($Folder.DoNotCare -eq 'true') { $true } else { $false }
                    RedirectToLocal           = if ($Folder.RedirectToLocal -eq 'true') { $true } else { $false }
                    PolicyRemovalBehavior     = $Folder.PolicyRemovalBehavior     # : LeaveContents
                    ConfigurationControl      = if ($Folder.ConfigurationControl -eq 'GP') { 'Group Policy' } else { $Folder.ConfigurationControl }      # : GP
                    PrimaryComputerEvaluation = $Folder.PrimaryComputerEvaluation # : PrimaryComputerPolicyDisabled
                    Linked                    = $GPO.Linked
                    LinksCount                = $GPO.LinksCount
                    Links                     = $GPO.Links
                }
                [PSCustomObject] $CreateGPO
            }
        }
    }
}