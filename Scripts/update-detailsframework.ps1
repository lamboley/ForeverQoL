#requires -Version 5.1
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$archiveUrl = 'https://github.com/Tercioo/Details-Framework/archive/refs/heads/master.zip'
$destination = Join-Path $PSScriptRoot 'Libs\LibDFramework-1.0'
$tempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$staging = Join-Path $tempRoot ('ForeverQoL-DetailsFramework-' + [guid]::NewGuid().ToString('N'))

try {
    New-Item -ItemType Directory -Path $staging | Out-Null
    $archive = Join-Path $staging 'Details-Framework.zip'
    Write-Host 'Downloading Details Framework...'
    Invoke-WebRequest -Uri $archiveUrl -OutFile $archive -UseBasicParsing
    Expand-Archive -LiteralPath $archive -DestinationPath $staging

    $source = Join-Path $staging 'Details-Framework-master'
    if (-not (Test-Path -LiteralPath (Join-Path $source 'LibDFramework-1.0.toc') -PathType Leaf)) {
        throw 'The downloaded ZIP is missing Details-Framework-master\LibDFramework-1.0.toc. Check the repository archive layout.'
    }

    # Copy the contents so GitHub's wrapper directory does not become part of the addon path.
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    Get-ChildItem -LiteralPath $source -Force | Copy-Item -Destination $destination -Recurse -Force
    Write-Host "Details Framework installed in $destination"
}
catch {
    throw "Could not update Details Framework from ${archiveUrl}: $($_.Exception.Message)"
}
finally {
    $cleanupPath = [System.IO.Path]::GetFullPath($staging)
    if ([System.IO.Path]::GetDirectoryName($cleanupPath).TrimEnd('\') -ne $tempRoot.TrimEnd('\')) {
        throw "Refusing to clean up a directory outside the temporary folder: $cleanupPath"
    }
    if (Test-Path -LiteralPath $cleanupPath) {
        Remove-Item -LiteralPath $cleanupPath -Recurse -Force
    }
}
