---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version:
schema: 2.0.0
---

# Get-GPOZaurrUpdates

## SYNOPSIS
{{ Fill in the Synopsis }}

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
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -DateFrom
{{ Fill DateFrom Description }}

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

### -DateProperty
{{ Fill DateProperty Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: WhenCreated, WhenChanged

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DateRange
{{ Fill DateRange Description }}

```yaml
Type: String
Parameter Sets: DateRange
Aliases:
Accepted values: PastHour, CurrentHour, PastDay, CurrentDay, PastMonth, CurrentMonth, PastQuarter, CurrentQuarter, Last14Days, Last21Days, Last30Days, Last7Days, Last3Days, Last1Days

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DateTo
{{ Fill DateTo Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
