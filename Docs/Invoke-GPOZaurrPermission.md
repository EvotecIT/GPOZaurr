---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version:
schema: 2.0.0
---

# Invoke-GPOZaurrPermission

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Level
```
Invoke-GPOZaurrPermission [[-PermissionRules] <ScriptBlock>] -Level <Int32> -Limit <Int32> [-Type <String[]>]
 [-ApprovedGroups <Array>] [-Trustee <Array>] [-TrusteePermissionType <GPPermissionType>]
 [-TrusteeType <String>] [-GPOCache <IDictionary>] [-Forest <String>] [-ExcludeDomains <String[]>]
 [-IncludeDomains <String[]>] [-ExtendedForestInformation <IDictionary>] [-LimitAdministrativeGroupsToDomain]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Linked
```
Invoke-GPOZaurrPermission [[-PermissionRules] <ScriptBlock>] -Linked <String> [-Type <String[]>]
 [-ApprovedGroups <Array>] [-Trustee <Array>] [-TrusteePermissionType <GPPermissionType>]
 [-TrusteeType <String>] [-GPOCache <IDictionary>] [-Forest <String>] [-ExcludeDomains <String[]>]
 [-IncludeDomains <String[]>] [-ExtendedForestInformation <IDictionary>] [-LimitAdministrativeGroupsToDomain]
 [-SkipDuplicates] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ADObject
```
Invoke-GPOZaurrPermission [[-PermissionRules] <ScriptBlock>] -ADObject <ADObject[]> [-Type <String[]>]
 [-ApprovedGroups <Array>] [-Trustee <Array>] [-TrusteePermissionType <GPPermissionType>]
 [-TrusteeType <String>] [-GPOCache <IDictionary>] [-Forest <String>] [-ExcludeDomains <String[]>]
 [-IncludeDomains <String[]>] [-ExtendedForestInformation <IDictionary>] [-LimitAdministrativeGroupsToDomain]
 [-SkipDuplicates] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Filter
```
Invoke-GPOZaurrPermission [[-PermissionRules] <ScriptBlock>] [-Filter <String>] [-SearchBase <String>]
 [-SearchScope <ADSearchScope>] [-Type <String[]>] [-ApprovedGroups <Array>] [-Trustee <Array>]
 [-TrusteePermissionType <GPPermissionType>] [-TrusteeType <String>] [-GPOCache <IDictionary>]
 [-Forest <String>] [-ExcludeDomains <String[]>] [-IncludeDomains <String[]>]
 [-ExtendedForestInformation <IDictionary>] [-LimitAdministrativeGroupsToDomain] [-SkipDuplicates] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### GPOName
```
Invoke-GPOZaurrPermission [[-PermissionRules] <ScriptBlock>] [-GPOName <String>] [-Type <String[]>]
 [-ApprovedGroups <Array>] [-Trustee <Array>] [-TrusteePermissionType <GPPermissionType>]
 [-TrusteeType <String>] [-GPOCache <IDictionary>] [-Forest <String>] [-ExcludeDomains <String[]>]
 [-IncludeDomains <String[]>] [-ExtendedForestInformation <IDictionary>] [-LimitAdministrativeGroupsToDomain]
 [-SkipDuplicates] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### GPOGUID
```
Invoke-GPOZaurrPermission [[-PermissionRules] <ScriptBlock>] [-GPOGuid <String>] [-Type <String[]>]
 [-ApprovedGroups <Array>] [-Trustee <Array>] [-TrusteePermissionType <GPPermissionType>]
 [-TrusteeType <String>] [-GPOCache <IDictionary>] [-Forest <String>] [-ExcludeDomains <String[]>]
 [-IncludeDomains <String[]>] [-ExtendedForestInformation <IDictionary>] [-LimitAdministrativeGroupsToDomain]
 [-SkipDuplicates] [-WhatIf] [-Confirm] [<CommonParameters>]
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

### -ApprovedGroups
{{ Fill ApprovedGroups Description }}

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

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

### -GPOGuid
{{ Fill GPOGuid Description }}

```yaml
Type: String
Parameter Sets: GPOGUID
Aliases: GUID, GPOID

Required: False
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

### -Level
{{ Fill Level Description }}

```yaml
Type: Int32
Parameter Sets: Level
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
{{ Fill Limit Description }}

```yaml
Type: Int32
Parameter Sets: Level
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LimitAdministrativeGroupsToDomain
{{ Fill LimitAdministrativeGroupsToDomain Description }}

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

### -PermissionRules
{{ Fill PermissionRules Description }}

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
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
Parameter Sets: Linked, ADObject, Filter, GPOName, GPOGUID
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Trustee
{{ Fill Trustee Description }}

```yaml
Type: Array
Parameter Sets: (All)
Aliases: Principal

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TrusteePermissionType
{{ Fill TrusteePermissionType Description }}

```yaml
Type: GPPermissionType
Parameter Sets: (All)
Aliases:
Accepted values: None, GpoApply, GpoRead, GpoEdit, GpoEditDeleteModifySecurity, GpoCustom, WmiFilterEdit, WmiFilterFullControl, WmiFilterCustom, StarterGpoRead, StarterGpoEdit, StarterGpoFullControl, StarterGpoCustom, SomCreateWmiFilter, SomWmiFilterFullControl, SomCreateGpo, SomCreateStarterGpo, SomLogging, SomPlanning, SomLink

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TrusteeType
{{ Fill TrusteeType Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: PrincipalType
Accepted values: DistinguishedName, Name, Sid

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
Accepted values: Unknown, NotWellKnown, NotWellKnownAdministrative, NotAdministrative, All

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

### Microsoft.ActiveDirectory.Management.ADObject[]

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
