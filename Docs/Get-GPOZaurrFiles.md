---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Get-GPOZaurrFiles
## SYNOPSIS
Retrieves information about Group Policy Objects (GPOs) stored in SYSVOL and NETLOGON folders.

## SYNTAX
### __AllParameterSets
```powershell
Get-GPOZaurrFiles [[-Type] <string[]>] [[-HashAlgorithm] <string>] [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-IncludeDomains] <string[]>] [[-ExtendedForestInformation] <IDictionary>] [-Signature] [-AsHashTable] [-Extended] [-ExtendedMetaData] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves information about GPOs stored in SYSVOL and NETLOGON folders of specified domains. It can filter by type of files and hash algorithms used for verification.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Get-GPOZaurrFiles -Type 'All' -HashAlgorithm 'SHA256' -Signature
Retrieves all files from SYSVOL and NETLOGON folders with SHA256 hash algorithm and includes file signatures.
```


### EXAMPLE 2
```powershell
PS > Get-GPOZaurrFiles -Type 'Sysvol' -HashAlgorithm 'MD5' -AsHashTable
Retrieves only SYSVOL files with MD5 hash algorithm and returns the results as a hashtable.
```


## PARAMETERS

### -AsHashTable
Indicates whether to return the results as a hashtable.

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

### -ExcludeDomains
Specifies an array of domains to exclude from the search.

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

### -Extended
Indicates whether to include extended information about the forest.

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

### -ExtendedForestInformation
Specifies additional forest information to include.

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

### -ExtendedMetaData
Indicates whether to include extended metadata information.

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

### -Forest
Specifies the forest name to retrieve GPO information from.

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

### -HashAlgorithm
Specifies the hash algorithm to use for file verification. Valid values are 'None', 'MACTripleDES', 'MD5', 'RIPEMD160', 'SHA1', 'SHA256', 'SHA384', 'SHA512'.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values: None, MACTripleDES, MD5, RIPEMD160, SHA1, SHA256, SHA384, SHA512

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomains
Specifies an array of domains to include in the search.

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

### -Signature
Indicates whether to include file signatures for verification.

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

### -Type
Specifies the type of files to retrieve. Valid values are 'All', 'Netlogon', and 'Sysvol'.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values: All, Netlogon, Sysvol

Required: False
Position: 0
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
