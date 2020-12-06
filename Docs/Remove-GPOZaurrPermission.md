---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version:
schema: 2.0.0
---

# Remove-GPOZaurrPermission

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Global (Default)
```
Remove-GPOZaurrPermission [-Principal <String[]>] [-PrincipalType <String>] [-Type <String[]>]
 [-IncludePermissionType <GPPermissionType[]>] [-ExcludePermissionType <GPPermissionType[]>] [-SkipWellKnown]
 [-SkipAdministrative] [-Forest <String>] [-ExcludeDomains <String[]>] [-IncludeDomains <String[]>]
 [-ExtendedForestInformation <IDictionary>] [-LimitProcessing <Int32>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### GPOName
```
Remove-GPOZaurrPermission -GPOName <String> [-Principal <String[]>] [-PrincipalType <String>]
 [-Type <String[]>] [-IncludePermissionType <GPPermissionType[]>] [-ExcludePermissionType <GPPermissionType[]>]
 [-SkipWellKnown] [-SkipAdministrative] [-Forest <String>] [-ExcludeDomains <String[]>]
 [-IncludeDomains <String[]>] [-ExtendedForestInformation <IDictionary>] [-LimitProcessing <Int32>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### GPOGUID
```
Remove-GPOZaurrPermission -GPOGuid <String> [-Principal <String[]>] [-PrincipalType <String>]
 [-Type <String[]>] [-IncludePermissionType <GPPermissionType[]>] [-ExcludePermissionType <GPPermissionType[]>]
 [-SkipWellKnown] [-SkipAdministrative] [-Forest <String>] [-ExcludeDomains <String[]>]
 [-IncludeDomains <String[]>] [-ExtendedForestInformation <IDictionary>] [-LimitProcessing <Int32>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
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

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
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

### -ExcludePermissionType
{{ Fill ExcludePermissionType Description }}

```yaml
Type: GPPermissionType[]
Parameter Sets: (All)
Aliases:
Accepted values: None, GpoApply, GpoRead, GpoEdit, GpoEditDeleteModifySecurity, GpoCustom, WmiFilterEdit, WmiFilterFullControl, WmiFilterCustom, StarterGpoRead, StarterGpoEdit, StarterGpoFullControl, StarterGpoCustom, SomCreateWmiFilter, SomWmiFilterFullControl, SomCreateGpo, SomCreateStarterGpo, SomLogging, SomPlanning, SomLink

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

### -GPOGuid
{{ Fill GPOGuid Description }}

```yaml
Type: String
Parameter Sets: GPOGUID
Aliases: GUID, GPOID

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOName
{{ Fill GPOName Description }}

```yaml
Type: String
Parameter Sets: GPOName
Aliases:

Required: True
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

### -IncludePermissionType
{{ Fill IncludePermissionType Description }}

```yaml
Type: GPPermissionType[]
Parameter Sets: (All)
Aliases: PermissionType
Accepted values: None, GpoApply, GpoRead, GpoEdit, GpoEditDeleteModifySecurity, GpoCustom, WmiFilterEdit, WmiFilterFullControl, WmiFilterCustom, StarterGpoRead, StarterGpoEdit, StarterGpoFullControl, StarterGpoCustom, SomCreateWmiFilter, SomWmiFilterFullControl, SomCreateGpo, SomCreateStarterGpo, SomLogging, SomPlanning, SomLink

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LimitProcessing
{{ Fill LimitProcessing Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
Position: Named
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
Accepted values: DistinguishedName, Name, NetbiosName, Sid

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipAdministrative
{{ Fill SkipAdministrative Description }}

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

### -SkipWellKnown
{{ Fill SkipWellKnown Description }}

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

### -Type
{{ Fill Type Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: Unknown, NotAdministrative, Default

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

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
