---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Remove-GPOZaurrFolders
## SYNOPSIS
Removes specified GPOZaurr folders and backs them up to a specified path.

## SYNTAX
### __AllParameterSets
```powershell
Remove-GPOZaurrFolders [[-BackupPath] <string>] [[-Type] <string[]>] [-FolderType] <string> [[-FolderName] <string[]>] [[-LimitProcessing] <int>] [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-IncludeDomains] <string[]>] [[-ExtendedForestInformation] <IDictionary>] [-BackupDated] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function removes specified GPOZaurr folders based on the provided criteria and backs them up to a specified path. It allows for filtering by folder type, domain, and other parameters.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Remove-GPOZaurrFolders -BackupPath "C:\Backups" -BackupDated -Type 'All' -FolderType 'NTFRS' -FolderName "Folder1" -LimitProcessing 10 -Forest "ExampleForest" -ExcludeDomains "Domain1" -IncludeDomains "Domain2" -ExtendedForestInformation $info
Removes GPOZaurr folders of type 'NTFRS' named "Folder1" from all domains in the forest "ExampleForest", backs them up to "C:\Backups" with a timestamp, and limits processing to 10 folders.
```


## PARAMETERS

### -BackupDated
Indicates whether the backup path should include a timestamp.

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
The path where the GPOZaurr folders will be backed up.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDomains
Specifies domains to exclude from processing.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedForestInformation
Specifies additional forest information.

```yaml
Type: IDictionary
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FolderName
Specifies the name of the folder to remove.

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

### -FolderType
Specifies the type of folders to remove. Options are 'NTFRS' or 'Empty'.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values: NTFRS, Empty

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Forest
Specifies the forest to target.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: ForestName
Possible values:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomains
Specifies domains to include in processing.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: Domain, Domains
Possible values:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LimitProcessing
Limits the number of folders to process.

```yaml
Type: Int32
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 4
Default value: 2147483647
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Specifies the type of folders to remove. Options are 'All', 'Netlogon', or 'Sysvol'.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values: All, Netlogon, Sysvol

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
