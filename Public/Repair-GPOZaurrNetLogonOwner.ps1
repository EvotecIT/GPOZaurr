function Repair-GPOZaurrNetLogonOwner {
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
    Get-GPOZaurrNetLogon -OwnerOnly | Select-Object -First $LimitProcessing | Where-Object {
        if ($_.OwnerSid -ne 'S-1-5-32-544') {
            $_
        }
    } | ForEach-Object {
        if ($PSCmdlet.ShouldProcess($_.FullName, "Setting NetLogon Owner to $($Principal)")) {
            Set-FileOwner -JustPath -Path $_.FullName -Owner $Principal -Verbose:$true -WhatIf:$WhatIfPreference
        }
    }
}