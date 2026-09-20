---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Get-GPOZaurrAD
## SYNOPSIS
Retrieves Group Policy Objects (GPOs) information from Active Directory.

## SYNTAX
### Default (Default)
```powershell
Get-GPOZaurrAD [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-DateFrom <datetime>] [-DateTo <datetime>] [-DateRange <string>] [-DateProperty <string[]>] [-ExtendedForestInformation <IDictionary>] [<CommonParameters>]
```

### GPOName
```powershell
Get-GPOZaurrAD [-GPOName <string>] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-DateFrom <datetime>] [-DateTo <datetime>] [-DateRange <string>] [-DateProperty <string[]>] [-ExtendedForestInformation <IDictionary>] [<CommonParameters>]
```

### GPOGUID
```powershell
Get-GPOZaurrAD [-GPOGuid <string>] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-DateFrom <datetime>] [-DateTo <datetime>] [-DateRange <string>] [-DateProperty <string[]>] [-ExtendedForestInformation <IDictionary>] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves information about Group Policy Objects (GPOs) from Active Directory based on specified criteria such as GPO name, GPO GUID, date range, and forest details.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Get-GPOZaurrAD -GPOName "ExampleGPO"
```

Description:
Retrieves information about a GPO with the name "ExampleGPO".

### EXAMPLE 2
```powershell
PS > Get-GPOZaurrAD -GPOGuid "{12345678-1234-1234-1234-123456789012}"
```

Description:
Retrieves information about a GPO with the specified GUID.

### EXAMPLE 3
```powershell
PS > Get-GPOZaurrAD -Forest "example.com" -IncludeDomains "domain1", "domain2" -DateRange "Last30Days"
```

Description:
Retrieves GPO information from the forest "example.com" for domains "domain1" and "domain2" created or modified in the last 30 days.

## PARAMETERS

### -DateFrom
Specifies the start date for filtering GPOs based on creation or modification date.

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
Specifies the property (WhenCreated or WhenChanged) to use for filtering GPOs based on date.

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
Specifies a predefined date range for filtering GPOs based on creation or modification date.

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
Specifies the end date for filtering GPOs based on creation or modification date.

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
Specifies an array of domains to exclude from the search.

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
Specifies additional forest information to include in the output.

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
Specifies the forest name to search for GPOs.

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
Specifies the GUID of the GPO to retrieve.

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
Specifies the name of the GPO to retrieve.

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
Specifies an array of domains to include in the search.

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
