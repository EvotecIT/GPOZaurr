function Repair-GPOZaurrPermissionConsistency {
    [cmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    param(
        [Parameter(ParameterSetName = 'GPOName')][string] $GPOName,
        [Parameter(ParameterSetName = 'GPOGUID')][alias('GUID', 'GPOID')][string] $GPOGuid,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,

        [int] $LimitProcessing = [int32]::MaxValue
    )
    $ConsistencySplat = @{
        Forest                    = $Forest
        IncludeDomains            = $IncludeDomains
        ExcludeDomains            = $ExcludeDomains
        ExtendedForestInformation = $ExtendedForestInformation
        Verbose                   = $VerbosePreference
    }
    if ($GPOName) {
        $ConsistencySplat['GPOName'] = $GPOName
    } elseif ($GPOGuid) {
        $ConsistencySplat['GPOGuid'] = $GPOGUiD
    } else {
        $ConsistencySplat['Type'] = 'Inconsistent'
    }

    Get-GPOZaurrPermissionConsistency @ConsistencySplat -IncludeGPOObject | Where-Object {
        if ($_.ACLConsistent -eq $false) {
            $_
        }
    } | Select-Object -First $LimitProcessing | ForEach-Object {
        #Write-Verbose "Repair-GPOZaurrPermissionConsistency - Repairing GPO consistency $($_.DisplayName) from domain: $($_.DomainName)"
        if ($PSCmdlet.ShouldProcess($_.DisplayName, "Reparing GPO permissions consistency in domain $($_.DomainName)")) {
            try {
                $_.IncludeGPOObject.MakeAclConsistent()
            } catch {
                $ErrorMessage = $_.Exception.Message
                Write-Warning "Repair-GPOZaurrPermissionConsistency - Failed to set consistency: $($ErrorMessage)."
            }
        }
    }
}