function ConvertTo-XMLAudit {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [switch] $FullObject
    )
    $SettingType = @{
        '0' = 'No Auditing'
        '1' = 'Success'
        '2' = 'Failure'
        '3' = 'Success, Failure'
    }
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