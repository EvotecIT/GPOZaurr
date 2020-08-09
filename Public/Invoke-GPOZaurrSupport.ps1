function Invoke-GPOZaurrSupport {
    [cmdletBinding()]
    param(
        [ValidateSet('XML', 'Object')][string] $Type = 'Object',
        [alias('Server')][string] $ComputerName,
        [alias('User')][string] $UserName,
        [string] $Path,
        [string] $Splitter = [System.Environment]::NewLine
    )

    $SplatPolicy = @{
        ReportType = 'xml'
        Path       = [io.path]::GetTempFileName().Replace('.tmp', ".xml")
    }
    if ($PSBoundParameters.ContainsKey('ComputerName')) {
        $SplatPolicy['Computer'] = $ComputerName
    }
    if ($PSBoundParameters.ContainsKey('UserName')) {
        $SplatPolicy['User'] = $UserName
    }
    try {
        $ResultantSetPolicy = Get-GPResultantSetOfPolicy @SplatPolicy
    } catch {
        if ($_.Exception.Message -eq 'Exception from HRESULT: 0x80041003') {
            Write-Warning "Request-GPOZaurr - Are you running as admin? $($_.Exception.Message)"
        } else {
            Write-Warning "Request-GPOZaurr - Error: $($_.Exception.Message)"
        }
    }
    if (-not $ComputerName) {
        # ComputerName is not set, lets use local
        $ComputerName = $Env:COMPUTERNAME
    }
    # Loads created XML by resultant Output
    [xml] $PolicyContent = Get-Content -LiteralPath $SplatPolicy.Path
    if ($PolicyContent -and (Test-Path -LiteralPath $SplatPolicy.Path)) {
        # lets remove temporary XML file
        Remove-Item -LiteralPath $SplatPolicy.Path
    }
    if ($Type -eq 'XML') {
        $PolicyContent.Rsop
    } else {
        $Output = [ordered] @{
            ResultantSetPolicy = $ResultantSetPolicy
        }
        if ($PolicyContent.Rsop.ComputerResults) {
            $Output.ComputerResults = ConvertFrom-XMLRSOP -Content $PolicyContent.Rsop -ComputerName $ComputerName -ResultantSetPolicy $ResultantSetPolicy -ResultsType 'ComputerResults' -Splitter $Splitter
        }
        if ($PolicyContent.Rsop.UserResults) {
            $Output.UserResults = ConvertFrom-XMLRSOP -Content $PolicyContent.Rsop -ComputerName $ComputerName -ResultantSetPolicy $ResultantSetPolicy -ResultsType 'UserResults' -Splitter $Splitter
        }
        $Output
    }
}