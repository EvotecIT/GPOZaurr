---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Remove-GPOZaurrDuplicateObject
## SYNOPSIS
Removes duplicate Group Policy Objects (GPOs) identified by the Get-GPOZaurrDuplicateObject function.

## SYNTAX
### __AllParameterSets
```powershell
Remove-GPOZaurrDuplicateObject [[-LimitProcessing] <int>] [[-Forest] <string>] [[-ExcludeDomains] <string[]>] [[-IncludeDomains] <string[]>] [[-ExtendedForestInformation] <IDictionary>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function removes duplicate GPOs based on the criteria provided. It retrieves duplicate GPO objects using Get-GPOZaurrDuplicateObject and then attempts to remove them from the Active Directory.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Remove-GPOZaurrDuplicateObject -Forest "contoso.com" -IncludeDomains "domain1.com", "domain2.com" -ExcludeDomains "domain3.com" -LimitProcessing 5
```

Description:
Removes duplicate GPOs from the forest "contoso.com" for domains "domain1.com" and "domain2.com", excluding "domain3.com", processing only the first 5 duplicates.

## PARAMETERS

### -ExcludeDomains
Specifies an array of domains to exclude from the duplicate GPO removal process.

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

### -ExtendedForestInformation
Specifies additional information about the forest.

```yaml
Type: IDictionary
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Forest
Specifies the forest where the duplicate GPOs are located.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: ForestName
Possible values:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomains
Specifies an array of domains to include in the duplicate GPO removal process.

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

### -LimitProcessing
Specifies the maximum number of duplicate GPOs to process. Default is set to [int32]::MaxValue.

```yaml
Type: Int32
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 0
Default value: 2147483647
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
