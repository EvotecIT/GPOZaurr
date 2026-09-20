---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Set-GPOZaurrOwner
## SYNOPSIS
Sets GPO Owner to Domain Admins or other choosen account

## SYNTAX
### Type (Default)
```powershell
Set-GPOZaurrOwner -Type <string> [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-ExtendedForestInformation <IDictionary>] [-Principal <string>] [-SkipSysvol] [-LimitProcessing <int>] [-ApprovedOwner <string[]>] [-Action <string>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Named
```powershell
Set-GPOZaurrOwner [-GPOName <string>] [-GPOGuid <string>] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-ExtendedForestInformation <IDictionary>] [-Principal <string>] [-SkipSysvol] [-LimitProcessing <int>] [-ApprovedOwner <string[]>] [-Action <string>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sets GPO Owner to Domain Admins or other choosen account. GPO Owner is set in AD and SYSVOL unless specified otherwise. If account doesn't require change, no change is done.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Set-GPOZaurrOwner -Type All -Verbose -WhatIf -LimitProcessing 2
```


## PARAMETERS

### -Action
Specifies a value for action.

```yaml
Type: String
Parameter Sets: Type, Named
Aliases: None
Possible values: OnlyAD, OnlyFileSystem

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApprovedOwner
Specifies one or more values for approved owner.

```yaml
Type: String[]
Parameter Sets: Type, Named
Aliases: Exclusion, Exclusions
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDomains
Exclude domain from search, by default whole forest is scanned

```yaml
Type: String[]
Parameter Sets: Type, Named
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedForestInformation
Ability to provide Forest Information from another command to speed up processing

```yaml
Type: IDictionary
Parameter Sets: Type, Named
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Pushes new owner regardless if it's already set or not

```yaml
Type: SwitchParameter
Parameter Sets: Type, Named
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Forest
Target different Forest, by default current forest is used

```yaml
Type: String
Parameter Sets: Type, Named
Aliases: ForestName
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOGuid
GUID of GPO. By default all GPOs are targetted

```yaml
Type: String
Parameter Sets: Named
Aliases: GUID, GPOID
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOName
Name of GPO. By default all GPOs are targetted

```yaml
Type: String
Parameter Sets: Named
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomains
Include only specific domains, by default whole forest is scanned

```yaml
Type: String[]
Parameter Sets: Type, Named
Aliases: Domain, Domains
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LimitProcessing
Allows to specify maximum number of items that will be fixed in a single run. It doesn't affect amount of GPOs processed

```yaml
Type: Int32
Parameter Sets: Type, Named
Aliases: None
Possible values:

Required: False
Position: named
Default value: 2147483647
Accept pipeline input: False
Accept wildcard characters: False
```

### -Principal
Parameter description

```yaml
Type: String
Parameter Sets: Type, Named
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipSysvol
Set GPO Owner only in Active Directory. By default GPO Owner is being set in both places

```yaml
Type: SwitchParameter
Parameter Sets: Type, Named
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Unknown - finds unknown Owners and sets them to Administrative (Domain Admins) or chosen principal
NotMatching - find administrative groups only and if sysvol and gpo doesn't match - replace with chosen principal or Domain Admins if not specified
Inconsistent - same as not NotMatching
NotAdministrative - combination of Unknown/NotMatching and NotAdministrative - replace with chosen principal or Domain Admins if not specified
All - if Owner is known it checks if it's Administrative, if it sn't it fixes that. If owner is unknown it fixes it

```yaml
Type: String
Parameter Sets: Type
Aliases: None
Possible values: Unknown, NotAdministrative, NotMatching, Inconsistent, All

Required: True
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
