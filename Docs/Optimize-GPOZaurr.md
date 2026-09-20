---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Optimize-GPOZaurr
## SYNOPSIS
Enables or disables user/computer section of group policy based on it's content.

## SYNTAX
### GPOName (Default)
```powershell
Optimize-GPOZaurr [[-ExcludeGroupPolicies] <scriptblock>] -GPOName <string> [-LimitProcessing <int>] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-ExtendedForestInformation <IDictionary>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### GPOGUID
```powershell
Optimize-GPOZaurr [[-ExcludeGroupPolicies] <scriptblock>] -GPOGuid <string> [-LimitProcessing <int>] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-ExtendedForestInformation <IDictionary>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### All
```powershell
Optimize-GPOZaurr [[-ExcludeGroupPolicies] <scriptblock>] -All [-LimitProcessing <int>] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-ExtendedForestInformation <IDictionary>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Enables or disables user/computer section of group policy based on it's content.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Optimize-GPOZaurr -All -WhatIf -Verbose -LimitProcessing 2
```


### EXAMPLE 2
```powershell
PS > Optimize-GPOZaurr -All -WhatIf -Verbose -LimitProcessing 2 {
    Skip-GroupPolicy -Name 'TEST | Drive Mapping 1'
    Skip-GroupPolicy -Name 'TEST | Drive Mapping 2'
}
```


## PARAMETERS

### -All
Specifies the all switch.

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases: None
Possible values:

Required: True
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDomains
Exclude domain from search, by default whole forest is scanned

```yaml
Type: String[]
Parameter Sets: GPOName, GPOGUID, All
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeGroupPolicies
Provide a list of group policies to skip using Skip-GroupPolicy cmdlet

```yaml
Type: ScriptBlock
Parameter Sets: GPOName, GPOGUID, All
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
Parameter Sets: GPOName, GPOGUID, All
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Forest
Target different Forest, by default current forest is used

```yaml
Type: String
Parameter Sets: GPOName, GPOGUID, All
Aliases: ForestName
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOGuid
Specifies a value for gpo guid.

```yaml
Type: String
Parameter Sets: GPOGUID
Aliases: GUID, GPOID
Possible values:

Required: True
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOName
Specifies a value for gpo name.

```yaml
Type: String
Parameter Sets: GPOName
Aliases: Name, DisplayName
Possible values:

Required: True
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomains
Include only specific domains, by default whole forest is scanned

```yaml
Type: String[]
Parameter Sets: GPOName, GPOGUID, All
Aliases: Domain, Domains
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LimitProcessing
Allows to specify maximum number of items that will be fixed in a single run. It doesn't affect amount of GPOs processed

```yaml
Type: Int32
Parameter Sets: GPOName, GPOGUID, All
Aliases: None
Possible values:

Required: False
Position: named
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
