---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Get-GPOZaurrMissingFiles
## SYNOPSIS
Retrieves information about missing files in Group Policy Objects (GPOs) within a specified forest.

## SYNTAX
### __AllParameterSets
```powershell
Get-GPOZaurrMissingFiles [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-IncludeDomains] <string[]>] [[-ExtendedForestInformation] <IDictionary>] [[-GPOName] <string[]>] [[-GPOGUID] <string[]>] [-BrokenOnly] [<CommonParameters>]
```

## DESCRIPTION
This function queries Active Directory for GPOs and checks for missing files within them. It provides detailed information about any errors found.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Get-GPOZaurrMissingFiles -Forest "example.com" -IncludeDomains "domain1", "domain2" -ExcludeDomains "domain3" -GPOName "GPO1"
```

Retrieves information about missing files in the GPO named "GPO1" within the "example.com" forest, including only domains "domain1" and "domain2" while excluding "domain3".

### EXAMPLE 2
```powershell
PS > Get-GPOZaurrMissingFiles -Forest "example.com" -IncludeDomains "domain1", "domain2" -GPOGUID "12345678-1234-1234-1234-1234567890AB" -BrokenOnly
```

Retrieves information about GPOs with missing files in the "example.com" forest, including only domains "domain1" and "domain2" for the GPO with the specified GUID, displaying only GPOs with missing files.

## PARAMETERS

### -BrokenOnly
Indicates whether to only display GPOs with missing files.

```yaml
Type: SwitchParameter
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDomains
Specifies an array of domains to exclude from the query.

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
Specifies additional information about the forest.

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
Specifies the name of the forest to query for GPO information.

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

### -GPOGUID
Specifies the GUID of the GPO to retrieve information for.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOName
Specifies the name of the GPO to retrieve information for.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: Name
Possible values:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomains
Specifies an array of domains to include in the query.

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
