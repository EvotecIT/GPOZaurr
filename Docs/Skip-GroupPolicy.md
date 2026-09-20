---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Skip-GroupPolicy
## SYNOPSIS
Used within ScriptBlocks only. Allows to exclude Group Policy from being affected by fixes

## SYNTAX
### Name (Default)
```powershell
Skip-GroupPolicy [-Name <string>] [-DomaiName <string>] [<CommonParameters>]
```

### Guid
```powershell
Skip-GroupPolicy [-GUID <string>] [-DomaiName <string>] [<CommonParameters>]
```

## DESCRIPTION
Used within ScriptBlocks only. Allows to exclude Group Policy from being affected by fixes. Only some commands support it. The goal is to support all cmdlets.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Optimize-GPOZaurr -All -WhatIf -Verbose -LimitProcessing 2 {
    Skip-GroupPolicy -Name 'TEST | Drive Mapping 1'
    Skip-GroupPolicy -Name 'TEST | Drive Mapping 2'
}
```


### EXAMPLE 2
```powershell
PS > Remove-GPOZaurr -Type Empty, Unlinked -BackupPath "$Env:UserProfile\Desktop\GPO" -BackupDated -LimitProcessing 2 -Verbose -WhatIf {
    Skip-GroupPolicy -Name 'TEST | Drive Mapping 1'
    Skip-GroupPolicy -Name 'TEST | Drive Mapping 2' -DomaiName 'ad.evotec.pl'
}
```


## PARAMETERS

### -DomaiName
Define DomainName where Group Policy is located. Otherwise each domain will be checked and skipped if found with same name.

```yaml
Type: String
Parameter Sets: Name, Guid
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GUID
Specifies a value for guid.

```yaml
Type: String
Parameter Sets: Guid
Aliases: ID
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Define Group Policy Name to skip

```yaml
Type: String
Parameter Sets: Name
Aliases: GpoName, DisplayName
Possible values:

Required: False
Position: named
Default value: None
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
