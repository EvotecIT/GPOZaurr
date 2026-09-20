---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Get-GPOZaurrDuplicateObject
## SYNOPSIS
Retrieves duplicate Group Policy Objects (GPOs) within a specified forest.

## SYNTAX
### __AllParameterSets
```powershell
Get-GPOZaurrDuplicateObject [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-IncludeDomains] <string[]>] [[-ExtendedForestInformation] <IDictionary>] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves duplicate Group Policy Objects (GPOs) within a specified forest by comparing GPOs based on partial distinguished name matching.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Get-GPOZaurrDuplicateObject -Forest "contoso.com" -IncludeDomains "child1.contoso.com", "child2.contoso.com" -ExcludeDomains "child3.contoso.com" -ExtendedForestInformation $additionalInfo
```

Description
-----------
Retrieves duplicate GPOs within the "contoso.com" forest, including domains "child1.contoso.com" and "child2.contoso.com" while excluding "child3.contoso.com". Additional forest information is provided for the search.

## PARAMETERS

### -ExcludeDomains
Specifies an array of domain names to exclude from the search for duplicate GPOs.

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
Specifies additional information about the forest to aid in the search for duplicate GPOs.

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
Specifies the name of the forest to search for duplicate GPOs.

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
Specifies an array of domain names to include in the search for duplicate GPOs.

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
