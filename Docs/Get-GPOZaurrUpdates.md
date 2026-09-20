---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Get-GPOZaurrUpdates
## SYNOPSIS
Gets the list of GPOs created or updated in the last X number of days.

## SYNTAX
### DateRange (Default)
```powershell
Get-GPOZaurrUpdates -DateRange <string> [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-DateProperty <string[]>] [-ExtendedForestInformation <IDictionary>] [<CommonParameters>]
```

### Dates
```powershell
Get-GPOZaurrUpdates -DateFrom <datetime> -DateTo <datetime> [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-DateProperty <string[]>] [-ExtendedForestInformation <IDictionary>] [<CommonParameters>]
```

## DESCRIPTION
Gets the list of GPOs created or updated in the last X number of days.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Get-GPOZaurrUpdates -DateRange Last14Days -DateProperty WhenCreated, WhenChanged -Verbose -IncludeDomains 'ad.evotec.pl' | Format-List
```


### EXAMPLE 2
```powershell
PS > Get-GPOZaurrUpdates -DateRange Last14Days -DateProperty WhenCreated -Verbose | Format-Table
```


## PARAMETERS

### -DateFrom
Provide a date from which to start the search, by default the last X days are used

```yaml
Type: DateTime
Parameter Sets: Dates
Aliases: None
Possible values:

Required: True
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DateProperty
Choose a date property. It can be WhenCreated or WhenChanged or both. By default whenCreated is used for comparison purposes

```yaml
Type: String[]
Parameter Sets: DateRange, Dates
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
Parameter Sets: DateRange
Aliases: None
Possible values: PastHour, CurrentHour, PastDay, CurrentDay, PastMonth, CurrentMonth, PastQuarter, CurrentQuarter, Last14Days, Last21Days, Last30Days, Last7Days, Last3Days, Last1Days

Required: True
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DateTo
Provide a date to which to end the search, by default the last X days are used

```yaml
Type: DateTime
Parameter Sets: Dates
Aliases: None
Possible values:

Required: True
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDomains
Exclude domain from search, by default whole forest is scanned

```yaml
Type: String[]
Parameter Sets: DateRange, Dates
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
Parameter Sets: DateRange, Dates
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
Parameter Sets: DateRange, Dates
Aliases: ForestName
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
Parameter Sets: DateRange, Dates
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
