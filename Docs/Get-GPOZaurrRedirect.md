---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Get-GPOZaurrRedirect
## SYNOPSIS
Command to detect if GPOs have correct path in SYSVOL, or someone changed it manually.

## SYNTAX
### Default (Default)
```powershell
Get-GPOZaurrRedirect [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-DateFrom <datetime>] [-DateTo <datetime>] [-DateRange <string>] [-DateProperty <string[]>] [-ExtendedForestInformation <IDictionary>] [<CommonParameters>]
```

### GPOName
```powershell
Get-GPOZaurrRedirect [-GPOName <string>] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-DateFrom <datetime>] [-DateTo <datetime>] [-DateRange <string>] [-DateProperty <string[]>] [-ExtendedForestInformation <IDictionary>] [<CommonParameters>]
```

### GPOGUID
```powershell
Get-GPOZaurrRedirect [-GPOGuid <string>] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-DateFrom <datetime>] [-DateTo <datetime>] [-DateRange <string>] [-DateProperty <string[]>] [-ExtendedForestInformation <IDictionary>] [<CommonParameters>]
```

## DESCRIPTION
Command to detect if GPOs have correct path in SYSVOL, or someone changed it manually.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Get-GPOZaurrRedirect | Format-Table
```


## PARAMETERS

### -DateFrom
Provide a date from which to start the search, by default the last X days are used

```yaml
Type: DateTime
Parameter Sets: Default, GPOName, GPOGUID
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DateProperty
Choose a date property. It can be WhenCreated or WhenChanged or both. By default whenCreated is used for comparison purposes

```yaml
Type: String[]
Parameter Sets: Default, GPOName, GPOGUID
Aliases: None
Possible values: WhenCreated, WhenChanged

Required: False
Position: named
Default value: WhenCreated
Accept pipeline input: False
Accept wildcard characters: False
```

### -DateRange
Provide a date range to search for, by default the last X days are used

```yaml
Type: String
Parameter Sets: Default, GPOName, GPOGUID
Aliases: None
Possible values: PastHour, CurrentHour, PastDay, CurrentDay, PastMonth, CurrentMonth, PastQuarter, CurrentQuarter, Last14Days, Last21Days, Last30Days, Last7Days, Last3Days, Last1Days

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DateTo
Provide a date to which to end the search, by default the last X days are used

```yaml
Type: DateTime
Parameter Sets: Default, GPOName, GPOGUID
Aliases: None
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
Parameter Sets: Default, GPOName, GPOGUID
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
Parameter Sets: Default, GPOName, GPOGUID
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Forest
Target different Forest, by default current forest is used

```yaml
Type: String
Parameter Sets: Default, GPOName, GPOGUID
Aliases: ForestName
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOGuid
Provide GPO GUID to search for. By default command returns all GPOs

```yaml
Type: String
Parameter Sets: GPOGUID
Aliases: GUID, GPOID
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOName
Provide GPO name to search for. By default command returns all GPOs

```yaml
Type: String
Parameter Sets: GPOName
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
Parameter Sets: Default, GPOName, GPOGUID
Aliases: Domain, Domains
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
