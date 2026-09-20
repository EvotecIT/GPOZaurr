---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Get-GPOZaurrOrganizationalUnit
## SYNOPSIS
Retrieves information about Group Policy Objects (GPOs) linked to Organizational Units (OUs) within a specified forest.

## SYNTAX
### __AllParameterSets
```powershell
Get-GPOZaurrOrganizationalUnit [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-IncludeDomains] <string[]>] [[-ExtendedForestInformation] <IDictionary>] [[-Option] <string[]>] [[-ExcludeOrganizationalUnit] <string[]>] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves detailed information about the GPOs linked to OUs within a specified forest. It provides information on linked GPOs, objects within OUs, and counts of objects at different levels.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Get-GPOZaurrOrganizationalUnit -Forest "contoso.com" -IncludeDomains "child.contoso.com" -ExcludeDomains "test.contoso.com" -ExtendedForestInformation $ExtendedInfo -Option "OK" -ExcludeOrganizationalUnit "OU=Test,DC=contoso,DC=com"
Retrieves information about GPOs linked to OUs in the "contoso.com" forest, including the "child.contoso.com" domain, excluding the "test.contoso.com" domain, with additional forest information, performing the 'OK' action, and excluding the "OU=Test,DC=contoso,DC=com" OU.
```


## PARAMETERS

### -ExcludeDomains
Specifies an array of domains to exclude from processing.

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

### -ExcludeOrganizationalUnit
Specifies an array of OUs to exclude from processing.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: ExcludeOU, Exclusions
Possible values:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedForestInformation
Specifies additional information about the forest.

```yaml
Type: IDictionary
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Forest
Specifies the name of the forest to retrieve information from.

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
Specifies an array of domains to include for processing.

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

### -Option
Specifies the action to perform on the retrieved data. Valid values are 'OK', 'Unlink', or 'Delete'.

```yaml
Type: String[]
Parameter Sets: __AllParameterSets
Aliases: None
Possible values: OK, Unlink, Delete

Required: False
Position: 4
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
