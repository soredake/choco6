﻿$ErrorActionPreference = 'Stop'
# Install start menu shortcut
$programs = [environment]::GetFolderPath([environment+specialfolder]::Programs)
$shortcutFilePath = Join-Path $programs "Dont Sleep.lnk"
if (Test-Path $shortcutFilePath) { Remove-Item $shortcutFilePath }
