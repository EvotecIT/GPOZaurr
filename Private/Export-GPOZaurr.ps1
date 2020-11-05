function Export-GPOZaurr {
    [cmdletBinding()]
    param(

    )
    $Output = [ordered] @{}
    foreach ($T in $Script:GPOConfiguration.Keys) {
        if ($Script:GPOConfiguration[$T].Enabled -eq $true) {
            $Output[$T] = [ordered]@{
                Action    = $Script:GPOConfiguration[$T].Action
                Data      = $Script:GPOConfiguration[$T].Data
                Summary   = $Script:GPOConfiguration[$T].Summary
                Variables = $Script:GPOConfiguration[$T].Variables
            }
        }
    }
    $Output
}