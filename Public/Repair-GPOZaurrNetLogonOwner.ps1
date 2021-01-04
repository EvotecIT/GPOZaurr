function Repair-GPOZaurrNetLogonOwner {
    <#
    .SYNOPSIS
    Sets new owner to each file in NetLogon share.

    .DESCRIPTION
    Sets new owner to each file in NetLogon share.

    .PARAMETER Forest
    Target different Forest, by default current forest is used

    .PARAMETER ExcludeDomains
    Exclude domain from search, by default whole forest is scanned

    .PARAMETER IncludeDomains
    Include only specific domains, by default whole forest is scanned

    .PARAMETER ExtendedForestInformation
    Ability to provide Forest Information from another command to speed up processing

    .PARAMETER Principal
    Provide named owner. If not provided default S-1-5-32-544 is used.

    .PARAMETER LimitProcessing
    Allows to specify maximum number of items that will be fixed in a single run. It doesn't affect amount of GPOs processed

    .EXAMPLE
    Repair-GPOZaurrNetLogonOwner -WhatIf -Verbose -IncludeDomains ad.evotec.pl

    .NOTES
    General notes
    #>
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,

        [string] $Principal = 'S-1-5-32-544',
        [int] $LimitProcessing = [int32]::MaxValue
    )
    $Identity = Convert-Identity -Identity $Principal -Verbose:$false
    if ($Identity.Error) {
        Write-Warning "Repair-GPOZaurrNetLogonOwner - couldn't convert Identity $Principal to desired name. Error: $($Identity.Error)"
        return
    }
    $Principal = $Identity.Name

    $getGPOZaurrNetLogonSplat = @{
        OwnerOnly                 = $true
        Forest                    = $Forest
        IncludeDomains            = $IncludeDomains
        ExcludeDomains            = $ExcludeDomains
        ExtendedForestInformation = $ExtendedForestInformation
    }

    Get-GPOZaurrNetLogon @getGPOZaurrNetLogonSplat -Verbose | Where-Object {
        if ($_.OwnerSid -ne 'S-1-5-32-544') {
            $_
        }
    } | Select-Object -First $LimitProcessing | ForEach-Object {
        if ($PSCmdlet.ShouldProcess($_.FullName, "Setting NetLogon Owner to $($Principal)")) {
            Set-FileOwner -JustPath -Path $_.FullName -Owner $Principal -Verbose:$true -WhatIf:$WhatIfPreference
        }
    }
}