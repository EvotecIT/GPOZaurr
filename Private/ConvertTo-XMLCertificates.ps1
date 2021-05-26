function ConvertTo-XMLCertificates {
    [cmdletBinding()]
    param(
        [PSCustomObject] $GPO,
        [string[]] $Category,
        [switch] $SingleObject
    )
    $SkipNames = ('Name', 'LocalName', 'NamespaceURI', 'Prefix', 'NodeType', 'ParentNode', 'OwnerDocument', 'IsEmpty', 'Attributes', 'HasAttributes', 'SchemaInfo', 'InnerXml', 'InnerText', 'NextSibling', 'PreviousSibling', 'ChildNodes', 'FirstChild', 'LastChild', 'HasChildNodes', 'IsReadOnly', 'OuterXml', 'BaseURI', 'PreviousText')
    if ($SingleObject) {
        $CreateGPO = [ordered]@{
            DisplayName = $GPO.DisplayName
            DomainName  = $GPO.DomainName
            GUID        = $GPO.GUID
            GpoType     = $GPO.GpoType
            Count       = 0
            Settings    = $null
        }
        [Array] $CreateGPO['Settings'] = foreach ($Setting in $GPO.DataSet) {
            $SettingName = $Setting.Name -split ":"
            $MySettings = [ordered] @{
                CreatedTime         = $GPO.CreatedTime         # : 06.06.2020 18:03:36
                ModifiedTime        = $GPO.ModifiedTime        # : 17.06.2020 16:08:10
                ReadTime            = $GPO.ReadTime            # : 13.08.2020 10:15:37
                SecurityDescriptor  = $GPO.SecurityDescriptor  # : SecurityDescriptor
                FilterDataAvailable = $GPO.FilterDataAvailable # : True
            }
            $Name = $SettingName[1]
            #$Name = Format-ToTitleCase -Text $Setting.Name -RemoveWhiteSpace -RemoveChar ',', '-', "'", '\(', '\)', ':'
            $MySettings['Name'] = $Name # $Setting.Name

            ConvertTo-XMLNested -CreateGPO $MySettings -Setting $Setting -SkipNames $SkipNames #-Name $Name

            if ($MySettings.Data) {
                $bytes = $MySettings.Data -replace '\r?\n' -split '(?<=\G.{2})' -ne '' -replace '^', '0x' -as [byte[]]
                $CertificateData = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($bytes)

                $MySettings['NotBefore'] = $CertificateData.NotBefore
                $MySettings['NotAfter'] = $CertificateData.NotAfter
                $MySettings['HasPrivateKey'] = $CertificateData.HasPrivateKey
                $MySettings['Thumbprint'] = $CertificateData.Thumbprint
                $MySettings['SerialNumber'] = $CertificateData.SerialNumber
                $MySettings['Version'] = $CertificateData.Version
                $MySettings['Handle'] = $CertificateData.Handle
                $MySettings['SignatureAlgorithm'] = $CertificateData.SignatureAlgorithm.Value
                $MySettings['SignatureAlgorithmName'] = $CertificateData.SignatureAlgorithm.FriendlyName
                $MySettings['KeyUsages'] = $CertificateData.Extensions.KeyUsages
                $MySettings.Remove('Data')
            }

            [PSCustomObject] $MySettings
        }

        $CreateGPO['Count'] = $CreateGPO['Settings'].Count
        $CreateGPO['Linked'] = $GPO.Linked
        $CreateGPO['LinksCount'] = $GPO.LinksCount
        $CreateGPO['Links'] = $GPO.Links
        [PSCustomObject] $CreateGPO
    } else {
        foreach ($Setting in $GPO.DataSet) {
            $CreateGPO = [ordered]@{
                DisplayName = $GPO.DisplayName
                DomainName  = $GPO.DomainName
                GUID        = $GPO.GUID
                GpoType     = $GPO.GpoType
            }
            $SettingName = $Setting.Name -split ":"
            $CreateGPO['CreatedTime'] = $GPO.CreatedTime         # : 06.06.2020 18:03:36
            $CreateGPO['ModifiedTime'] = $GPO.ModifiedTime        # : 17.06.2020 16:08:10
            $CreateGPO['ReadTime'] = $GPO.ReadTime            # : 13.08.2020 10:15:37
            $CreateGPO['SecurityDescriptor'] = $GPO.SecurityDescriptor  # : SecurityDescriptor
            $CreateGPO['FilterDataAvailable'] = $GPO.FilterDataAvailable # : True

            $Name = $SettingName[1]
            $CreateGPO['Name'] = $Name # $Setting.Name

            ConvertTo-XMLNested -CreateGPO $CreateGPO -Setting $Setting -SkipNames $SkipNames #-Name $Name

            if ($CreateGPO.Data) {
                $bytes = $CreateGPO.Data -replace '\r?\n' -split '(?<=\G.{2})' -ne '' -replace '^', '0x' -as [byte[]]
                $CertificateData = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($bytes)

                $CreateGPO['NotBefore'] = $CertificateData.NotBefore
                $CreateGPO['NotAfter'] = $CertificateData.NotAfter
                $CreateGPO['HasPrivateKey'] = $CertificateData.HasPrivateKey
                $CreateGPO['Thumbprint'] = $CertificateData.Thumbprint
                $CreateGPO['SerialNumber'] = $CertificateData.SerialNumber
                $CreateGPO['Version'] = $CertificateData.Version
                $CreateGPO['Handle'] = $CertificateData.Handle
                $CreateGPO['SignatureAlgorithm'] = $CertificateData.SignatureAlgorithm.Value
                $CreateGPO['SignatureAlgorithmName'] = $CertificateData.SignatureAlgorithm.FriendlyName
                $CreateGPO['KeyUsages'] = $CertificateData.Extensions.KeyUsages
                $CreateGPO.Remove('Data')
            }
            $CreateGPO['Filters'] = $Setting.Filters
            $CreateGPO['Linked'] = $GPO.Linked
            $CreateGPO['LinksCount'] = $GPO.LinksCount
            $CreateGPO['Links'] = $GPO.Links
            [PSCustomObject] $CreateGPO
        }
    }
}