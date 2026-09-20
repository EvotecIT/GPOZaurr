---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Invoke-GPOZaurrContent
## SYNOPSIS
Invokes GPOZaurrContent function to retrieve Group Policy Objects information.

## SYNTAX
### Default (Default)
```powershell
Invoke-GPOZaurrContent [-Forest <string>] [-ExcludeDomains <string[]>] [-IncludeDomains <string[]>] [-ExtendedForestInformation <IDictionary>] [-Type <string[]>] [-Splitter <string>] [-FullObjects] [-OutputType <string[]>] [-OutputPath <string>] [-Open] [-Online] [-CategoriesOnly] [-SingleObject] [-SkipNormalize] [-SkipCleanup] [-Extended] [-GPOName <string[]>] [-GPOGUID <string[]>] [<CommonParameters>]
```

### Local
```powershell
Invoke-GPOZaurrContent [-GPOPath <string>] [-Type <string[]>] [-Splitter <string>] [-FullObjects] [-OutputType <string[]>] [-OutputPath <string>] [-Open] [-Online] [-CategoriesOnly] [-SingleObject] [-SkipNormalize] [-SkipCleanup] [-Extended] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves Group Policy Objects information based on the specified parameters. It can search for GPOs in a forest, exclude specific domains, include specific domains, and provide extended forest information.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Invoke-GPOZaurrContent -Forest "Contoso" -IncludeDomains "Domain1", "Domain2" -Type "Security" -OutputType "HTML" -OutputPath "C:\Reports\GPOReport.html"
Retrieves security-related Group Policy Objects information for the specified domains and saves the output as an HTML file.
```


### EXAMPLE 2
```powershell
PS > Invoke-GPOZaurrContent -GPOPath "CN={31B2F340-016D-11D2-945F-00C04FB984F9},CN=Policies,CN=System,DC=Contoso,DC=com" -Type "All" -OutputType "Object"
Retrieves all information for a specific Group Policy Object and outputs the result as an object.
```


### EXAMPLE 3
```powershell
PS > Invoke-GPOZaurrContent -GPOName "Group Policy Test" -SingleObject | ConvertTo-Json -Depth 3
Quickly view GPO settings by name in JSON format for easy inspection.
```


## PARAMETERS

### -CategoriesOnly
Indicates whether to retrieve only categories.

```yaml
Type: SwitchParameter
Parameter Sets: Default, Local
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDomains
Specifies an array of domains to exclude from the search.

```yaml
Type: String[]
Parameter Sets: Default
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Extended
Specifies the extended switch.

```yaml
Type: SwitchParameter
Parameter Sets: Default, Local
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedForestInformation
Specifies additional information about the forest.

```yaml
Type: IDictionary
Parameter Sets: Default
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Forest
Specifies the forest name to search for Group Policy Objects.

```yaml
Type: String
Parameter Sets: Default
Aliases: ForestName
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FullObjects
Indicates whether to retrieve full objects.

```yaml
Type: SwitchParameter
Parameter Sets: Default, Local
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOGUID
Specifies one or more values for gpoguid.

```yaml
Type: String[]
Parameter Sets: Default
Aliases: None
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
Parameter Sets: Default
Aliases: Name
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOPath
Specifies the path to a specific Group Policy Object.

```yaml
Type: String
Parameter Sets: Local
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
Parameter Sets: Default
Aliases: Domain, Domains
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Online
Indicates whether to retrieve information online.

```yaml
Type: SwitchParameter
Parameter Sets: Default, Local
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Open
Indicates whether to open the output after retrieval.

```yaml
Type: SwitchParameter
Parameter Sets: Default, Local
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputPath
Specifies the path to save the output.

```yaml
Type: String
Parameter Sets: Default, Local
Aliases: None
Possible values:

Required: False
Position: named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputType
Specifies the type of output (HTML or Object).

```yaml
Type: String[]
Parameter Sets: Default, Local
Aliases: None
Possible values: HTML, Object

Required: False
Position: named
Default value: Object
Accept pipeline input: False
Accept wildcard characters: False
```

### -SingleObject
Indicates whether to retrieve a single object.

```yaml
Type: SwitchParameter
Parameter Sets: Default, Local
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipCleanup
Specifies the skip cleanup switch.

```yaml
Type: SwitchParameter
Parameter Sets: Default, Local
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipNormalize
Indicates whether to skip normalization.

```yaml
Type: SwitchParameter
Parameter Sets: Default, Local
Aliases: None
Possible values:

Required: False
Position: named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Splitter
Specifies the delimiter to use for splitting information.

```yaml
Type: String
Parameter Sets: Default, Local
Aliases: None
Possible values:

Required: False
Position: named
Default value: [System.Environment]::NewLine
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Specifies the type of information to retrieve.

```yaml
Type: String[]
Parameter Sets: Default, Local
Aliases: None
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
