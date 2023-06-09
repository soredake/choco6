﻿import-module au

function global:au_BeforeUpdate {
    Remove-Item "$PSScriptRoot\tools\*.zip"
    Invoke-WebRequest -Uri $Latest.URL32 -OutFile "$PSScriptRoot\tools\$($Latest.FileName32)"

    $Latest.ChecksumType32 = 'sha256'
    $Latest.Checksum32     = Get-RemoteChecksum $Latest.URL32 -Algorithm $Latest.ChecksumType32
}

function global:au_GetLatest {
  $download_url = 'https://www.pkisolutions.com/download/16432/'
  # $regex        = '(SSL(-)?Verifier-v(?<Version>[\d\.-]+)\.zip)'
  $regex        = '(SSL[-\ ]?Verifier-v(?<Version>[\d\.-]+)\.exe)'

  $download = Invoke-WebRequest $download_url -UseBasicParsing
  $download.Headers.'Content-Disposition' -match $regex | Out-Null

  return @{
    Version = $matches.Version -Replace '-', '.'
    FileName32 = $matches[0]
    URL32 = $download_url
  }
}

function global:au_SearchReplace {
    @{
        "legal\VERIFICATION.txt"  = @{            
            "(?i)(x32: ).*"             = "`${1}$($Latest.URL32)"
            "(?i)(x64: ).*"             = "`${1}$($Latest.URL32)"
            "(?i)(checksum type:\s+).*" = "`${1}$($Latest.ChecksumType32)"
            "(?i)(checksum32:).*"       = "`${1} $($Latest.Checksum32)"
            "(?i)(checksum64:).*"       = "`${1} $($Latest.Checksum32)"
        }

        "tools\chocolateyinstall.ps1" = @{        
          "(?i)(^\s*file\s*=\s*`"[$]toolsDir\\)(.*)`"" = "`${1}$($Latest.FileName32)`""
           "(^.*SSL[-\ ]?Verifier-v)[\d\.-]+(\.exe)"      = "`${1}$($Latest.Version)`${2}"            
        }
    }
}

update -ChecksumFor none -noCheckUrl