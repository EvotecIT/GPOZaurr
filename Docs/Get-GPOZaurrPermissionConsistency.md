---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Get-GPOZaurrPermissionConsistency
## SYNOPSIS
Retrieves information about Group Policy Objects (GPOs) and checks permission consistency across domains.

## SYNTAX
### Type (Default)
```powershell
Get-GPOZaurrPermissionConsistency [-Type <string[]>] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-ExtendedForestInformation <IDictionary>] [-IncludeGPOObject] [-VerifyInheritance] [<CommonParameters>]
```

### GPOName
```powershell
Get-GPOZaurrPermissionConsistency [-GPOName <string>] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-ExtendedForestInformation <IDictionary>] [-IncludeGPOObject] [-VerifyInheritance] [<CommonParameters>]
```

### GPOGUID
```powershell
Get-GPOZaurrPermissionConsistency [-GPOGuid <string>] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-ExtendedForestInformation <IDictionary>] [-IncludeGPOObject] [-VerifyInheritance] [<CommonParameters>]
```

## DESCRIPTION
The Get-GPOZaurrPermissionConsistency function retrieves information about GPOs and checks permission consistency across domains. It can filter by GPO name, GPO GUID, or type of consistency. It also provides options to include/exclude specific domains and verify inheritance.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Get-GPOZaurrPermissionConsistency -GPOName "TestGPO" -Forest "Contoso" -IncludeDomains @("DomainA", "DomainB") -Type "Consistent"
Retrieves permission consistency information for the GPO named "TestGPO" in the forest "Contoso" for domains "DomainA" and "DomainB" with consistent permissions.
```


### EXAMPLE 2
```powershell
PS > Get-GPOZaurrPermissionConsistency -GPOGuid "12345678-1234-1234-1234-1234567890AB" -Forest "Fabrikam" -Type "Inconsistent" -VerifyInheritance
Retrieves permission consistency information for the GPO with GUID "12345678-1234-1234-1234-1234567890AB" in the forest "Fabrikam" for all domains with inconsistent permissions and verifies inheritance.
```


## PARAMETERS

### -ExcludeDomains
Specifies an array of domains to exclude from the search.

```yaml
Type: String[]
Parameter Sets: Type, GPOName, GPOGUID
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedForestInformation
Specifies additional information about the forest.

```yaml
Type: IDictionary
Parameter Sets: Type, GPOName, GPOGUID
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
Parameter Sets: Type, GPOName, GPOGUID
Aliases: ForestName
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOGuid
Specifies the GUID of the GPO to retrieve.

```yaml
Type: String
Parameter Sets: GPOGUID
Aliases: GUID, GPOID
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOName
Specifies the name of the GPO to retrieve.

```yaml
Type: String
Parameter Sets: GPOName
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomains
Specifies an array of domains to include in the search.

```yaml
Type: String[]
Parameter Sets: Type, GPOName, GPOGUID
Aliases: Domain, Domains
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeGPOObject
Indicates whether to include the GPO object in the output.

```yaml
Type: SwitchParameter
Parameter Sets: Type, GPOName, GPOGUID
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Specifies the type of consistency to check. Valid values are 'Consistent', 'Inconsistent', or 'All'.

```yaml
Type: String[]
Parameter Sets: Type
Aliases: None
Possible values: Consistent, Inconsistent, All

Required: False
Position: named
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -VerifyInheritance
Indicates whether to verify inheritance of permissions.

```yaml
Type: SwitchParameter
Parameter Sets: Type, GPOName, GPOGUID
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
