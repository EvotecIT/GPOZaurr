<p align="center">
  <a href="https://www.powershellgallery.com/packages/GPOZaurr"><img src="https://img.shields.io/powershellgallery/v/GPOZaurr.svg"></a>
  <a href="https://www.powershellgallery.com/packages/GPOZaurr"><img src="https://img.shields.io/powershellgallery/vpre/GPOZaurr.svg?label=powershell%20gallery%20preview&colorB=yellow"></a>
  <a href="https://github.com/EvotecIT/GPOZaurr"><img src="https://img.shields.io/github/license/EvotecIT/GPOZaurr.svg"></a>
</p>

<p align="center">
  <a href="https://www.powershellgallery.com/packages/GPOZaurr"><img src="https://img.shields.io/powershellgallery/p/GPOZaurr.svg"></a>
  <a href="https://github.com/EvotecIT/GPOZaurr"><img src="https://img.shields.io/github/languages/top/evotecit/GPOZaurr.svg"></a>
  <a href="https://github.com/EvotecIT/GPOZaurr"><img src="https://img.shields.io/github/languages/code-size/evotecit/GPOZaurr.svg"></a>
  <a href="https://www.powershellgallery.com/packages/GPOZaurr"><img src="https://img.shields.io/powershellgallery/dt/GPOZaurr.svg"></a>
</p>

<p align="center">
  <a href="https://twitter.com/PrzemyslawKlys"><img src="https://img.shields.io/twitter/follow/PrzemyslawKlys.svg?label=Twitter%20%40PrzemyslawKlys&style=social"></a>
  <a href="https://evotec.xyz/hub"><img src="https://img.shields.io/badge/Blog-evotec.xyz-2A6496.svg"></a>
  <a href="https://www.linkedin.com/in/pklys"><img src="https://img.shields.io/badge/LinkedIn-pklys-0077B5.svg?logo=LinkedIn"></a>
</p>

# GPOZaurr

## To install

```powershell
Install-Module -Name GPOZaurr -AllowClobber -Force
```

Force and AllowClobber aren't necessary, but they do skip errors in case some appear.

## And to update

```powershell
Update-Module -Name GPOZaurr
```

That's it. Whenever there's a new version, you run the command, and you can enjoy it. Remember that you may need to close, reopen PowerShell session if you have already used module before updating it.

**The essential thing** is if something works for you on production, keep using it till you test the new version on a test computer. I do changes that may not be big, but big enough that auto-update may break your code. For example, small rename to a parameter and your code stops working! Be responsible!

## Changelog

- 0.0.37 - 16.06.2020
  - Updates to `Invoke-GPOZaurrPermission` with new parameterset `Level`
  - Updates to `Get-GPOZaurrLinkSummary`
- 0.0.36 - 15.06.2020
  - Initial release
