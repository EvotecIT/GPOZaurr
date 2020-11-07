function Find-GPOPassword {
    [cmdletBinding()]
    param(
        [string] $Path
    )
    #Convert XML in a String file
    [string]$XMLString = Get-Content -LiteralPath $Path
    #Check if Cpassword Exist in the file
    if ($XMLString.Contains("cpassword")) {
        #Take the Cpassword Value from XML String file
        [string]$Cpassword = [regex]::matches($XMLString, '(cpassword=).+?(?=\")')
        $Cpassword = $Cpassword.split('(\")')[1]
        #Check if Cpassword has a value
        if ($Cpassword.Length -gt 20 -and $Cpassword -notlike '*cpassword*') {
            $Mod = ($Cpassword.length % 4)
            switch ($Mod) {
                '1' { $Cpassword = $Cpassword.Substring(0, $Cpassword.Length - 1) }
                '2' { $Cpassword += ('=' * (4 - $Mod)) }
                '3' { $Cpassword += ('=' * (4 - $Mod)) }
            }
            $Base64Decoded = [Convert]::FromBase64String($Cpassword)
            $AesObject = [System.Security.Cryptography.AesCryptoServiceProvider]::new()
            #Use th AES Key
            [Byte[]] $AesKey = @(0x4e, 0x99, 0x06, 0xe8, 0xfc, 0xb6, 0x6c, 0xc9, 0xfa, 0xf4, 0x93, 0x10, 0x62, 0x0f, 0xfe, 0xe8, 0xf4, 0x96, 0xe8, 0x06, 0xcc, 0x05, 0x79, 0x90, 0x20, 0x9b, 0x09, 0xa4, 0x33, 0xb6, 0x6c, 0x1b)
            $AesIV = New-Object Byte[]($AesObject.IV.Length)
            $AesObject.IV = $AesIV
            $AesObject.Key = $AesKey
            $DecryptorObject = $AesObject.CreateDecryptor()
            [Byte[]] $OutBlock = $DecryptorObject.TransformFinalBlock($Base64Decoded, 0, $Base64Decoded.length)
            #Convert Hash variable in a String valute
            $Password = [System.Text.UnicodeEncoding]::Unicode.GetString($OutBlock)
        } else {
            $Password = ''
        }
    }
    $Password
}