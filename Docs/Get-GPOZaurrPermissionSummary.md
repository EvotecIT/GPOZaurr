---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version:
schema: 2.0.0
---

# Get-GPOZaurrPermissionSummary

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
Get-GPOZaurrPermissionSummary [[-Type] <String[]>] [[-PermitType] <String>]
 [[-IncludePermissionType] <String[]>] [[-ExcludePermissionType] <String[]>] [[-Forest] <String>]
 [[-ExcludeDomains] <String[]>] [[-IncludeDomains] <String[]>] [[-ExtendedForestInformation] <IDictionary>]
 [[-Separator] <String>] [<CommonParameters>]
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
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludePermissionType
{{ Fill ExcludePermissionType Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: GpoApply, GpoEdit, GpoCustom, GpoEditDeleteModifySecurity, GpoRead, GpoOwner, GpoRootCreate, GpoRootOwner

Required: False
Position: 3
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
Position: 7
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
Position: 4
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
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludePermissionType
{{ Fill IncludePermissionType Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: GpoApply, GpoEdit, GpoCustom, GpoEditDeleteModifySecurity, GpoRead, GpoOwner, GpoRootCreate, GpoRootOwner

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PermitType
{{ Fill PermitType Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Allow, Deny, All

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Separator
{{ Fill Separator Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
{{ Fill Type Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: AuthenticatedUsers, DomainComputers, Unknown, WellKnownAdministrative, NotWellKnown, NotWellKnownAdministrative, NotAdministrative, Administrative, All

Required: False
Position: 0
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
