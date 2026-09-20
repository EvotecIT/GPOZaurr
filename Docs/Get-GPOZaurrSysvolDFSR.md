---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Get-GPOZaurrSysvolDFSR
## SYNOPSIS
Gets DFSR information from the SYSVOL DFSR

## SYNTAX
### __AllParameterSets
```powershell
Get-GPOZaurrSysvolDFSR [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-ExcludeDomainControllers] <string[]>] [[-IncludeDomains] <string[]>] [[-IncludeDomainControllers] <string[]>] [[-ExtendedForestInformation] <IDictionary>] [[-SearchDFSR] <string>] [-SkipRODC] [<CommonParameters>]
```

## DESCRIPTION
Gets DFSR information from the SYSVOL DFSR

## EXAMPLES

### EXAMPLE 1
```powershell
PS > $DFSR = Get-GPOZaurrSysvolDFSR
$DFSR | Format-Table *
```


## PARAMETERS

### -ExcludeDomainControllers
Exclude specific domain controllers, by default there are no exclusions, as long as VerifyDomainControllers switch is enabled. Otherwise this parameter is ignored.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDomains
Exclude domain from search, by default whole forest is scanned

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedForestInformation
Ability to provide Forest Information from another command to speed up processing

```yaml
Type: IDictionary
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 5
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
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomainControllers
Include only specific domain controllers, by default all domain controllers are included, as long as VerifyDomainControllers switch is enabled. Otherwise this parameter is ignored.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: DomainControllers
Possible values:

Required: False
Position: 4
Default value: None
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
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchDFSR
Define DFSR Share. By default it uses SYSVOL Share

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 6
Default value: SYSVOL Share
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipRODC
Skip Read-Only Domain Controllers. By default all domain controllers are included.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

- `None`

## OUTPUTS

- `None`

## RELATED LINKS

- None
