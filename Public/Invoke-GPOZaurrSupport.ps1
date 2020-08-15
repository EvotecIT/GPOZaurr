function Invoke-GPOZaurrSupport {
    [cmdletBinding()]
    param(
        [ValidateSet('NativeHTML', 'HTML', 'XML', 'Object')][string] $Type = 'HTML',
        [alias('Server')][string] $ComputerName,
        [alias('User')][string] $UserName,
        [string] $Path,
        [string] $Splitter = [System.Environment]::NewLine,
        [switch] $PreventShow,
        [switch] $Offline
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
            Write-Warning "Request-GPOZaurr - PSWriteHTML module is required for HTML functionality. Use XML, Object or NativeHTML option instead."
            return
        }
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
    if ($Type -eq 'NativeHTML') {
        if (-not $PreventShow) {
            Write-Verbose "Invoke-GPOZaurrSupport - Opening up file $SplatPolicy['Path']"
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