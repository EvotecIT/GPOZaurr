---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Invoke-GPOZaurr
## SYNOPSIS
Single cmdlet that provides 360 degree overview of Group Policies in Active Directory Forest.

## SYNTAX
### __AllParameterSets
```powershell
Invoke-GPOZaurr [[-Type] <string[]>] [[-Exclusions] <Object>] [-FilePath <string>] [-PassThru] [-HideHTML] [-HideSteps] [-ShowError] [-ShowWarning] [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-Online] [-SplitReports] [-GPOName <string[]>] [-GPOGUID <string[]>] [<CommonParameters>]
```

## DESCRIPTION
Single cmdlet that provides 360 degree overview of Group Policies in Active Directory Forest with ability to pick reports and export to HTML.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Invoke-GPOZaurr
```


### EXAMPLE 2
```powershell
PS > Invoke-GPOZaurr -Type GPOOrganizationalUnit -Online -FilePath $PSScriptRoot\Reports\GPOZaurrOU.html -Exclusions @(
    '*OU=Production,DC=ad,DC=evotec,DC=pl'
)
```


## PARAMETERS

### -ExcludeDomains
Exclude domain from search, by default whole forest is scanned

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exclusions
Allows to mark as excluded some Group Policies or Organizational Units depending on type.
Can be a scriptblock or array depending on supported way by underlying report.
Not every report support exclusions.
Not every report support exclusions the same way.
Exclusions should be used only if there is single report being asked for.

```yaml
Type: Object
Parameter Sets: __AllParameterSets
Aliases: ExcludeGroupPolicies, ExclusionsCode
Possible values:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilePath
Path to the file where the report will be saved.

```yaml
Type: String
Parameter Sets: __AllParameterSets
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
Parameter Sets: __AllParameterSets
Aliases: ForestName
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOGUID
Specifies one or more values for gpoguid.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: GUID
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOName
Specifies one or more values for gpo name.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: Name
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HideHTML
Do not auto open HTML report in default browser

```yaml
Type: SwitchParameter
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -HideSteps
Do not show steps in report

```yaml
Type: SwitchParameter
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomains
Include only specific domains, by default whole forest is scanned

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: Domain, Domains
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Online
Forces report to use online resources in HTML (using CDN most of the time), by default it is run offline, and inlines all CSS/JS code.

```yaml
Type: SwitchParameter
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Returns created objects after the report is done

```yaml
Type: SwitchParameter
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowError
Show errors in HTML report. Useful in case the report is being run as Scheduled Task

```yaml
Type: SwitchParameter
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowWarning
Show warnings in HTML report. Useful in case the report is being run as Scheduled Task

```yaml
Type: SwitchParameter
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SplitReports
Split report into multiple files, one for each report. This can be useful for large domains with huge reports.

```yaml
Type: SwitchParameter
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Type of report to be generated from a list of available reports.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 0
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
