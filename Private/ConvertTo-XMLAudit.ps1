function ConvertTo-XMLAudit {
    <#
    .SYNOPSIS
    Converts a PowerShell custom object representing an audit policy into XML format.

    .DESCRIPTION
    This function takes a PowerShell custom object representing an audit policy and converts it into XML format for storage or transmission.

    .PARAMETER GPO
    The PowerShell custom object representing the audit policy.

    .PARAMETER SingleObject
    Indicates whether to convert a single object or multiple objects.

    .EXAMPLE
    ConvertTo-XMLAudit -GPO $auditPolicyObject -SingleObject

    Description:
    Converts the $auditPolicyObject into XML format for a single object.

    .EXAMPLE
    $auditPolicies | ConvertTo-XMLAudit -SingleObject

    Description:
    Converts multiple audit policies in $auditPolicies into XML format for each object.
    #>
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [switch] $SingleObject
    )
    $SettingType = @{
        '0' = 'No Auditing'
        '1' = 'Success'
        '2' = 'Failure'
        '3' = 'Success, Failure'
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
        [Array] $CreateGPO['Settings'] = @(
            $Settings = [ordered]@{
                AuditAccountLogon                        = 'Not configured'
                AuditAccountManage                       = 'Not configured'
                AuditDSAccess                            = 'Not configured'
                AuditLogonEvents                         = 'Not configured'
                AuditObjectAccess                        = 'Not configured'
                AuditPolicyChange                        = 'Not configured'
                AuditPrivilegeUse                        = 'Not configured'
                AuditProcessTracking                     = 'Not configured'
                AuditSystemEvents                        = 'Not configured'
                # Advanced Policies
                AuditAccountLockout                      = 'Not configured'
                AuditApplicationGenerated                = 'Not configured'
                AuditApplicationGroupManagement          = 'Not configured'
                AuditAuditPolicyChange                   = 'Not configured'
                AuditAuthenticationPolicyChange          = 'Not configured'
                AuditAuthorizationPolicyChange           = 'Not configured'
                AuditCentralAccessPolicyStaging          = 'Not configured'
                AuditCertificationServices               = 'Not configured'
                AuditComputerAccountManagement           = 'Not configured'
                AuditCredentialValidation                = 'Not configured'
                AuditDetailedDirectoryServiceReplication = 'Not configured'
                AuditDetailedFileShare                   = 'Not configured'
                AuditDirectoryServiceAccess              = 'Not configured'
                AuditDirectoryServiceChanges             = 'Not configured'
                AuditDirectoryServiceReplication         = 'Not configured'
                AuditDistributionGroupManagement         = 'Not configured'
                AuditDPAPIActivity                       = 'Not configured'
                AuditFileShare                           = 'Not configured'
                AuditFileSystem                          = 'Not configured'
                AuditFilteringPlatformConnection         = 'Not configured'
                AuditFilteringPlatformPacketDrop         = 'Not configured'
                AuditFilteringPlatformPolicyChange       = 'Not configured'
                AuditGroupMembership                     = 'Not configured'
                AuditHandleManipulation                  = 'Not configured'
                AuditIPsecDriver                         = 'Not configured'
                AuditIPsecExtendedMode                   = 'Not configured'
                AuditIPsecMainMode                       = 'Not configured'
                AuditIPsecQuickMode                      = 'Not configured'
                AuditKerberosAuthenticationService       = 'Not configured'
                AuditKerberosServiceTicketOperations     = 'Not configured'
                AuditKernelObject                        = 'Not configured'
                AuditLogoff                              = 'Not configured'
                AuditLogon                               = 'Not configured'
                AuditMPSSVCRuleLevelPolicyChange         = 'Not configured'
                AuditNetworkPolicyServer                 = 'Not configured'
                AuditNonSensitivePrivilegeUse            = 'Not configured'
                AuditOtherAccountLogonEvents             = 'Not configured'
                AuditOtherAccountManagementEvents        = 'Not configured'
                AuditOtherLogonLogoffEvents              = 'Not configured'
                AuditOtherObjectAccessEvents             = 'Not configured'
                AuditOtherPolicyChangeEvents             = 'Not configured'
                AuditOtherPrivilegeUseEvents             = 'Not configured'
                AuditOtherSystemEvents                   = 'Not configured'
                AuditPNPActivity                         = 'Not configured'
                AuditProcessCreation                     = 'Not configured'
                AuditProcessTermination                  = 'Not configured'
                AuditRegistry                            = 'Not configured'
                AuditRemovableStorage                    = 'Not configured'
                AuditRPCEvents                           = 'Not configured'
                AuditSAM                                 = 'Not configured'
                AuditSecurityGroupManagement             = 'Not configured'
                AuditSecurityStateChange                 = 'Not configured'
                AuditSecuritySystemExtension             = 'Not configured'
                AuditSensitivePrivilegeUse               = 'Not configured'
                AuditSpecialLogon                        = 'Not configured'
                AuditSystemIntegrity                     = 'Not configured'
                AuditUserDeviceClaims                    = 'Not configured'
                AuditUserAccountManagement               = 'Not configured'
            }
            foreach ($GPOEntry in $GPO.DataSet) {
                if ($GPOEntry.PolicyTarget) {
                    # Category = 'AuditSettings', Settings = 'AuditSetting'
                    $Category = $GPOEntry.SubcategoryName -replace ' ', '' -replace '-', '' -replace '/', ''
                    if ($Settings["$($Category)"]) {
                        $Settings["$($Category)"] = $SettingType["$($GPOEntry.SettingValue)"]
                    }
                } else {
                    # Category = 'SecuritySettings', Settings = 'Audit'
                    $SuccessAttempts = try { [bool]::Parse($GPOEntry.SuccessAttempts) } catch { $null };
                    $FailureAttempts = try { [bool]::Parse($GPOEntry.FailureAttempts) } catch { $null };
                    if ($SuccessAttempts -and $FailureAttempts) {
                        $Setting = 'Success, Failure'
                    } elseif ($SuccessAttempts) {
                        $Setting = 'Success'
                    } elseif ($FailureAttempts) {
                        $Setting = 'Failure'
                    } else {
                        $Setting = 'Not configured'
                    }
                    $Settings["$($GPOEntry.Name)"] = $Setting
                }
            }
            [PSCustomObject] $Settings
        )

        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        $CreateGPO = [ordered]@{
            DisplayName                              = $GPO.DisplayName
            DomainName                               = $GPO.DomainName
            GUID                                     = $GPO.GUID
            GpoType                                  = $GPO.GpoType
            #GpoCategory = $GPOEntry.GpoCategory
            #GpoSettings = $GPOEntry.GpoSettings
            AuditAccountLogon                        = 'Not configured'
            AuditAccountManage                       = 'Not configured'
            AuditDSAccess                            = 'Not configured'
            AuditLogonEvents                         = 'Not configured'
            AuditObjectAccess                        = 'Not configured'
            AuditPolicyChange                        = 'Not configured'
            AuditPrivilegeUse                        = 'Not configured'
            AuditProcessTracking                     = 'Not configured'
            AuditSystemEvents                        = 'Not configured'
            # Advanced Policies
            AuditAccountLockout                      = 'Not configured'
            AuditApplicationGenerated                = 'Not configured'
            AuditApplicationGroupManagement          = 'Not configured'
            AuditAuditPolicyChange                   = 'Not configured'
            AuditAuthenticationPolicyChange          = 'Not configured'
            AuditAuthorizationPolicyChange           = 'Not configured'
            AuditCentralAccessPolicyStaging          = 'Not configured'
            AuditCertificationServices               = 'Not configured'
            AuditComputerAccountManagement           = 'Not configured'
            AuditCredentialValidation                = 'Not configured'
            AuditDetailedDirectoryServiceReplication = 'Not configured'
            AuditDetailedFileShare                   = 'Not configured'
            AuditDirectoryServiceAccess              = 'Not configured'
            AuditDirectoryServiceChanges             = 'Not configured'
            AuditDirectoryServiceReplication         = 'Not configured'
            AuditDistributionGroupManagement         = 'Not configured'
            AuditDPAPIActivity                       = 'Not configured'
            AuditFileShare                           = 'Not configured'
            AuditFileSystem                          = 'Not configured'
            AuditFilteringPlatformConnection         = 'Not configured'
            AuditFilteringPlatformPacketDrop         = 'Not configured'
            AuditFilteringPlatformPolicyChange       = 'Not configured'
            AuditGroupMembership                     = 'Not configured'
            AuditHandleManipulation                  = 'Not configured'
            AuditIPsecDriver                         = 'Not configured'
            AuditIPsecExtendedMode                   = 'Not configured'
            AuditIPsecMainMode                       = 'Not configured'
            AuditIPsecQuickMode                      = 'Not configured'
            AuditKerberosAuthenticationService       = 'Not configured'
            AuditKerberosServiceTicketOperations     = 'Not configured'
            AuditKernelObject                        = 'Not configured'
            AuditLogoff                              = 'Not configured'
            AuditLogon                               = 'Not configured'
            AuditMPSSVCRuleLevelPolicyChange         = 'Not configured'
            AuditNetworkPolicyServer                 = 'Not configured'
            AuditNonSensitivePrivilegeUse            = 'Not configured'
            AuditOtherAccountLogonEvents             = 'Not configured'
            AuditOtherAccountManagementEvents        = 'Not configured'
            AuditOtherLogonLogoffEvents              = 'Not configured'
            AuditOtherObjectAccessEvents             = 'Not configured'
            AuditOtherPolicyChangeEvents             = 'Not configured'
            AuditOtherPrivilegeUseEvents             = 'Not configured'
            AuditOtherSystemEvents                   = 'Not configured'
            AuditPNPActivity                         = 'Not configured'
            AuditProcessCreation                     = 'Not configured'
            AuditProcessTermination                  = 'Not configured'
            AuditRegistry                            = 'Not configured'
            AuditRemovableStorage                    = 'Not configured'
            AuditRPCEvents                           = 'Not configured'
            AuditSAM                                 = 'Not configured'
            AuditSecurityGroupManagement             = 'Not configured'
            AuditSecurityStateChange                 = 'Not configured'
            AuditSecuritySystemExtension             = 'Not configured'
            AuditSensitivePrivilegeUse               = 'Not configured'
            AuditSpecialLogon                        = 'Not configured'
            AuditSystemIntegrity                     = 'Not configured'
            AuditUserDeviceClaims                    = 'Not configured'
            AuditUserAccountManagement               = 'Not configured'
        }
        foreach ($GPOEntry in $GPO.DataSet) {
            if ($GPOEntry.PolicyTarget) {
                # Category = 'AuditSettings', Settings = 'AuditSetting'
                $Category = $GPOEntry.SubcategoryName -replace ' ', '' -replace '-', '' -replace '/', ''
                if ($CreateGPO["$($Category)"]) {
                    $CreateGPO["$($Category)"] = $SettingType["$($GPOEntry.SettingValue)"]
                }
            } else {
                # Category = 'SecuritySettings', Settings = 'Audit'
                $SuccessAttempts = try { [bool]::Parse($GPOEntry.SuccessAttempts) } catch { $null };
                $FailureAttempts = try { [bool]::Parse($GPOEntry.FailureAttempts) } catch { $null };
                if ($SuccessAttempts -and $FailureAttempts) {
                    $Setting = 'Success, Failure'
                } elseif ($SuccessAttempts) {
                    $Setting = 'Success'
                } elseif ($FailureAttempts) {
                    $Setting = 'Failure'
                } else {
                    $Setting = 'Not configured'
                }
                $CreateGPO["$($GPOEntry.Name)"] = $Setting
            }
        }
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    }
}