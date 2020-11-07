function Get-GPOZaurrPassword {
    <#
    .SYNOPSIS
    Tries to find CPassword in Group Policies or given path and translate it to readable value

    .DESCRIPTION
    Tries to find CPassword in Group Policies or given path and translate it to readable value

    .PARAMETER Forest
    Specify forest name. By default current forest is used

    .PARAMETER ExcludeDomains
    Exclude Domain or Domains

    .PARAMETER IncludeDomains
    Include only certain Domain or Domains

    .PARAMETER ExtendedForestInformation
    Ability to provide extended forest information in advanced scenarios

    .PARAMETER GPOPath
    Path where Group Policy content is located or where backup is located

    .EXAMPLE
    Get-GPOZaurrPassword -GPOPath 'C:\Users\przemyslaw.klys\Desktop\GPOExport_2020.10.12'

    .EXAMPLE
    Get-GPOZaurrPassword

    .NOTES
    General notes
    #>
    [cmdletBinding()]
    param(
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [string[]] $GPOPath
    )
    if ($GPOPath) {
        foreach ($Path in $GPOPath) {
            $Items = Get-ChildItem -LiteralPath $Path -Recurse -Filter *.xml -ErrorAction SilentlyContinue -ErrorVariable err
            $Output = foreach ($XMLFileName in $Items) {
                $Password = Find-GPOPassword -Path $XMLFileName.FullName
                if ($Password) {
                    if ($XMLFileName.FullName -match '{\w{8}-\w{4}-\w{4}-\w{4}-\w{12}}') {
                        $GPOGUID = $matches[0]
                    }
                    [PSCustomObject] @{
                        RootPath     = $Path
                        PasswordFile = $XMLFileName.FullName
                        GUID         = $GPOGUID
                        Password     = $Password
                    }
                }
            }
        }
    } else {
        $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
        foreach ($Domain in $ForestInformation.Domains) {
            $Path = -join ('\\', $Domain, '\SYSVOL\', $Domain, '\Policies')
            #Extract the all XML files in the Folder
            $Items = Get-ChildItem -LiteralPath $Path -Recurse -Filter *.xml -ErrorAction SilentlyContinue -ErrorVariable err
            $Output = foreach ($XMLFileName in $Items) {
                $Password = Find-GPOPassword -Path $XMLFileName.FullName
                if ($Password) {
                    # match regex
                    if ($XMLFileName.FullName -match '{\w{8}-\w{4}-\w{4}-\w{4}-\w{12}}') {
                        $GPOGUID = $matches[0]
                        $GPO = Get-GPOZaurrAD -GPOGuid $GPOGUID -IncludeDomains $Domain
                        [PSCustomObject] @{
                            DisplayName  = $GPO.DisplayName
                            DomainName   = $GPO.DomainName
                            GUID         = $GPO.GUID
                            PasswordFile = $XMLFileName.FullName
                            Password     = $Password
                            Created      = $GPO.Created
                            Modified     = $GPO.Modified
                            Description  = $GPO.Description
                        }
                    } else {
                        [PSCustomObject] @{
                            DisplayName  = ''
                            DomainName   = ''
                            GUID         = ''
                            PasswordFile = $XMLFileName.FullName
                            Password     = $Password
                            Created      = ''
                            Modified     = ''
                            Description  = ''
                        }
                    }
                }
            }
            foreach ($e in $err) {
                Write-Warning "Get-GPOZaurrPassword - $($e.Exception.Message) ($($e.CategoryInfo.Reason))"
            }
            $Output
        }
    }
}