function ConvertTo-XMLFolderRedirection {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [switch] $SingleObject
    )
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