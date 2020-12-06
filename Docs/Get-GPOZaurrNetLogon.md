---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version:
schema: 2.0.0
---

# Get-GPOZaurrNetLogon

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Default (Default)
```
Get-GPOZaurrNetLogon [-Forest <String>] [-ExcludeDomains <String[]>] [-IncludeDomains <String[]>]
 [-ExtendedForestInformation <IDictionary>] [<CommonParameters>]
```

### OwnerOnly
```
Get-GPOZaurrNetLogon [-OwnerOnly] [-Forest <String>] [-ExcludeDomains <String[]>] [-IncludeDomains <String[]>]
 [-ExtendedForestInformation <IDictionary>] [<CommonParameters>]
```

### SkipOwner
```
Get-GPOZaurrNetLogon [-SkipOwner] [-Forest <String>] [-ExcludeDomains <String[]>] [-IncludeDomains <String[]>]
 [-ExtendedForestInformation <IDictionary>] [<CommonParameters>]
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

### -OwnerOnly
{{ Fill OwnerOnly Description }}

```yaml
Type: SwitchParameter
Parameter Sets: OwnerOnly
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipOwner
{{ Fill SkipOwner Description }}

```yaml
Type: SwitchParameter
Parameter Sets: SkipOwner
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

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
