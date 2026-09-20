---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Get-GPOZaurrLink
## SYNOPSIS
Retrieves Group Policy Object (GPO) links based on specified criteria.

## SYNTAX
### Linked (Default)
```powershell
Get-GPOZaurrLink [-Linked <string[]>] [-Limited] [-SkipDuplicates] [-GPOCache <IDictionary>] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-ExtendedForestInformation <IDictionary>] [-AsHashTable] [-Summary] [<CommonParameters>]
```

### ADObject
```powershell
Get-GPOZaurrLink -ADObject <ADObject[]> [-Limited] [-SkipDuplicates] [-GPOCache <IDictionary>] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-ExtendedForestInformation <IDictionary>] [-AsHashTable] [-Summary] [<CommonParameters>]
```

### Filter
```powershell
Get-GPOZaurrLink [-Filter <string>] [-SearchBase <string>] [-SearchScope <ADSearchScope>] [-Limited] [-SkipDuplicates] [-GPOCache <IDictionary>] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-ExtendedForestInformation <IDictionary>] [-AsHashTable] [-Summary] [<CommonParameters>]
```

### Site
```powershell
Get-GPOZaurrLink [-Site <string[]>] [-GPOCache <IDictionary>] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-ExtendedForestInformation <IDictionary>] [-AsHashTable] [-Summary] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves GPO links based on various parameters such as ADObject, Filter, Linked, Site, etc. It provides flexibility in searching for GPO links within Active Directory.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Get-GPOZaurrLink -ADObject $ADObject -Linked 'All'
```

Description
-----------
Retrieves all linked GPOZaurr links for the specified Active Directory object(s).

### EXAMPLE 2
```powershell
PS > Get-GPOZaurrLink -Filter "(objectClass -eq 'organizationalUnit')" -SearchBase 'CN=Configuration,DC=ad,DC=evotec,DC=xyz'
```

Description
-----------
Retrieves GPOZaurr links based on the specified filter and search base.

## PARAMETERS

### -ADObject
Specifies the Active Directory object(s) to search for GPO links.

```yaml
Type: ADObject[]
Parameter Sets: ADObject
Aliases: None
Possible values:

Required: True
Position: named
Default value: None
Accept pipeline input: True (ByValue, ByPropertyName)
Accept wildcard characters: False
```

### -AsHashTable
Specifies the as hash table switch.

```yaml
Type: SwitchParameter
Parameter Sets: Linked, ADObject, Filter, Site
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDomains
Specifies the domains to exclude from the search.

```yaml
Type: String[]
Parameter Sets: Linked, ADObject, Filter, Site
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedForestInformation
Specifies one or more values for extended forest information.

```yaml
Type: IDictionary
Parameter Sets: Linked, ADObject, Filter, Site
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
Specifies the filter criteria to search for GPO links.

```yaml
Type: String
Parameter Sets: Filter
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Forest
Specifies the forest name for filtering GPO links.

```yaml
Type: String
Parameter Sets: Linked, ADObject, Filter, Site
Aliases: ForestName
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOCache
Specifies a cache for storing GPO information.

```yaml
Type: IDictionary
Parameter Sets: Linked, ADObject, Filter, Site
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomains
Specifies the domains to include in the search.

```yaml
Type: String[]
Parameter Sets: Linked, ADObject, Filter, Site
Aliases: Domain, Domains
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limited
Indicates whether to limit the search results.

```yaml
Type: SwitchParameter
Parameter Sets: Linked, ADObject, Filter
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Linked
Specifies the type of linked GPOs to retrieve. Valid values are 'All', 'Root', 'DomainControllers', 'Site', and 'OrganizationalUnit'.

```yaml
Type: String[]
Parameter Sets: Linked
Aliases: None
Possible values: All, Root, DomainControllers, Site, OrganizationalUnit

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchBase
Specifies the search base for filtering GPO links.

```yaml
Type: String
Parameter Sets: Filter
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchScope
Specifies the search scope for filtering GPO links.

```yaml
Type: ADSearchScope
Parameter Sets: Filter
Aliases: None
Possible values: Base, OneLevel, Subtree

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Site
Specifies the site(s) to search for GPO links.

```yaml
Type: String[]
Parameter Sets: Site
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipDuplicates
Indicates whether to skip duplicate search results.

```yaml
Type: SwitchParameter
Parameter Sets: Linked, ADObject, Filter
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Summary
Specifies the summary switch.

```yaml
Type: SwitchParameter
Parameter Sets: Linked, ADObject, Filter, Site
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

- `ADObject[]`

## OUTPUTS

- `None`

## RELATED LINKS

- None
