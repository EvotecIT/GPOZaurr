function Get-GPOZaurrTemplates {
    [CmdletBinding()]
    param(

    )


    $SysvolADMXPath = "\\$env:USERDNSDOMAIN\SYSVOL\$env:USERDNSDOMAIN\Policies\PolicyDefinitions"
    Get-ChildItem -Path $SysvolADMXPath -Filter "*.admx" -Recurse -File | ForEach-Object {
        [PSCustomObject]@{
            Name          = $_.Name
            Path          = $_.FullName
            Size          = $_.Length
            LastWriteTime = $_.LastWriteTime
        }
    }
}