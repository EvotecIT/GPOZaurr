Import-Module "$PSScriptRoot\..\GPoZaurr.psd1" -Force

# Extracts CSE from registry
$AllRegistryExtensions = Find-CSExtension
$AllRegistryExtensions | Format-Table

# Uses Hashtable - similar to above but much faster
$AllRegistryExtensionsFaster = foreach ($CSE in $AllRegistryExtensions) {
    ConvertFrom-CSExtension -CSE $CSE.CSE
}
$AllRegistryExtensionsFaster | Format-Table

# With this we can find out if we're missing anything in hashtable so we can update code if nessecary
$MissingEntries = foreach ($CSE in $AllRegistryExtensions) {
    $Output = ConvertFrom-CSExtension -CSE $CSE.CSE
    if ($Output.CSE -eq $Output.Description) {
        # THis means the value in hashtable is missing this entry and we should add it
        $CSE
    }
}
$MissingEntries | Format-Table