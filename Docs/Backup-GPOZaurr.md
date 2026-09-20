---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Backup-GPOZaurr
## SYNOPSIS
Provides Backup functionality to Group Policies

## SYNTAX
### __AllParameterSets
```powershell
Backup-GPOZaurr [[-LimitProcessing] <int>] [[-Type] <string[]>] [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-IncludeDomains] <string[]>] [[-ExtendedForestInformation] <IDictionary>] [[-BackupPath] <string>] [-BackupDated] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Provides Backup functionality to Group Policies

## EXAMPLES

### EXAMPLE 1
```powershell
PS > $GPOSummary = Backup-GPOZaurr -BackupPath "$Env:UserProfile\Desktop\GPO" -Verbose -Type All
$GPOSummary | Format-Table # only if you want to display output of backup
```


### EXAMPLE 2
```powershell
PS > $GPOSummary = Backup-GPOZaurr -BackupPath "$Env:UserProfile\Desktop\GPO" -Verbose -Type All -BackupDated
$GPOSummary | Format-Table # only if you want to display output of backup
```


## PARAMETERS

### -BackupDated
Whether cmdlet should created Dated folders for executed backup or not. Keep in mind it's not nessecary and two backups made to same folder have their dates properly tagged

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
Path where to keep the backup

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 6
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
Position: 3
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
Position: 5
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
Position: 2
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
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LimitProcessing
Limits amount of GPOs that are backed up

```yaml
Type: Int32
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 0
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Provides a way to backup only Empty or Unlinked GPOs. The default is All.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values: Empty, Unlinked, Disabled, All

Required: False
Position: 1
Default value: All
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
