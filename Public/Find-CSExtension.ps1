function Find-CSExtension {
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