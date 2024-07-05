function New-GPOZaurrWMI {
    <#
    .SYNOPSIS
    Creates a new Group Policy Object (GPO) based on a WMI filter query.

    .DESCRIPTION
    This function creates a new GPO in Active Directory based on a specified WMI filter query. It allows for customization of the GPO creation process by providing options to target specific forests, domains, and extended forest information.

    .PARAMETER Name
    The name of the new GPO to be created.

    .PARAMETER Description
    The description for the new GPO. Default is an empty string.

    .PARAMETER Namespace
    The WMI namespace to target. Default is 'root\CIMv2'.

    .PARAMETER Query
    The WMI filter query to be applied to the GPO.

    .PARAMETER SkipQueryCheck
    Switch to skip the query check before creating the GPO.

    .PARAMETER Force
    Switch to force the creation of the GPO without confirmation.

    .PARAMETER Forest
    The forest to target for GPO creation.

    .PARAMETER ExcludeDomains
    An array of domains to exclude from GPO application.

    .PARAMETER IncludeDomains
    An array of domains to include for GPO application.

    .PARAMETER ExtendedForestInformation
    Additional information about the forest for GPO customization.

    .EXAMPLE
    New-GPOZaurrWMI -Name "TestGPO" -Query "SELECT * FROM Win32_OperatingSystem" -Force
    Creates a new GPO named "TestGPO" with a WMI filter query targeting all Windows operating systems.

    .EXAMPLE
    New-GPOZaurrWMI -Name "FinanceGPO" -Query "SELECT * FROM Win32_Processor" -Forest "Contoso" -IncludeDomains "FinanceDomain"
    Creates a new GPO named "FinanceGPO" with a WMI filter query targeting all processors in the "FinanceDomain" within the "Contoso" forest.

    #>
    [cmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(Mandatory)][string] $Name,
        [string] $Description = ' ',
        [string] $Namespace = 'root\CIMv2',
        [parameter(Mandatory)][string] $Query,
        [switch] $SkipQueryCheck,
        [switch] $Force,

        [alias('ForestName')][string] $Forest,
        [string[]] $ExcludeDomains,
        [alias('Domain', 'Domains')][string[]] $IncludeDomains,
        [System.Collections.IDictionary] $ExtendedForestInformation
    )
    if (-not $Forest -and -not $ExcludeDomains -and -not $IncludeDomains -and -not $ExtendedForestInformation) {
        $IncludeDomains = $Env:USERDNSDOMAIN
    }

    if (-not $SkipQueryCheck) {
        try {
            $null = Get-CimInstance -Query $Query -ErrorAction Stop -Verbose:$false
        } catch {
            Write-Warning "New-GPOZaurrWMI - Query error $($_.Exception.Message). Terminating."
            return
        }
    }

    $ForestInformation = Get-WinADForestDetails -Forest $Forest -IncludeDomains $IncludeDomains -ExcludeDomains $ExcludeDomains -ExtendedForestInformation $ExtendedForestInformation
    foreach ($Domain in $ForestInformation.Domains) {
        $QueryServer = $ForestInformation['QueryServers'][$Domain]['HostName'][0]
        $DomainInformation = Get-ADDomain -Server $QueryServer
        $defaultNamingContext = $DomainInformation.DistinguishedName
        #$defaultNamingContext = (Get-ADRootDSE).defaultnamingcontext
        [string] $Author = (([ADSI]"LDAP://<SID=$([System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value)>").UserPrincipalName).ToString()
        [string] $GUID = "{" + ([System.Guid]::NewGuid()) + "}"

        [string] $DistinguishedName = -join ("CN=", $GUID, ",CN=SOM,CN=WMIPolicy,CN=System,", $defaultNamingContext)
        $CurrentTime = (Get-Date).ToUniversalTime()
        [string] $CurrentDate = -join (
            ($CurrentTime.Year).ToString("0000"),
            ($CurrentTime.Month).ToString("00"),
            ($CurrentTime.Day).ToString("00"),
            ($CurrentTime.Hour).ToString("00"),
            ($CurrentTime.Minute).ToString("00"),
            ($CurrentTime.Second).ToString("00"),
            ".",
            ($CurrentTime.Millisecond * 1000).ToString("000000"),
            "-000"
        )

        [Array] $ExistingWmiFilter = Get-GPOZaurrWMI -ExtendedForestInformation $ForestInformation -IncludeDomains $Domain -Name $Name
        if ($ExistingWmiFilter.Count -eq 0) {
            [string] $WMIParm2 = -join ("1;3;10;", $Query.Length.ToString(), ";WQL;$Namespace;", $Query , ";")
            $OtherAttributes = @{
                "msWMI-Name"             = $Name
                "msWMI-Parm1"            = $Description
                "msWMI-Parm2"            = $WMIParm2
                "msWMI-Author"           = $Author
                "msWMI-ID"               = $GUID
                "instanceType"           = 4
                "showInAdvancedViewOnly" = "TRUE"
                "distinguishedname"      = $DistinguishedName
                "msWMI-ChangeDate"       = $CurrentDate
                "msWMI-CreationDate"     = $CurrentDate
            }
            $WMIPath = -join ("CN=SOM,CN=WMIPolicy,CN=System,", $defaultNamingContext)

            try {
                Write-Verbose "New-GPOZaurrWMI - Creating WMI filter $Name in $Domain"
                New-ADObject -Name $GUID -Type "msWMI-Som" -Path $WMIPath -OtherAttributes $OtherAttributes -Server $QueryServer
            } catch {
                Write-Warning "New-GPOZaurrWMI - Creating GPO filter error $($_.Exception.Message). Terminating."
                return
            }
        } else {
            foreach ($_ in $ExistingWmiFilter) {
                Write-Warning "New-GPOZaurrWMI - Skipping creation of GPO because name: $($_.DisplayName) guid: $($_.ID) for $($_.DomainName) already exists."
            }
        }
    }
}