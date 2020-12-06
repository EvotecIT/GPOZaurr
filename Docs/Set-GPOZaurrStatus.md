---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version:
schema: 2.0.0
---

# Set-GPOZaurrStatus

## SYNOPSIS
Enables or disables user/computer section of Group Policy.

## SYNTAX

### GPOName (Default)
```
Set-GPOZaurrStatus -GPOName <String> -Status <GpoStatus> [-Forest <String>] [-ExcludeDomains <String[]>]
 [-IncludeDomains <String[]>] [-ExtendedForestInformation <IDictionary>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### GPOGUID
```
Set-GPOZaurrStatus -GPOGuid <String> -Status <GpoStatus> [-Forest <String>] [-ExcludeDomains <String[]>]
 [-IncludeDomains <String[]>] [-ExtendedForestInformation <IDictionary>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Enables or disables user/computer section of Group Policy.

## EXAMPLES

### EXAMPLE 1
```
Set-GPOZaurrStatus -Name 'TEST | Empty GPO - AD.EVOTEC.PL CrossDomain GPO' -Status AllSettingsEnabled -Verbose
```

### EXAMPLE 2
```
Set-GPOZaurrStatus -Name 'TEST | Empty GPO - AD.EVOTEC.PL CrossDomain GPO' -DomainName ad.evotec.pl -Status AllSettingsEnabled -Verbose
```

## PARAMETERS

### -GPOName
Provide Group Policy Name

```yaml
Type: String
Parameter Sets: GPOName
Aliases: Name, DisplayName

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOGuid
Provide Group Policy GUID

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

### -Status
Choose a status for provided Group Policy

```yaml
Type: GpoStatus
Parameter Sets: (All)
Aliases:
Accepted values: AllSettingsDisabled, UserSettingsDisabled, ComputerSettingsDisabled, AllSettingsEnabled

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Forest
Choose forest to target.

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

### -ExcludeDomains
Exclude domains from trying to find Group Policy Name or GUID

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

### -IncludeDomains
Include domain (one or more) to find Group Policy Name or GUID

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Domain, Domains, DomainName

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedForestInformation
Provide Extended Forest Information

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS
