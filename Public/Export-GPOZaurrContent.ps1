function Export-GPOZaurrContent {
    <#
    .SYNOPSIS
    Exports Group Policy Objects (GPOs) to XML or HTML files.

    .DESCRIPTION
    This function exports GPOs to either XML or HTML files based on the specified parameters.

    .PARAMETER FolderOutput
    Specifies the folder path where the exported GPO files will be saved.

    .PARAMETER ReportType
    Specifies the type of report to generate. Valid values are XML or HTML. The default value is XML.

    .EXAMPLE
    Export-GPOZaurrContent -FolderOutput "C:\ExportedGPOs" -ReportType HTML
    Exports all GPOs to HTML format and saves them in the "C:\ExportedGPOs" folder.

    .NOTES
    This function exports GPOs to XML or HTML files for further analysis or backup purposes.
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