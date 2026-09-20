---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Get-GPOZaurrFilesPolicyDefinition
## SYNOPSIS
Retrieves policy definitions for Group Policy Objects (GPOs) within specified domains.

## SYNTAX
### __AllParameterSets
```powershell
Get-GPOZaurrFilesPolicyDefinition [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-IncludeDomains] <string[]>] [[-ExtendedForestInformation] <IDictionary>] [-Signature] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves policy definitions for GPOs within specified domains. It collects information about policy files, including their attributes and digital signatures.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Get-GPOZaurrFilesPolicyDefinition -Forest "contoso.com" -IncludeDomains "domain1", "domain2" -ExcludeDomains "domain3" -Signature
Retrieves policy definitions for GPOs within the "contoso.com" forest, including domains "domain1" and "domain2" while excluding "domain3". Digital signature information is also retrieved.
```


## PARAMETERS

### -ExcludeDomains
Specifies an array of domains to exclude from the search.

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
Specifies additional forest information to include in the output.

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
Specifies the forest name to retrieve GPO policy definitions from.

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
Specifies an array of domains to include in the search.

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

### -Signature
Indicates whether to retrieve digital signature information for policy files.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

- `None`

## OUTPUTS

- `None`

## RELATED LINKS

- None
