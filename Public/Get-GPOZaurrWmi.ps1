function Get-GPOZaurrWMI {
    <#
    .SYNOPSIS
    Get Group Policy WMI filter

    .DESCRIPTION
    Get Group Policy WMI filter

    .PARAMETER Guid
    Search for specific filter using GUID

    .PARAMETER Name
    Search for specific filter using Name

    .PARAMETER Forest
    Target different Forest, by default current forest is used

    .PARAMETER ExcludeDomains
    Exclude domain from search, by default whole forest is scanned

    .PARAMETER IncludeDomains
    Include only specific domains, by default whole forest is scanned

    .PARAMETER ExtendedForestInformation
    Ability to provide Forest Information from another command to speed up processing

    .PARAMETER AsHashtable
    Return output as hashtable

    .EXAMPLE
    Get-GPOZaurrWMI -AsHashtable

    .EXAMPLE
    Get-GPOZaurrWMI | Format-Table

    .NOTES
    General notes
    #>
    [cmdletBinding()]
    Param(
        [Guid[]] $Guid,
        [string[]] $Name,
        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation,
        [switch] $AsHashtable
    )
    $Dictionary = [ordered] @{}
    $wmiFilterAttr = 'msWMI-Name', 'msWMI-Parm1', 'msWMI-Parm2', 'msWMI-Author', 'msWMI-ID', 'CanonicalName', 'Created', 'Modified'
    $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    foreach ($Domain in $ForestInformation.Domains) {
        $QueryServer = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
        $Objects = @(
            if ($Name) {
                foreach ($N in $Name) {
                    try {
                        $ldapFilter = "(&(objectClass=msWMI-Som)(msWMI-Name=$N))"
                        Get-ADObject -LDAPFilter $ldapFilter -Properties $wmiFilterAttr -Server $QueryServer
                    } catch {
                        Write-Warning "Get-GPOZaurrWMI - Error processing WMI for $Domain`: $($_.Error.Exception)"
                    }
                }
            } elseif ($GUID) {
                foreach ($G in $GUID) {
                    try {
                        $ldapFilter = "(&(objectClass=msWMI-Som)(Name={$G}))"
                        Get-ADObject -LDAPFilter $ldapFilter -Properties $wmiFilterAttr -Server $QueryServer
                    } catch {
                        Write-Warning "Get-GPOZaurrWMI - Error processing WMI for $Domain`: $($_.Error.Exception)"
                    }
                }
            } else {
                try {
                    $ldapFilter = '(objectClass=msWMI-Som)'
                    Get-ADObject -LDAPFilter $ldapFilter -Properties $wmiFilterAttr -Server $QueryServer
                } catch {
                    Write-Warning "Get-GPOZaurrWMI - Error processing WMI for $Domain`: $($_.Error.Exception)"
                }
            }
        )
        foreach ($_ in $Objects) {
            $WMI = $_.'msWMI-Parm2' -split ';' #$WMI = $_.'msWMI-Parm2'.Split(';',8)
            [Array] $Data = for ($i = 0; $i -lt $WMI.length; $i += 6) {
                if ($WMI[$i + 5]) {
                    #[PSCustomObject] @{
                    #    NameSpace = $WMI[$i + 5]
                    #    Query     = $WMI[$i + 6]
                    #}
                    -join ($WMI[$i + 5], ';' , $WMI[$i + 6])
                }
            }
            $WMIObject = [PSCustomObject] @{
                DisplayName       = $_.'msWMI-Name'
                Description       = $_.'msWMI-Parm1'
                DomainName        = $Domain
                #NameSpace         = $WMI[$i + 5]
                #Query             = $WMI[$i + 6]
                QueryCount        = $Data.Count
                Query             = $Data -join ','
                Author            = $_.'msWMI-Author'
                ID                = $_.'msWMI-ID'
                Created           = $_.Created
                Modified          = $_.Modified
                ObjectGUID        = $_.'ObjectGUID'
                CanonicalName     = $_.CanonicalName
                DistinguishedName = $_.'DistinguishedName'
            }
            if (-not $AsHashtable) {
                $WMIObject
            } else {
                $Dictionary[$WMIObject.ID] = $WMIObject
            }
        }

    }
    if ($AsHashtable) {
        $Dictionary
    }
}
<#
CanonicalName                   : ad.evotec.xyz/System/WMIPolicy/SOM/{E988C890-BDBC-4946-87B5-BF70F39F4686}
CN                              : {E988C890-BDBC-4946-87B5-BF70F39F4686}
Created                         : 08.04.2020 19:04:06
createTimeStamp                 : 08.04.2020 19:04:06
Deleted                         :
Description                     :
DisplayName                     :
DistinguishedName               : CN={E988C890-BDBC-4946-87B5-BF70F39F4686},CN=SOM,CN=WMIPolicy,CN=System,DC=ad,DC=evotec,DC=xyz
dSCorePropagationData           : {01.01.1601 01:00:00}
instanceType                    : 4
isDeleted                       :
LastKnownParent                 :
Modified                        : 08.04.2020 19:04:06
modifyTimeStamp                 : 08.04.2020 19:04:06
msWMI-Author                    : przemyslaw.klys@evotec.pl
msWMI-ChangeDate                : 20200408170406.280000-000
msWMI-CreationDate              : 20200408170406.280000-000
msWMI-ID                        : {E988C890-BDBC-4946-87B5-BF70F39F4686}
msWMI-Name                      : Virtual Machines
msWMI-Parm1                     : Oh my description
msWMI-Parm2                     : 1;3;10;66;WQL;root\CIMv2;SELECT * FROM Win32_ComputerSystem WHERE Model = "Virtual Machine";
Name                            : {E988C890-BDBC-4946-87B5-BF70F39F4686}
nTSecurityDescriptor            : System.DirectoryServices.ActiveDirectorySecurity
ObjectCategory                  : CN=ms-WMI-Som,CN=Schema,CN=Configuration,DC=ad,DC=evotec,DC=xyz
ObjectClass                     : msWMI-Som
ObjectGUID                      : c1ee708d-7a67-46e2-b13f-d11a573d2597
ProtectedFromAccidentalDeletion : False
sDRightsEffective               : 15
showInAdvancedViewOnly          : True
uSNChanged                      : 12785589
uSNCreated                      : 12785589
whenChanged                     : 08.04.2020 19:04:06
whenCreated                     : 08.04.2020 19:04:06
#>