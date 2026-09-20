---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Get-GPOZaurrPermissionAnalysis
## SYNOPSIS
Analyzes permissions for Group Policy Objects (GPOs) and administrative groups.

## SYNTAX
### __AllParameterSets
```powershell
Get-GPOZaurrPermissionAnalysis [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-IncludeDomains] <string[]>] [[-Permissions] <array>] [<CommonParameters>]
```

## DESCRIPTION
This function analyzes permissions for Group Policy Objects (GPOs) and identifies administrative groups with specific permissions.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Get-GPOZaurrPermissionAnalysis -Forest "ContosoForest" -IncludeDomains @("Domain1", "Domain2") -ExcludeDomains @("Domain3") -Permissions $PermissionsArray
Analyzes permissions for GPOs in the "ContosoForest" forest, including "Domain1" and "Domain2" while excluding "Domain3", using the specified permissions array.
```


## PARAMETERS

### -ExcludeDomains
Specifies an array of domains to exclude from the analysis.

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

### -Forest
Specifies the name of the forest to analyze.

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

### -IncludeDomains
Specifies an array of domains to include in the analysis.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: Domain, Domains
Possible values:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Permissions
Specifies an array of permissions to analyze.

```yaml
Type: Array
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 3
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
