function Export-GPOZaurrContent {
    <#
    .SYNOPSIS
    Saves GPOs to XML or HTML files.

    .DESCRIPTION
    Saves GPOs to XML or HTML files.

    .PARAMETER FolderOutput
    The folder where the GPOs will be saved.

    .PARAMETER ReportType
    The type of report to generate. Valid values are XML or HTML. Default is XML.

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][alias('Path')][string] $FolderOutput,
        [ValidateSet('XML', 'HTML')][string] $ReportType = 'XML'
    )
    if ($FolderOutput) {
        if (-not (Test-Path -LiteralPath $FolderOutput)) {
            $null = New-Item -Path $FolderOutput -ItemType Directory -Force
        }
        $Forest = Get-ADForest
        $Count = 0
        foreach ($Domain in $Forest.Domains) {
            $GPOs = Get-GPO -All -Domain $Domain
            foreach ($GPO in $GPOS) {
                $Count++
                Write-Verbose -Message "Export-GPOZaurr - Exporting ($Count / $($GPOs.Count)) - $($GPO.DisplayName) to $ReportType"
                $Name = "$($GPO.DomainName)_$($GPO.Id)_$($GPO.DisplayName).xml".Replace(" ", "_").Replace("|", "_")
                $FullName = [io.path]::Combine($GPOOutput, $Name)
                Get-GPOReport -Guid $GPO.Id -Domain $GPO.DomainName -ReportType $ReportType -Path $FullName
            }
        }
    }
}