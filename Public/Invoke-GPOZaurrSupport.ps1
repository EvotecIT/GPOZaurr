function Invoke-GPOZaurrSupport {
    <#
    .SYNOPSIS
    Invokes GPOZaurrSupport function to retrieve Group Policy information.

    .DESCRIPTION
    This function retrieves Group Policy information using either HTML, XML, or Object format. It can be run locally or on a remote computer.

    .PARAMETER Type
    Specifies the type of output format. Valid values are 'NativeHTML', 'HTML', 'XML', or 'Object'. Default is 'HTML'.

    .PARAMETER ComputerName
    Specifies the name of the remote computer to retrieve Group Policy information from.

    .PARAMETER UserName
    Specifies the username to run the function as on the remote computer.

    .PARAMETER Path
    Specifies the path to save the output file. If not provided, a temporary file will be created.

    .PARAMETER Splitter
    Specifies the delimiter for splitting output data. Default is a new line.

    .PARAMETER PreventShow
    Prevents displaying the output in the console.

    .PARAMETER Online
    Runs the function online to retrieve the latest Group Policy information.

    .EXAMPLE
    Invoke-GPOZaurrSupport -Type HTML -ComputerName "RemoteComputer" -UserName "Admin" -Path "C:\Temp\GPOReport.html"
    Retrieves Group Policy information in HTML format from a remote computer and saves it to a specified path.

    .EXAMPLE
    Invoke-GPOZaurrSupport -Type XML -Path "C:\Temp\GPOReport.xml" -Online
    Retrieves the latest Group Policy information in XML format and saves it to a specified path.

    #>
    [cmdletBinding()]
    param(
        [ValidateSet('NativeHTML', 'HTML', 'XML', 'Object')][string] $Type = 'HTML',
        [alias('Server')][string] $ComputerName,
        [alias('User')][string] $UserName,
        [string] $Path,
        [string] $Splitter = [System.Environment]::NewLine,
        [switch] $PreventShow,
        [switch] $Online
    )
    # if user didn't choose anything, lets run as currently logged in user locally
    if (-not $UserName -and -not $ComputerName) {
        $UserName = $Env:USERNAME
        # we can also check if the session is Administrative and if so request computer policies
        if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            $ComputerName = $Env:COMPUTERNAME
        }
    }
    If ($Type -eq 'HTML') {
        $Exists = Get-Command -Name 'New-HTML' -ErrorAction SilentlyContinue
        if (-not $Exists) {
            Write-Warning "Invoke-GPOZaurrSupport - PSWriteHTML module is required for HTML functionality. Use XML, Object or NativeHTML option instead."
            return
        }
    }
    $Command = Get-Command -Name 'Get-GPResultantSetOfPolicy' -ErrorAction SilentlyContinue
    $NativeCommand = Get-Command -Name 'gpresult' -ErrorAction SilentlyContinue
    if (-not $Command -and -not $NativeCommand) {
        Write-Warning "Invoke-GPOZaurrSupport - Neither gpresult or Get-GPResultantSetOfPolicy are available. Terminating."
        return
    }

    $SplatPolicy = @{}
    if ($Type -in 'Object', 'XML', 'HTML') {
        if ($Path) {
            $SplatPolicy['Path'] = $Path
        } else {
            $SplatPolicy['Path'] = [io.path]::GetTempFileName().Replace('.tmp', ".xml")
        }
        $SplatPolicy['ReportType'] = 'xml'
    } elseif ($Type -eq 'NativeHTML') {
        if ($Path) {
            $SplatPolicy['Path'] = $Path
        } else {
            $SplatPolicy['Path'] = [io.path]::GetTempFileName().Replace('.tmp', ".html")
        }
        $SplatPolicy['ReportType'] = 'html'
    }
    if ($ComputerName) {
        $SplatPolicy['Computer'] = $ComputerName
    }
    if ($UserName) {
        $SplatPolicy['User'] = $UserName
    }

    $SplatPolicy['TempXmlPath'] = [io.path]::GetTempFileName().Replace('.tmp', ".xml")
    # Originally planned to use Get-GPResultantSetOfPolicy but it only works with administrative rights
    # if ($Command -and -not $ForceGPResult) {
    #     try {
    #         Write-Verbose "Invoke-GPOZaurrSupport - ComputerName: $($SplatPolicy['Computer']), UserName: $($SplatPolicy['User']), ReportType: $($SplatPolicy['ReportType']), Path: $($SplatPolicy['Path'])"
    #         $ResultantSetPolicy = Get-GPResultantSetOfPolicy @SplatPolicy -ErrorAction Stop
    #     } catch {
    #         if ($_.Exception.Message -eq 'Exception from HRESULT: 0x80041003') {
    #             Write-Warning "Invoke-GPOZaurrSupport - Are you running as admin? $($_.Exception.Message)"
    #             return
    #         } else {
    #             $ErrorMessage = $($_.Exception.Message).Replace([Environment]::NewLine, ' ')
    #             Write-Warning "Invoke-GPOZaurrSupport - Error: $ErrorMessage"
    #             return
    #         }
    #     }
    # } else {
    $Arguments = @(
        if ($SplatPolicy['Computer']) {
            "/S $ComputerName"
        }
        if ($SplatPolicy['User']) {
            "/USER $($SplatPolicy['User'])"
        }
        if ($SplatPolicy['ReportType'] -eq 'HTML') {
            '/H'
            $SplatPolicy['Path']
        } elseif ($SplatPolicy['ReportType'] -eq 'XML') {
            '/X'
            $SplatPolicy['TempXmlPath']
        }
        "/F"
    )
    Write-Verbose "Invoke-GPOZaurrSupport - GPResult Arguments: $Arguments"
    Start-Process -NoNewWindow -FilePath 'gpresult' -ArgumentList $Arguments -Wait
    #}
    if ($Type -eq 'NativeHTML') {
        if (-not $PreventShow) {
            Write-Verbose "Invoke-GPOZaurrSupport - Opening up file $($SplatPolicy['Path'])"
            Start-Process -FilePath $SplatPolicy['Path']
        }
        return
    }
    # Loads created XML by resultant Output
    if ($SplatPolicy.TempXmlPath -and (Test-Path -LiteralPath $SplatPolicy.TempXmlPath)) {
        [xml] $PolicyContent = Get-Content -LiteralPath $SplatPolicy.TempXmlPath
        if ($PolicyContent) {
            # lets remove temporary XML file
            Remove-Item -LiteralPath $SplatPolicy.TempXmlPath
        } else {
            Write-Warning "Invoke-GPOZaurrSupport - Couldn't load XML file from drive $($SplatPolicy.TempXmlPath). Terminating."
            return
        }
    } else {
        Write-Warning "Invoke-GPOZaurrSupport - Couldn't find XML file on drive $($SplatPolicy.TempXmlPath). Terminating."
        return
    }
    if ($ComputerName) {
        if (-not $PolicyContent.Rsop.'ComputerResults'.EventsDetails) {
            Write-Warning "Invoke-GPOZaurrSupport - Windows Events for Group Policy are missing. Amount of data will be limited. Firewall issue?"
        }
    }
    if (-not $ComputerName) {
        # Ok, user haven't given computername, and we're not admin, so RSOP won't be there, but we will use $ComputerName further down to get additional data, even without administrative rights
        # Also for display purposes
        $ComputerName = $Env:COMPUTERNAME
    }

    if ($Type -eq 'XML') {
        $PolicyContent.Rsop
    } else {
        if ($VerbosePreference -ne 'SilentlyContinue') {
            $Verbose = $true
        } else {
            $Verbose = $false
        }
        $Output = [ordered] @{
            ComputerInformation = Get-Computer -ComputerName $ComputerName -Verbose:$Verbose
            #ResultantSetPolicy  = $ResultantSetPolicy

            <# ResultantSetPolicy  = $ResultantSetPolicy
            RunspaceId      : 5a4931ea-915e-42d3-80d8-6a86b16eb271
            RsopMode        : Logging
            Namespace       : \\EVOSPEED\Root\Rsop\NS103F4892_39E9_42B8_B0FF_E438EC0796B5
            LoggingComputer : EVOSPEED
            LoggingUser     : EVOTEC\przemyslaw.klys
            LoggingMode     : UserAndComputer
            #>
        }
        if ($PolicyContent.Rsop.ComputerResults) {
            $Output.ComputerResults = ConvertFrom-XMLRSOP -Content $PolicyContent.Rsop -ResultsType 'ComputerResults' -Splitter $Splitter
        }
        if ($PolicyContent.Rsop.UserResults) {
            $Output.UserResults = ConvertFrom-XMLRSOP -Content $PolicyContent.Rsop -ResultsType 'UserResults' -Splitter $Splitter
        }
        New-GPOZaurrReportConsole -Results $Output -ComputerName $ComputerName
        if ($Type -contains 'Object') {
            $Output
        } elseif ($Type -contains 'HTML') {
            New-GPOZaurrReportHTML -Path $Path -Online:$Online -Open:(-not $PreventShow) -Support $Output
        }
    }
}

<#


GPRESULT [/S system [/U username [/P [password]]]] [/SCOPE scope]
           [/USER targetusername] [/R | /V | /Z] [(/X | /H) <filename> [/F]]

Description:
    This command line tool displays the Resultant Set of Policy (RSoP)
    information for a target user and computer.

Parameter List:
    /S        system           Specifies the remote system to connect to.

    /U        [domain\]user    Specifies the user context under which the
                               command should run.
                               Can not be used with /X, /H.

    /P        [password]       Specifies the password for the given user
                               context. Prompts for input if omitted.
                               Cannot be used with /X, /H.

    /SCOPE    scope            Specifies whether the user or the
                               computer settings need to be displayed.
                               Valid values: "USER", "COMPUTER".

    /USER     [domain\]user    Specifies the user name for which the
                               RSoP data is to be displayed.

    /X        <filename>       Saves the report in XML format at the
                               location and with the file name specified
                               by the <filename> parameter. (valid in Windows
                               Vista SP1 and later and Windows Server 2008 and later)

    /H        <filename>       Saves the report in HTML format at the
                               location and with the file name specified by
                               the <filename> parameter. (valid in Windows
                               at least Vista SP1 and at least Windows Server 2008)

    /F                         Forces Gpresult to overwrite the file name
                               specified in the /X or /H command.

    /R                         Displays RSoP summary data.

    /V                         Specifies that verbose information should
                               be displayed. Verbose information provides
                               additional detailed settings that have
                               been applied with a precedence of 1.

    /Z                         Specifies that the super-verbose
                               information should be displayed. Super-
                               verbose information provides additional
                               detailed settings that have been applied
                               with a precedence of 1 and higher. This
                               allows you to see if a setting was set in
                               multiple places. See the Group Policy
                               online help topic for more information.

    /?                         Displays this help message.


Examples:
    GPRESULT /R
    GPRESULT /H GPReport.html
    GPRESULT /USER targetusername /V
    GPRESULT /S system /USER targetusername /SCOPE COMPUTER /Z
    GPRESULT /S system /U username /P password /SCOPE USER /V
#>