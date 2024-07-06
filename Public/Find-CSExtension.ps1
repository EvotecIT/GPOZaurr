function Find-CSExtension {
    <#
    .SYNOPSIS
    This function retrieves Group Policy Client Side Extensions (CSEs) from a specified Windows computer.

    .DESCRIPTION
    The Find-CSExtension function lists Group Policy Client Side Extensions (CSEs) configured on a Windows computer. It queries the Windows Registry to retrieve information about the CSEs.

    .PARAMETER CSE
    Specifies an array of CSE names to filter the results. If not provided, all CSEs will be listed.

    .PARAMETER ComputerName
    Specifies the name of the computer from which to retrieve the CSE information.

    .EXAMPLE
    Find-CSExtension -ComputerName "Computer01"
    Retrieves all CSEs configured on the computer named "Computer01".

    .EXAMPLE
    Find-CSExtension -CSE "CSE1", "CSE2" -ComputerName "Computer02"
    Retrieves information about CSEs named "CSE1" and "CSE2" on the computer named "Computer02".
    #>
    [cmdletBinding()]
    param(
        [string[]] $CSE,
        [string] $ComputerName
    )
    #List Group Policy Client Side Extensions, CSEs, from Windows 10
    $Keys = Get-PSRegistry -RegistryPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\GPExtensions" -ComputerName $ComputerName
    foreach ($Key in $Keys.PSSubKeys) {
        $RegistryKey = Get-PSRegistry -RegistryPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\GPExtensions\$Key" -ComputerName $ComputerName
        if ($CSE) {
            foreach ($C in $CSE) {
                if ($RegistryKey.DefaultKey -eq $Key) {
                    [PSCustomObject] @{ Name = $Key; Description = $RegistryKey.DefaultKey }
                }
            }
        } else {
            [PSCustomObject] @{ CSE = $Key; Description = $RegistryKey.DefaultKey }
        }
    }
}