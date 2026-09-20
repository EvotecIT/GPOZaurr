---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Remove-GPOZaurrLinkEmptyOU
## SYNOPSIS
Removes Group Policy Object (GPO) links from empty Organizational Units (OUs) in a specified forest.

## SYNTAX
### __AllParameterSets
```powershell
Remove-GPOZaurrLinkEmptyOU [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-IncludeDomains] <string[]>] [[-ExtendedForestInformation] <IDictionary>] [[-ExcludeOrganizationalUnit] <string[]>] [[-LimitProcessing] <int>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function removes GPO links from OUs that are empty and meet specified criteria. It processes OUs within the specified forest based on inclusion and exclusion rules.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Remove-GPOZaurrLinkEmptyOU -Forest "ContosoForest" -IncludeDomains @("domain1", "domain2") -ExcludeDomains @("domain3") -ExtendedForestInformation $info -ExcludeOrganizationalUnit @("OU=TestOU,DC=contoso,DC=com") -LimitProcessing 100
Removes GPO links from empty OUs in the "ContosoForest" forest, including domains "domain1" and "domain2" but excluding "domain3". Additional forest information is provided, and processing is limited to 100 OUs.
```


## PARAMETERS

### -ExcludeDomains
Specifies an array of domains to exclude from processing.

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

### -ExcludeOrganizationalUnit
Specifies an array of OUs to exclude from processing.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 4
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
Specifies the name of the forest to target for processing.

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
Specifies an array of domains to include for processing.

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

### -LimitProcessing
Specifies the maximum number of OUs to process.

```yaml
Type: Int32
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 5
Default value: 2147483647
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
