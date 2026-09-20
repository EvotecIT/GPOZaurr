---
external help file: GPOZaurr-help.xml
Module Name: GPOZaurr
online version: https://github.com/EvotecIT/GPOZaurr
schema: 2.0.0
---
# Invoke-GPOZaurrSupport
## SYNOPSIS
Invokes GPOZaurrSupport function to retrieve Group Policy information.

## SYNTAX
### __AllParameterSets
```powershell
Invoke-GPOZaurrSupport [[-Type] <string>] [[-ComputerName] <string>] [[-UserName] <string>] [[-Path] <string>] [[-Splitter] <string>] [-PreventShow] [-Online] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves Group Policy information using either HTML, XML, or Object format. It can be run locally or on a remote computer.

## EXAMPLES

### EXAMPLE 1
```powershell
PS > Invoke-GPOZaurrSupport -Type HTML -ComputerName "RemoteComputer" -UserName "Admin" -Path (Join-Path $env:TEMP 'GPOReport.html')
Retrieves Group Policy information in HTML format from a remote computer and saves it to a specified path.
```


### EXAMPLE 2
```powershell
PS > Invoke-GPOZaurrSupport -Type XML -Path (Join-Path $env:TEMP 'GPOReport.xml') -Online
Retrieves the latest Group Policy information in XML format and saves it to a specified path.
```


## PARAMETERS

### -ComputerName
Specifies the name of the remote computer to retrieve Group Policy information from.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: Server
Possible values:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Online
Runs the function online to retrieve the latest Group Policy information.

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

### -Path
Specifies the path to save the output file. If not provided, a temporary file will be created.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PreventShow
Prevents displaying the output in the console.

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

### -Splitter
Specifies the delimiter for splitting output data. Default is a new line.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values:

Required: False
Position: 4
Default value: [System.Environment]::NewLine
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Specifies the type of output format. Valid values are 'NativeHTML', 'HTML', 'XML', or 'Object'. Default is 'HTML'.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: None
Possible values: NativeHTML, HTML, XML, Object

Required: False
Position: 0
Default value: HTML
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserName
Specifies the username to run the function as on the remote computer.

```yaml
Type: String
Parameter Sets: __AllParameterSets
Aliases: User
Possible values:

Required: False
Position: 2
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
