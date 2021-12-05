---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version:
schema: 2.0.0
---

# Get-GPOZaurrUpdates

## SYNOPSIS
Gets the list of GPOs created or updated in the last X number of days.

## SYNTAX

### DateRange (Default)
```
Get-GPOZaurrUpdates [-Forest <String>] [-ExcludeDomains <String[]>] [-IncludeDomains <String[]>]
 -DateRange <String> [-DateProperty <String[]>] [-ExtendedForestInformation <IDictionary>] [<CommonParameters>]
```

### Dates
```
Get-GPOZaurrUpdates [-Forest <String>] [-ExcludeDomains <String[]>] [-IncludeDomains <String[]>]
 -DateFrom <DateTime> -DateTo <DateTime> [-DateProperty <String[]>] [-ExtendedForestInformation <IDictionary>]
 [<CommonParameters>]
```

## DESCRIPTION
Gets the list of GPOs created or updated in the last X number of days.

## EXAMPLES

### EXAMPLE 1
```
Get-GPOZaurrUpdates -DateRange Last14Days -DateProperty WhenCreated, WhenChanged -Verbose -IncludeDomains 'ad.evotec.pl' | Format-List
```

### EXAMPLE 2
```
Get-GPOZaurrUpdates -DateRange Last14Days -DateProperty WhenCreated -Verbose | Format-Table
```

## PARAMETERS

### -Forest
Target different Forest, by default current forest is used

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
Exclude domain from search, by default whole forest is scanned

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
Include only specific domains, by default whole forest is scanned
ą

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

### -DateFrom
Provide a date from which to start the search, by default the last X days are used

```yaml
Type: DateTime
Parameter Sets: Dates
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DateTo
Provide a date to which to end the search, by default the last X days are used

```yaml
Type: DateTime
Parameter Sets: Dates
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DateRange
Provide a date range to search for, by default the last X days are used

```yaml
Type: String
Parameter Sets: DateRange
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DateProperty
Choose a date property.
It can be WhenCreated or WhenChanged or both.
By default whenCreated is used for comparison purposes

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: WhenCreated
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedForestInformation
Ability to provide Forest Information from another command to speed up processing

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS
