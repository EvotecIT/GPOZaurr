---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version:
schema: 2.0.0
---

# Get-GPOZaurrLink

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### ADObject
```
Get-GPOZaurrLink -ADObject <ADObject[]> [-Limited] [-SkipDuplicates] [-GPOCache <IDictionary>]
 [-Forest <String>] [-ExcludeDomains <String[]>] [-IncludeDomains <String[]>]
 [-ExtendedForestInformation <IDictionary>] [<CommonParameters>]
```

### Filter
```
Get-GPOZaurrLink [-Filter <String>] [-SearchBase <String>] [-SearchScope <ADSearchScope>] [-Limited]
 [-SkipDuplicates] [-GPOCache <IDictionary>] [-Forest <String>] [-ExcludeDomains <String[]>]
 [-IncludeDomains <String[]>] [-ExtendedForestInformation <IDictionary>] [<CommonParameters>]
```

### Linked
```
Get-GPOZaurrLink -Linked <String> [-Limited] [-SkipDuplicates] [-GPOCache <IDictionary>] [-Forest <String>]
 [-ExcludeDomains <String[]>] [-IncludeDomains <String[]>] [-ExtendedForestInformation <IDictionary>]
 [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ADObject
{{ Fill ADObject Description }}

```yaml
Type: ADObject[]
Parameter Sets: ADObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ExcludeDomains
{{ Fill ExcludeDomains Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedForestInformation
{{ Fill ExtendedForestInformation Description }}

```yaml
Type: IDictionary
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
{{ Fill Filter Description }}

```yaml
Type: String
Parameter Sets: Filter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Forest
{{ Fill Forest Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: ForestName

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOCache
{{ Fill GPOCache Description }}

```yaml
Type: IDictionary
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomains
{{ Fill IncludeDomains Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Domain, Domains

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limited
{{ Fill Limited Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Linked
{{ Fill Linked Description }}

```yaml
Type: String
Parameter Sets: Linked
Aliases:
Accepted values: Root, DomainControllers, Site, Other

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchBase
{{ Fill SearchBase Description }}

```yaml
Type: String
Parameter Sets: Filter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchScope
{{ Fill SearchScope Description }}

```yaml
Type: ADSearchScope
Parameter Sets: Filter
Aliases:
Accepted values: Base, OneLevel, Subtree

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipDuplicates
{{ Fill SkipDuplicates Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Microsoft.ActiveDirectory.Management.ADObject[]

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
