---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Get-GPOZaurrBackupInformation
## SYNOPSIS
Retrieves backup information from GPOZaurr manifest files.

## SYNTAX
### __AllParameterSets
```powershell
Get-GPOZaurrBackupInformation [[-BackupFolder] <string[]>] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves backup information from GPOZaurr manifest files located in the specified BackupFolder(s).

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Get-GPOZaurrBackupInformation -BackupFolder "C:\Backups"
```

Description:
Retrieves backup information from GPOZaurr manifest files located in the "C:\Backups" folder.

### EXAMPLE 2
```powershell
PS > Get-GPOZaurrBackupInformation -BackupFolder "C:\Backups", "D:\Archives"
```

Description:
Retrieves backup information from GPOZaurr manifest files located in both "C:\Backups" and "D:\Archives" folders.

## PARAMETERS

### -BackupFolder
Specifies the path(s) to the folder containing GPOZaurr manifest files.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
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
