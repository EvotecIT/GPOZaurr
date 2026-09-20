---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Set-GPOOwner
## SYNOPSIS
Used within Invoke-GPOZaurrPermission only. Set new group policy owner.

## SYNTAX
### __AllParameterSets
```powershell
Set-GPOOwner [[-Type] <string>] [[-Principal] <string>] [<CommonParameters>]
```

## DESCRIPTION
Used within Invoke-GPOZaurrPermission only. Set new group policy owner.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Invoke-GPOZaurrPermission -Verbose -SearchBase 'OU=Computers,OU=Production,DC=ad,DC=evotec,DC=xyz' {
    Set-GPOOwner -Type Administrative
    Remove-GPOPermission -Type NotAdministrative, NotWellKnownAdministrative -IncludePermissionType GpoEdit, GpoEditDeleteModifySecurity
    Add-GPOPermission -Type Administrative -IncludePermissionType GpoEditDeleteModifySecurity
    Add-GPOPermission -Type WellKnownAdministrative -IncludePermissionType GpoEditDeleteModifySecurity
} -WhatIf
```


## PARAMETERS

### -Principal
Choose Owner Name to set for Group Policy

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Choose Owner Type. When chosing Administrative Type, owner will be set to Domain Admins for current GPO domain. When Default is set Owner will be set to Principal given in another parameter.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values: Administrative, Default

Required: False
Position: 0
Default value: Default
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
