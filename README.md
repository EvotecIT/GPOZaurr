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

Group Policy Eater is a PowerShell module that aims to gather information about Group Policies but also allows fixing issues that you may find in them.

To understand the usage I've created blog post you may find useful

- [The only command you will ever need to understand and fix your Group Policies (GPO)](https://evotec.xyz/the-only-command-you-will-ever-need-to-understand-and-fix-your-group-policies-gpo/)

## Installing

GPOZaurr requires `RSAT` installed to provide results. If you don't have them you can install them as below. Keep in mind it also installs GUI tools so it shouldn't be installed on user workstations.

```powershell
# Windows 10 Latest
Add-WindowsCapability -Online -Name 'Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0'
Add-WindowsCapability -Online -Name 'Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0'
```

Finally just install module:

```powershell
Install-Module -Name GPOZaurr -AllowClobber -Force
```

Force and AllowClobber aren't necessary, but they do skip errors in case some appear.

## Updating

```powershell
Update-Module -Name GPOZaurr
```

That's it. Whenever there's a new version, you run the command, and you can enjoy it. Remember that you may need to close, reopen PowerShell session if you have already used module before updating it.

**The essential thing** is if something works for you on production, keep using it till you test the new version on a test computer. I do changes that may not be big, but big enough that auto-update may break your code. For example, small rename to a parameter and your code stops working! Be responsible!