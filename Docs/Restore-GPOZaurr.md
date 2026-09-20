---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Restore-GPOZaurr
## SYNOPSIS
Restores Group Policy Objects (GPOs) from a specified backup folder.

## SYNTAX
### __AllParameterSets
```powershell
Restore-GPOZaurr [-BackupFolder] <string> [[-DisplayName] <string>] [[-NewDisplayName] <string>] [[-Domain] <string>] [-SkipBackupSummary] [<CommonParameters>]
```

## DESCRIPTION
Restores Group Policy Objects (GPOs) from a specified backup folder. This function allows restoring GPOs with the option to provide a new display name for the GPO.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Restore-GPOZaurr -BackupFolder 'C:\GPOBackups' -DisplayName 'TestGPO'
```


### EXAMPLE 2
```powershell
PS > Restore-GPOZaurr -BackupFolder 'C:\GPOBackups' -DisplayName 'TestGPO' -NewDisplayName 'NewTestGPO' -Domain 'example.com'
```


## PARAMETERS

### -BackupFolder
The path to the folder containing the GPO backups.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayName
The display name of the GPO to be restored.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: Name
Possible values:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Domain
(Optional) The domain name where the GPO should be restored.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NewDisplayName
(Optional) The new display name for the restored GPO.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipBackupSummary
(Switch) Skip displaying the backup summary information.

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
