---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Get-GPOZaurrLegacyFiles
## SYNOPSIS
Retrieves legacy Group Policy Object (GPO) files from the SYSVOL directory of specified domains within a forest.

## SYNTAX
### __AllParameterSets
```powershell
Get-GPOZaurrLegacyFiles [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-IncludeDomains] <string[]>] [[-ExtendedForestInformation] <IDictionary>] [<CommonParameters>]
```

## DESCRIPTION
The Get-GPOZaurrLegacyFiles function retrieves legacy GPO files, such as '*.adm' and 'admfiles.ini', from the SYSVOL directory of specified domains within a forest. It provides detailed information about these files including their name, full path, creation time, last write time, attributes, associated domain name, and directory name.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Get-GPOZaurrLegacyFiles -Forest "contoso.com" -IncludeDomains "domain1", "domain2" -ExcludeDomains "domain3" -ExtendedForestInformation $additionalInfo
```

Retrieves legacy GPO files from the "contoso.com" forest for "domain1" and "domain2" domains while excluding "domain3", using additional forest information.

## PARAMETERS

### -ExcludeDomains
Specifies an array of domain names to exclude from the search for legacy GPO files.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedForestInformation
Specifies additional information about the forest to enhance the retrieval process.

```yaml
Type: IDictionary
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Forest
Specifies the name of the forest from which to retrieve legacy GPO files.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: ForestName
Possible values:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomains
Specifies an array of domain names to include in the search for legacy GPO files.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: Domain, Domains
Possible values:

Required: False
Position: 2
Default value: None
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
