---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Export-GPOZaurrContent
## SYNOPSIS
Exports Group Policy Objects (GPOs) to XML or HTML files.

## SYNTAX
### __AllParameterSets
```powershell
Export-GPOZaurrContent [-FolderOutput] <string> [[-ReportType] <string>] [<CommonParameters>]
```

## DESCRIPTION
This function exports GPOs to either XML or HTML files based on the specified parameters.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Export-GPOZaurrContent -FolderOutput "C:\ExportedGPOs" -ReportType HTML
Exports all GPOs to HTML format and saves them in the "C:\ExportedGPOs" folder.
```


## PARAMETERS

### -FolderOutput
Specifies the folder path where the exported GPO files will be saved.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: Path
Possible values:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportType
Specifies the type of report to generate. Valid values are XML or HTML. The default value is XML.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values: XML, HTML

Required: False
Position: 1
Default value: XML
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

- `None`

## OUTPUTS

- `None`

## RELATED LINKS

- None
