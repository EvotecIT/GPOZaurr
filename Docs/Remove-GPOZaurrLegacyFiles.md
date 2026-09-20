---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Remove-GPOZaurrLegacyFiles
## SYNOPSIS
Removes legacy Group Policy Objects (GPO) files from specified domains.

## SYNTAX
### __AllParameterSets
```powershell
Remove-GPOZaurrLegacyFiles [[-BackupPath] <string>] [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-IncludeDomains] <string[]>] [[-LimitProcessing] <int>] [-BackupDated] [-RemoveEmptyFolders] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The Remove-GPOZaurrLegacyFiles function removes legacy GPO files from specified domains. It can back up the files before removal and optionally remove empty folders.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Remove-GPOZaurrLegacyFiles -BackupPath "C:\GPOBackups" -BackupDated -RemoveEmptyFolders -Forest "Contoso" -IncludeDomains "Domain1", "Domain2" -ExcludeDomains "Domain3" -LimitProcessing 100
Removes legacy GPO files from the "Contoso" forest for "Domain1" and "Domain2", excluding "Domain3". Backs up files to "C:\GPOBackups" with timestamps and removes empty folders after deletion.
```


## PARAMETERS

### -BackupDated
Indicates whether backup files should be timestamped with the current date and time.

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
Specifies the path where backup files will be stored.

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
Specifies an array of domains to exclude from processing.

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

### -Forest
Specifies the forest where the GPO files are located.

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
Specifies an array of domains to include for processing.

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

### -LimitProcessing
Specifies the maximum number of GPO files to process.

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

### -RemoveEmptyFolders
Indicates whether empty folders should be removed after GPO files are deleted.

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
