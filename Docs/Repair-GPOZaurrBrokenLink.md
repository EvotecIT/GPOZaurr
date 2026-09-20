---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Repair-GPOZaurrBrokenLink
## SYNOPSIS
Removes any link to GPO that no longer exists.

## SYNTAX
### __AllParameterSets
```powershell
Repair-GPOZaurrBrokenLink [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-IncludeDomains] <string[]>] [[-ExtendedForestInformation] <IDictionary>] [[-LimitProcessing] <int>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Removes any link to GPO that no longer exists. It scans all site, organizational unit or domain root making sure every single link that may be linking to GPO that doesn't exists anymore is gone.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Repair-GPOZaurrBrokenLink -Verbose -LimitProcessing 1 -WhatIf
```


### EXAMPLE 2
```powershell
PS > Repair-GPOZaurrBrokenLink -Verbose -IncludeDomains ad.evotec.pl -LimitProcessing 1 -WhatIf
```


## PARAMETERS

### -ExcludeDomains
Exclude domain from search, by default whole forest is scanned

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
Ability to provide Forest Information from another command to speed up processing

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
Target different Forest, by default current forest is used

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
Include only specific domains, by default whole forest is scanned

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
Allows to specify maximum number of items that will be fixed in a single run. It doesn't affect amount of GPOs processed

```yaml
Type: Int32
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 4
Default value: 0
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
