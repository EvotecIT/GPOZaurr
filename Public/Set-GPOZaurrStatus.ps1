function Set-GPOZaurrStatus {
    <#
    .SYNOPSIS
    Enables or disables user/computer section of Group Policy.

    .DESCRIPTION
    Enables or disables user/computer section of Group Policy.

    .PARAMETER GPOName
    Provide Group Policy Name

    .PARAMETER GPOGuid
    Provide Group Policy GUID

    .PARAMETER Status
    Choose a status for provided Group Policy

    .PARAMETER Forest
    Choose forest to target.

    .PARAMETER ExcludeDomains
    Exclude domains from trying to find Group Policy Name or GUID

    .PARAMETER IncludeDomains
    Include domain (one or more) to find Group Policy Name or GUID

    .PARAMETER ExtendedForestInformation
    Provide Extended Forest Information

    .EXAMPLE
    Set-GPOZaurrStatus -Name 'TEST | Empty GPO - AD.EVOTEC.PL CrossDomain GPO' -Status AllSettingsEnabled -Verbose

    .EXAMPLE
    Set-GPOZaurrStatus -Name 'TEST | Empty GPO - AD.EVOTEC.PL CrossDomain GPO' -DomainName ad.evotec.pl -Status AllSettingsEnabled -Verbose

    .NOTES
    General notes
    #>
    [cmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'GPOName')]
    param(
        [alias('Name', 'DisplayName')][Parameter(ParameterSetName = 'GPOName', Mandatory)][string] $GPOName,
        [Parameter(ParameterSetName = 'GPOGUID', Mandatory)][alias('GUID', 'GPOID')][string] $GPOGuid,
        [Parameter(Mandatory)][Microsoft.GroupPolicy.GpoStatus] $Status,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains', 'DomainName')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    Begin {

    }
    Process {
        $getGPOZaurrSplat = @{
            Forest                    = $Forest
            IncludeDomains            = $IncludeDomains
            ExcludeDomains            = $ExcludeDomains
            ExtendedForestInformation = $ExtendedForestInformation
            GpoName                   = $GPOName
            GPOGUID                   = $GPOGuid
        }
        Remove-EmptyValue -Hashtable $getGPOZaurrSplat
        Get-GPOZaurr @getGPOZaurrSplat | ForEach-Object {
            $GPO = $_

            if ($Status -eq [Microsoft.GroupPolicy.GpoStatus]::AllSettingsEnabled) {
                $Text = "Enabling computer and user settings in domain $($GPO.DomainName)"
            } elseif ($Status -eq [Microsoft.GroupPolicy.GpoStatus]::ComputerSettingsDisabled) {
                $Text = "Disabling computer setings in domain $($GPO.DomainName)"
            } elseif ($Status -eq [Microsoft.GroupPolicy.GpoStatus]::UserSettingsDisabled) {
                $Text = "Disabling user setings in domain $($GPO.DomainName)"
            } else {
                $Text = "Disabling computer user settings in domain $($GPO.DomainName)"
            }
            if ($PSCmdlet.ShouldProcess($GPO.DisplayName, $Text)) {
                try {
                    $GPO.GPOObject.GpoStatus = $Status
                } catch {
                    Write-Warning -Message "Set-GPOZaurrStatus - Couldn't set $($GPO.DisplayName) / $($GPO.DomainName) to $Status. Error $($_.Exception.Message)"
                }
            }
        }
    }
}