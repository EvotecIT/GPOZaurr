---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Get-GPOZaurrNetLogon
## SYNOPSIS
Retrieves information about Group Policy Objects (GPO) stored in the Netlogon and SYSVOL directories.

## SYNTAX
### Default (Default)
```powershell
Get-GPOZaurrNetLogon [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-ExtendedForestInformation <IDictionary>] [<CommonParameters>]
```

### OwnerOnly
```powershell
Get-GPOZaurrNetLogon [-OwnerOnly] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-ExtendedForestInformation <IDictionary>] [<CommonParameters>]
```

### SkipOwner
```powershell
Get-GPOZaurrNetLogon [-SkipOwner] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-ExtendedForestInformation <IDictionary>] [<CommonParameters>]
```

## DESCRIPTION
The Get-GPOZaurrNetLogon function retrieves details about GPOs stored in the Netlogon and SYSVOL directories of specified domains within a forest. It provides information about file ownership, status, domain, extension, creation time, and more.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Get-GPOZaurrNetLogon -Forest "contoso.com" -IncludeDomains "domain1", "domain2"
Retrieves GPO information for the specified forest and domains.
```


### EXAMPLE 2
```powershell
PS > Get-GPOZaurrNetLogon -OwnerOnly
Retrieves GPO information only for GPOs with identified owners.
```


### EXAMPLE 3
```powershell
PS > Get-GPOZaurrNetLogon -SkipOwner
Retrieves GPO information while skipping the owner check.
```


## PARAMETERS

### -ExcludeDomains
Specifies an array of domains to exclude from GPO retrieval.

```yaml
Type: String[]
Parameter Sets: Default, OwnerOnly, SkipOwner
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedForestInformation
Specifies additional forest information to include in the output.

```yaml
Type: IDictionary
Parameter Sets: Default, OwnerOnly, SkipOwner
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Forest
Specifies the forest name to retrieve GPO information from.

```yaml
Type: String
Parameter Sets: Default, OwnerOnly, SkipOwner
Aliases: ForestName
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomains
Specifies an array of domains to include in GPO retrieval.

```yaml
Type: String[]
Parameter Sets: Default, OwnerOnly, SkipOwner
Aliases: Domain, Domains
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OwnerOnly
Specifies whether to include only GPOs with identified owners.

```yaml
Type: SwitchParameter
Parameter Sets: OwnerOnly
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipOwner
Specifies whether to skip checking the owner of GPOs.

```yaml
Type: SwitchParameter
Parameter Sets: SkipOwner
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
