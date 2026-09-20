---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Remove-GPOZaurrBroken
## SYNOPSIS
Finds and removes broken Group Policies from SYSVOL or AD or both.

## SYNTAX
### __AllParameterSets
```powershell
Remove-GPOZaurrBroken [-Type] <string[]> [-BackupPath <string>] [-BackupDated] [-LimitProcessing <int>] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-ExtendedForestInformation <IDictionary>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Finds and removes broken Group Policies from SYSVOL or AD or both. Assesment is based on Get-GPOZaurrBroken and there are 3 supported types:
- AD - meaning GPOs which have no SYSVOL content will be deleted from AD
- SYSVOL - meaning GPOs which have no AD content will be deleted from SYSVOL
- ObjectClass - meaning GPOs which have ObjectClass category of Container rather than groupPolicyContainer will be deleted from AD & SYSVOL

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Remove-GPOZaurrBroken -Verbose -WhatIf -Type AD, SYSVOL
```


### EXAMPLE 2
```powershell
PS > Remove-GPOZaurrBroken -Verbose -WhatIf -Type AD, SYSVOL -IncludeDomains 'ad.evotec.pl' -LimitProcessing 2
```


### EXAMPLE 3
```powershell
PS > Remove-GPOZaurrBroken -Verbose -IncludeDomains 'ad.evotec.xyz' -BackupPath $Env:UserProfile\Desktop\MyBackup1 -WhatIf -Type AD, SYSVOL
```


## PARAMETERS

### -BackupDated
Forces backup to be created within folder that has date in it

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

### -BackupPath
Path to optional backup of SYSVOL content before deletion

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDomains
Exclude domain from search, by default whole forest is scanned

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: named
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
Position: named
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
Position: named
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
Position: named
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
Position: named
Default value: 2147483647
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Choose one or more types to delete. Options are AD, ObjectClass, SYSVOL

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values: SYSVOL, AD, ObjectClass

Required: True
Position: 0
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
