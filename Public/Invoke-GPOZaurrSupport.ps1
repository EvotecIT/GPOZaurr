function Invoke-GPOZaurrSupport {
    [cmdletBinding()]
    param(
        [ValidateSet('NativeHTML', 'HTML', 'XML', 'Object')][string] $Type = 'HTML',
        [alias('Server')][string] $ComputerName,
        [alias('User')][string] $UserName,
        [string] $Path,
        [string] $Splitter = [System.Environment]::NewLine,
        [switch] $PreventShow,
        [switch] $Offline,
        [switch] $ForceGPResult
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
    if ($Command -and -not $ForceGPResult) {
        try {
            #Write-Verbose "Request-GPOZaurr - ComputerName: $($SplatPolicy['Computer']) UserName: $($SplatPolicy['User'])"
            $ResultantSetPolicy = Get-GPResultantSetOfPolicy @SplatPolicy -ErrorAction Stop
        } catch {
            if ($_.Exception.Message -eq 'Exception from HRESULT: 0x80041003') {
                Write-Warning "Request-GPOZaurr - Are you running as admin? $($_.Exception.Message)"
                return
            } else {
                $ErrorMessage = $($_.Exception.Message).Replace([Environment]::NewLine, ' ')
                Write-Warning "Request-GPOZaurr - Error: $ErrorMessage"
                return
            }
        }
    } else {
        $Arguments = @(
            if ($SplatPolicy['Computer']) {
                "/S $ComputerName"
            }
            if ($SplatPolicy['User']) {
                "/USER $($SplatPolicy['User'])"
            }
            if ($SplatPolicy['ReportType'] -eq 'HTML') {
                '/H'
            } elseif ($SplatPolicy['ReportType'] -eq 'XML') {
                '/X'
            }
            $SplatPolicy['Path']
            "/F"
        )
        Write-Verbose "Invoke-GPOZaurrSupport - GPResult Arguments: $Arguments"
        Start-Process -NoNewWindow -FilePath 'gpresult' -ArgumentList $Arguments -Wait
    }
    if ($Type -eq 'NativeHTML') {
        if (-not $PreventShow) {
            Write-Verbose "Invoke-GPOZaurrSupport - Opening up file $($SplatPolicy['Path'])"
            Start-Process -FilePath $SplatPolicy['Path']
        }
        return
    }
    # Loads created XML by resultant Output
    if ($SplatPolicy.Path -and (Test-Path -LiteralPath $SplatPolicy.Path)) {
        [xml] $PolicyContent = Get-Content -LiteralPath $SplatPolicy.Path
        if ($PolicyContent) {
            # lets remove temporary XML file
            Remove-Item -LiteralPath $SplatPolicy.Path
        } else {
            Write-Warning "Request-GPOZaurr - Couldn't load XML file from drive $($SplatPolicy.Path). Terminating."
            return
        }
    } else {
        Write-Warning "Request-GPOZaurr - Couldn't find XML file on drive $($SplatPolicy.Path). Terminating."
        return
    }
    if ($ComputerName) {
        if (-not $PolicyContent.Rsop.'ComputerResults'.EventsDetails) {
            Write-Warning "Request-GPOZaurr - Windows Events for Group Policy are missing. Amount of data will be limited. Firewall issue?"
        }
    }
    if ($Type -eq 'XML') {
        $PolicyContent.Rsop
    } else {
        $Output = [ordered] @{
            ResultantSetPolicy = $ResultantSetPolicy
        }
        if ($PolicyContent.Rsop.ComputerResults) {
            $Output.ComputerResults = ConvertFrom-XMLRSOP -Content $PolicyContent.Rsop -ResultantSetPolicy $ResultantSetPolicy -ResultsType 'ComputerResults' -Splitter $Splitter
        }
        if ($PolicyContent.Rsop.UserResults) {
            $Output.UserResults = ConvertFrom-XMLRSOP -Content $PolicyContent.Rsop -ResultantSetPolicy $ResultantSetPolicy -ResultsType 'UserResults' -Splitter $Splitter
        }

        New-GPOZaurrReportConsole -Results $Output
        if ($Type -contains 'Object') {
            $Output
        } elseif ($Type -contains 'HTML') {
            New-GPOZaurrReportHTML -Path $Path -Offline:$Offline -Open:(-not $PreventShow) -Support $Output
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