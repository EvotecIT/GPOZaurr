---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version:
schema: 2.0.0
---

# Optimize-GPOZaurr

## SYNOPSIS
Enables or disables user/computer section of group policy based on it's content.

## SYNTAX

### GPOName (Default)
```
Optimize-GPOZaurr [[-ExcludeGroupPolicies] <ScriptBlock>] -GPOName <String> [-LimitProcessing <Int32>]
 [-Forest <String>] [-ExcludeDomains <String[]>] [-IncludeDomains <String[]>]
 [-ExtendedForestInformation <IDictionary>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### GPOGUID
```
Optimize-GPOZaurr [[-ExcludeGroupPolicies] <ScriptBlock>] -GPOGuid <String> [-LimitProcessing <Int32>]
 [-Forest <String>] [-ExcludeDomains <String[]>] [-IncludeDomains <String[]>]
 [-ExtendedForestInformation <IDictionary>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### All
```
Optimize-GPOZaurr [[-ExcludeGroupPolicies] <ScriptBlock>] [-All] [-LimitProcessing <Int32>] [-Forest <String>]
 [-ExcludeDomains <String[]>] [-IncludeDomains <String[]>] [-ExtendedForestInformation <IDictionary>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Long description

## EXAMPLES

### EXAMPLE 1
```
Optimize-GPOZaurr -All -WhatIf -Verbose -LimitProcessing 2
```

### EXAMPLE 2
```
Optimize-GPOZaurr -All -WhatIf -Verbose -LimitProcessing 2 {
```

Skip-GroupPolicy -Name 'TEST | Drive Mapping 1'
    Skip-GroupPolicy -Name 'TEST | Drive Mapping 2'
}

## PARAMETERS

### -ExcludeGroupPolicies
Provide a list of group policies to skip using Skip-GroupPolicy cmdlet

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOName
{{ Fill GPOName Description }}

```yaml
Type: String
Parameter Sets: GPOName
Aliases: Name, DisplayName

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOGuid
{{ Fill GPOGuid Description }}

```yaml
Type: String
Parameter Sets: GPOGUID
Aliases: GUID, GPOID

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -All
{{ Fill All Description }}

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -LimitProcessing
Allows to specify maximum number of items that will be fixed in a single run.
It doesn't affect amount of GPOs processed

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Forest
Target different Forest, by default current forest is used

```yaml
Type: String
Parameter Sets: (All)
Aliases: ForestName

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDomains
Exclude domain from search, by default whole forest is scanned

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomains
Include only specific domains, by default whole forest is scanned

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Domain, Domains

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedForestInformation
Ability to provide Forest Information from another command to speed up processing

```yaml
Type: IDictionary
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS
