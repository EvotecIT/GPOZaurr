---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Get-GPOZaurrLinkSummary
## SYNOPSIS
Retrieves a summary of GPO links based on specified criteria.

## SYNTAX
### __AllParameterSets
```powershell
Get-GPOZaurrLinkSummary [[-Report] <string[]>] [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-IncludeDomains] <string[]>] [[-ExtendedForestInformation] <IDictionary>] [-UnlimitedProperties] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves a summary of GPO links based on the provided parameters. It categorizes the links into different types and provides detailed information about each link.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Get-GPOZaurrLinkSummary -Forest "Contoso" -IncludeDomains "Domain1", "Domain2" -Report "MultipleLinks"
Retrieves a summary of GPO links for the specified forest and included domains, focusing on multiple links.
```


### EXAMPLE 2
```powershell
PS > Get-GPOZaurrLinkSummary -Forest "Fabrikam" -ExcludeDomains "Domain3" -Report "OneLink"
Retrieves a summary of GPO links for the specified forest excluding Domain3, focusing on a single link.
```


## PARAMETERS

### -ExcludeDomains
Specifies an array of domains to exclude from the report.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 2
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
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Forest
Specifies the forest name to retrieve GPO links from.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: ForestName
Possible values:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomains
Specifies an array of domains to include in the report.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: Domain, Domains
Possible values:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Report
Specifies the type of report to generate. Valid values are 'All', 'MultipleLinks', 'OneLink', and 'LinksSummary'. Default is 'All'.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values: All, MultipleLinks, OneLink, LinksSummary

Required: False
Position: 0
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -UnlimitedProperties
Indicates whether to include unlimited properties in the report.

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
