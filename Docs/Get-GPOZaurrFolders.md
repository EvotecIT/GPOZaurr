---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Get-GPOZaurrFolders
## SYNOPSIS
Retrieves information about GPO folders within specified domains.

## SYNTAX
### __AllParameterSets
```powershell
Get-GPOZaurrFolders [[-Type] <string[]>] [[-FolderType] <string>] [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-IncludeDomains] <string[]>] [[-ExtendedForestInformation] <IDictionary>] [-AsHashTable] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves information about various GPO folders within specified domains, such as PolicyDefinitions, Policies, Scripts, GPO Starters, NETLOGON Scripts, DfsrPrivate, and SYSVOL Root.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Get-GPOZaurrFolders -Type All -FolderType All -Forest 'example.com' -IncludeDomains 'domain1', 'domain2' -ExcludeDomains 'domain3' -ExtendedForestInformation $info -AsHashTable
Retrieves information about all types of GPO folders within the specified domains in the forest 'example.com', excluding 'domain3', and including 'domain1' and 'domain2', with extended forest information.
```


### EXAMPLE 2
```powershell
PS > Get-GPOZaurrFolders -Type Sysvol -FolderType NTFRS -Forest 'example.com' -IncludeDomains 'domain1' -AsHashTable
Retrieves information about Sysvol folders using NTFRS type within the specified domain 'domain1' in the forest 'example.com' and returns the output as a hashtable.
```


## PARAMETERS

### -AsHashTable
Indicates whether to return the output as a hashtable.

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
Specifies domains to exclude from the retrieval.

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
Specifies additional information about the forest.

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

### -FolderType
Specifies the type of folders to retrieve. Valid values are 'All', 'NTFRS', 'Empty'.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values: All, NTFRS, Empty

Required: False
Position: 1
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -Forest
Specifies the forest name to retrieve information for.

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
Specifies domains to include in the retrieval.

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

### -Type
Specifies the type of folders to retrieve. Valid values are 'All', 'Netlogon', 'Sysvol'.

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
