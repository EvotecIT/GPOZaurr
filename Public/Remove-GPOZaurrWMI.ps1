function Remove-GPOZaurrWMI {
    <#
    .SYNOPSIS
    Removes Group Policy Objects (GPO) based on specified criteria.

    .DESCRIPTION
    This function removes GPOs based on the provided GUIDs or names within the specified forest or domains. It retrieves WMI filters associated with the GPOs and removes them.

    .PARAMETER Guid
    Specifies an array of GUIDs of the GPOs to be removed.

    .PARAMETER Name
    Specifies an array of names of the GPOs to be removed.

    .PARAMETER Forest
    Specifies the forest name where the GPOs are located.

    .PARAMETER ExcludeDomains
    Specifies an array of domains to exclude from the removal process.

    .PARAMETER IncludeDomains
    Specifies an array of domains to include in the removal process.

    .PARAMETER ExtendedForestInformation
    Specifies additional information about the forest.

    .EXAMPLE
    Remove-GPOZaurrWMI -Guid "12345678-1234-1234-1234-123456789012"

    Description
    -----------
    Removes the GPO with the specified GUID.

    .EXAMPLE
    Remove-GPOZaurrWMI -Name "TestGPO"

    Description
    -----------
    Removes the GPO with the specified name.

    #>
    [CmdletBinding(SupportsShouldProcess)]
    Param (
        [Guid[]] $Guid,
        [string[]] $Name,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    if (-not $Forest -and -not $ExcludeDomains -and -not $IncludeDomains -and -not $ExtendedForestInformation) {
        $IncludeDomains = $Env:USERDNSDOMAIN
    }
    $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    foreach ($Domain in $ForestInformation.Domains) {
        $QueryServer = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
        [Array] $Objects = @(
            if ($Guid) {
                Get-GPOZaurrWMI -Guid $Guid -ExtendedForestInformation $ForestInformation -IncludeDomains $Domain
            }
            if ($Name) {
                Get-GPOZaurrWMI -Name $Name -ExtendedForestInformation $ForestInformation -IncludeDomains $Domain
            }
        )
        $Objects | ForEach-Object -Process {
            if ($_.DistinguishedName) {
                Write-Verbose "Remove-GPOZaurrWMI - Removing WMI Filter $($_.DistinguishedName)"
                Remove-ADObject $_.DistinguishedName -Confirm:$false -Server $QueryServer
            }
        }
    }
}