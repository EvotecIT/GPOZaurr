function ConvertTo-XMLUserRightsAssignment {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [switch] $SingleObject
    )

    $UserRightsTranslation = @{
        SeNetworkLogonRight             = 'Access this computer from the network'
        SeMachineAccountPrivilege       = 'Add workstations to domain'
        SeIncreaseQuotaPrivilege        = 'Adjust memory quotas for a process'
        SeInteractiveLogonRight         = 'Allow log on locally'
        SeBackupPrivilege               = 'Back up files and directories'
        SeChangeNotifyPrivilege         = 'Bypass traverse checking Everyone'
        SeSystemTimePrivilege           = 'Change the system time'
        SeCreatePagefilePrivilege       = 'Create a pagefile'
        SeDebugPrivilege                = 'Debug programs'
        SeEnableDelegationPrivilege     = 'Enable computer and user accounts to be trusted for delegation'
        SeRemoteShutdownPrivilege       = 'Force shutdown from a remote system'
        SeAuditPrivilege                = 'Generate security audits'
        SeIncreaseBasePriorityPrivilege = 'Increase scheduling priority'
        SeLoadDriverPrivilege           = 'Load and unload device drivers'
        SeBatchLogonRight               = 'Log on as a batch job'
        SeSecurityPrivilege             = 'Manage auditing and security log'
        SeSystemEnvironmentPrivilege    = 'Modify firmware environment values'
        SeProfileSingleProcessPrivilege = 'Profile single process'
        SeSystemProfilePrivilege        = 'Profile system performance'
        SeUndockPrivilege               = 'Remove computer from docking station'
        SeAssignPrimaryTokenPrivilege   = 'Replace a process level token'
        SeRestorePrivilege              = 'Restore files and directories'
        SeShutdownPrivilege             = 'Shut down the system'
        SeTakeOwnershipPrivilege        = 'Take ownership of files or other objects'
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
        [Array] $CreateGPO['Settings'] = foreach ($Entry in $GPO.DataSet) {
            foreach ($Member in $Entry.Member) {
                [PSCustomObject]@{
                    'UserRightsAssignment'            = $Entry.Name
                    'UserRightsAssignmentDescription' = $UserRightsTranslation[$Entry.Name]
                    'Name'                            = $Member.Name.'#text'
                    'Sid'                             = $Member.SID.'#text'
                }
            }
        }
        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($Entry in $GPO.DataSet) {
            foreach ($Member in $Entry.Member) {
                $CreateGPO = [ordered]@{
                    DisplayName = $GPO.DisplayName
                    DomainName  = $GPO.DomainName
                    GUID        = $GPO.GUID
                    GpoType     = $GPO.GpoType
                    #GpoCategory = $GPOEntry.GpoCategory
                    #GpoSettings = $GPOEntry.GpoSettings
                }
                $CreateGPO['UserRightsAssignment'] = $Entry.Name
                $CreateGPO['UserRightsAssignmentDescription'] = $UserRightsTranslation[$Entry.Name]
                $CreateGPO['Name'] = $Member.Name.'#text'
                $CreateGPO['Sid'] = $Member.SID.'#text'
                #$CreateGPO['CreatedTime'] = $GPO.CreatedTime         # : 06.06.2020 18:03:36
                #$CreateGPO['ModifiedTime'] = $GPO.ModifiedTime        # : 17.06.2020 16:08:10
                #$CreateGPO['ReadTime'] = $GPO.ReadTime            # : 13.08.2020 10:15:37
                $CreateGPO['Linked'] = $GPO.Linked
                $CreateGPO['LinksCount'] = $GPO.LinksCount
                $CreateGPO['Links'] = $GPO.Links
                [PSCustomObject] $CreateGPO
            }
        }
    }
}