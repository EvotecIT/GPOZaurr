---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version:
schema: 2.0.0
---

# Set-GPOOwner

## SYNOPSIS
Used within Invoke-GPOZaurrPermission only.
Set new group policy owner.

## SYNTAX

```
Set-GPOOwner [[-Type] <String>] [[-Principal] <String>] [<CommonParameters>]
```

## DESCRIPTION
Used within Invoke-GPOZaurrPermission only.
Set new group policy owner.

## EXAMPLES

### EXAMPLE 1
```
Invoke-GPOZaurrPermission -Verbose -SearchBase 'OU=Computers,OU=Production,DC=ad,DC=evotec,DC=xyz' {
```

Set-GPOOwner -Type Administrative
    Remove-GPOPermission -Type NotAdministrative, NotWellKnownAdministrative -IncludePermissionType GpoEdit, GpoEditDeleteModifySecurity
    Add-GPOPermission -Type Administrative -IncludePermissionType GpoEditDeleteModifySecurity
    Add-GPOPermission -Type WellKnownAdministrative -IncludePermissionType GpoEditDeleteModifySecurity
} -WhatIf

## PARAMETERS

### -Type
Choose Owner Type.
When chosing Administrative Type, owner will be set to Domain Admins for current GPO domain.
When Default is set Owner will be set to Principal given in another parameter.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Default
Accept pipeline input: False
Accept wildcard characters: False
```

### -Principal
Choose Owner Name to set for Group Policy

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS
