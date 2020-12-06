---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version:
schema: 2.0.0
---

# Remove-GPOPermission

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
Remove-GPOPermission [[-Type] <String[]>] [[-IncludePermissionType] <GPPermissionType[]>]
 [[-ExcludePermissionType] <GPPermissionType[]>] [[-PermitType] <String>] [[-Principal] <String[]>]
 [[-PrincipalType] <String>] [[-ExcludePrincipal] <String[]>] [[-ExcludePrincipalType] <String>]
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

### -ExcludePermissionType
{{ Fill ExcludePermissionType Description }}

```yaml
Type: GPPermissionType[]
Parameter Sets: (All)
Aliases:
Accepted values: None, GpoApply, GpoRead, GpoEdit, GpoEditDeleteModifySecurity, GpoCustom, WmiFilterEdit, WmiFilterFullControl, WmiFilterCustom, StarterGpoRead, StarterGpoEdit, StarterGpoFullControl, StarterGpoCustom, SomCreateWmiFilter, SomWmiFilterFullControl, SomCreateGpo, SomCreateStarterGpo, SomLogging, SomPlanning, SomLink

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludePrincipal
{{ Fill ExcludePrincipal Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludePrincipalType
{{ Fill ExcludePrincipalType Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: DistinguishedName, Name, Sid

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludePermissionType
{{ Fill IncludePermissionType Description }}

```yaml
Type: GPPermissionType[]
Parameter Sets: (All)
Aliases:
Accepted values: None, GpoApply, GpoRead, GpoEdit, GpoEditDeleteModifySecurity, GpoCustom, WmiFilterEdit, WmiFilterFullControl, WmiFilterCustom, StarterGpoRead, StarterGpoEdit, StarterGpoFullControl, StarterGpoCustom, SomCreateWmiFilter, SomWmiFilterFullControl, SomCreateGpo, SomCreateStarterGpo, SomLogging, SomPlanning, SomLink

Required: False
Position: 1
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
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Principal
{{ Fill Principal Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PrincipalType
{{ Fill PrincipalType Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: DistinguishedName, Name, Sid

Required: False
Position: 5
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
Accepted values: Unknown, NotWellKnown, NotWellKnownAdministrative, Administrative, NotAdministrative, All

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
