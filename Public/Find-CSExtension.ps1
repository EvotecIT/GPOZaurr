function Find-CSExtension {
    [cmdletBinding()]
    param(
        [string] $CSE
    )

    #List Group Policy Client Side Extensions, CSEs, from Windows 10
    $Keys = Get-PSRegistry -RegistryPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\GPExtensions" -ComputerName AD3
    foreach ($Key in $Keys.PSSubKeys) {
        $Value = (Get-PSRegistry -RegistryPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\GPExtensions\$Key" -ComputerName AD3).DefaultKey

        if (-not $GUIDs[$Key]) {
            "$Key $Value"
        }
    }
}