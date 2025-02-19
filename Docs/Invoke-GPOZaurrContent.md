---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version:
schema: 2.0.0
---

# Invoke-GPOZaurrContent

## SYNOPSIS
Invokes GPOZaurrContent function to retrieve Group Policy Objects information.

## SYNTAX

### Default (Default)
```
Invoke-GPOZaurrContent [-Forest <String>] [-ExcludeDomains <String[]>] [-IncludeDomains <String[]>]
 [-ExtendedForestInformation <IDictionary>] [-Type <String[]>] [-Splitter <String>] [-FullObjects]
 [-OutputType <String[]>] [-OutputPath <String>] [-Open] [-Online] [-CategoriesOnly] [-SingleObject]
 [-SkipNormalize] [-SkipCleanup] [-Extended] [-GPOName <String[]>] [-GPOGUID <String[]>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Local
```
Invoke-GPOZaurrContent [-GPOPath <String>] [-Type <String[]>] [-Splitter <String>] [-FullObjects]
 [-OutputType <String[]>] [-OutputPath <String>] [-Open] [-Online] [-CategoriesOnly] [-SingleObject]
 [-SkipNormalize] [-SkipCleanup] [-Extended] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves Group Policy Objects information based on the specified parameters.
It can search for GPOs in a forest, exclude specific domains, include specific domains, and provide extended forest information.

## EXAMPLES

### EXAMPLE 1
```
Invoke-GPOZaurrContent -Forest "Contoso" -IncludeDomains "Domain1", "Domain2" -Type "Security" -OutputType "HTML" -OutputPath "C:\Reports\GPOReport.html"
Retrieves security-related Group Policy Objects information for the specified domains and saves the output as an HTML file.
```

### EXAMPLE 2
```
Invoke-GPOZaurrContent -GPOPath "CN={31B2F340-016D-11D2-945F-00C04FB984F9},CN=Policies,CN=System,DC=Contoso,DC=com" -Type "All" -OutputType "Object"
Retrieves all information for a specific Group Policy Object and outputs the result as an object.
```

### EXAMPLE 3
```
Invoke-GPOZaurrContent -GPOName "Group Policy Test" -SingleObject | ConvertTo-Json -Depth 3
Quickly view GPO settings by name in JSON format for easy inspection.
```

## PARAMETERS

### -Forest
Specifies the forest name to search for Group Policy Objects.

```yaml
Type: String
Parameter Sets: Default
Aliases: ForestName

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDomains
Specifies an array of domains to exclude from the search.

```yaml
Type: String[]
Parameter Sets: Default
Aliases:

Required: False
Position: Named
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

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedForestInformation
Specifies additional information about the forest.

```yaml
Type: IDictionary
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOPath
Specifies the path to a specific Group Policy Object.

```yaml
Type: String
Parameter Sets: Local
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Specifies the type of information to retrieve.

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

### -Splitter
Specifies the delimiter to use for splitting information.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: [System.Environment]::NewLine
Accept pipeline input: False
Accept wildcard characters: False
```

### -FullObjects
Indicates whether to retrieve full objects.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputType
Specifies the type of output (HTML or Object).

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Object
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputPath
Specifies the path to save the output.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Open
Indicates whether to open the output after retrieval.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Online
Indicates whether to retrieve information online.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -CategoriesOnly
Indicates whether to retrieve only categories.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SingleObject
When enabled, returns a single consolidated object per GPO rather than multiple objects for each setting. For example, with drive mappings, instead of returning separate objects for each mapped drive in a GPO, it will return one object containing all drive mappings for that GPO. This affects how the data is structured in the output reports.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipNormalize
Indicates whether to skip normalization.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipCleanup
Indicates whether to skip cleanup of the output hashtable. When enabled, empty values in the output hashtable are preserved rather than being removed via Remove-EmptyValue. This parameter affects the final processing step before returning GPO analysis results.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Extended
When enabled, returns the complete output hashtable containing all GPO analysis data, including both the processed reports and raw categories. By default, only the processed reports are returned. This parameter is useful for debugging or when you need access to the underlying data structure.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOName
Specifies the name of the Group Policy Object to retrieve. The alias of this parameter is `Name`.

```yaml
Type: String[]
Parameter Sets: Default
Aliases: Name

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GPOGUID
Specifies one or more Group Policy Object GUIDs to retrieve. This parameter allows you to target specific GPOs by their unique identifier rather than display name.


```yaml
Type: String[]
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
Specifies the action to take when progress is reported.

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

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

## RELATED LINKS
