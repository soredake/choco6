﻿$ErrorActionPreference = 'Stop';
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = "$toolsDir"

  url64          = 'https://github.com//NatronGitHub/Natron/releases/download/v2.5.0/Natron-2.5.0-Windows-x86_64.zip'
  checksum64     = '386dd68cb920e487c575917d3f657a55942d8c9a2468ed2ec6ce322ffcc5ab61'
  checksumType64 = 'sha256'
}

Install-ChocolateyZipPackage @packageArgs

# Don't create shims for any executables
$files = Get-ChildItem "$toolsDir" -Recurse -Include *.exe -Exclude "natron.exe"
foreach ($file in $files) {
  New-Item "$file.ignore" -type file -force | Out-Null
}

# Install start menu shortcut
$OSArchitectureWidth = Get-OSArchitectureWidth
$programs = [environment]::GetFolderPath([environment+specialfolder]::Programs)
$shortcutFilePath = Join-Path $programs "Natron.lnk"
$targetPath = (Get-ChildItem -Recurse "$toolsDir\Natron-*-Windows-x86_${OSArchitectureWidth}*\bin\natron.exe").fullName
Install-ChocolateyShortcut -shortcutFilePath $shortcutFilePath -targetPath $targetPath
