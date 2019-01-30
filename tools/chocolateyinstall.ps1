﻿$ErrorActionPreference = 'Stop';
$toolsDir       = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$filename       = 'mongodb-win32-x86_64-2008plus-ssl-4.0.5-signed.msi'
$url64          = "$toolsDir\$filename"
$checksum64     = 'e2ac83cfee3350012a641405ce5ba5c3cffe3f8d1a0cd5e0eb3e332246a9cc20'
$checksumType64 = 'sha256'
$silentArgs     = 'ADDLOCAL="Server,ServerService,Router,Client,MonitoringTools,ImportExportTools,MiscellaneousTools" /qn /norestart'
$dataPath       = "$env:PROGRAMDATA\MongoDB\data\db"
$logPath        = "$env:PROGRAMDATA\MongoDB\log"
$installLocation="C:\MongoDB"
 
# Allow the user to specify the data and log path, falling back to sensible defaults
$pp = Get-PackageParameters
 
if($pp.dataPath) {
    $dataPath = $pp.dataPath
}
if($pp.logPath) {
    $logPath = $pp.logPath
}
 
# Create directories
New-Item -ItemType Directory $dataPath -ErrorAction SilentlyContinue
New-Item -ItemType Directory $logPath -ErrorAction SilentlyContinue
New-Item -ItemType Directory $installLocation -ErrorAction SilentlyContinue
 
$silentArgs += " MONGO_DATA_PATH=`"$dataPath`" "
$silentArgs += " MONGO_LOG_PATH=`"$logPath`" "
$silentArgs += " INSTALLLOCATION=`"$installLocation`" "
 
$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  unzipLocation  = $toolsDir
  fileType       = 'msi'
  url64bit      = $url64
  checksum64    = $checksum64
  checksumType64= $checksumType64
  softwareName   = 'MongoDB *'
  silentArgs     = $silentArgs
  validExitCodes = @(0,3010)
}
 
Install-ChocolateyPackage @packageArgs
 
# start the service
Start-Service -Name MongoDB -ErrorAction SilentlyContinue
 
# service status
if((Get-Service -Name MongoDB).Status -ne "Running") {
  Write-Warning "  * MongoDB service is currenty not running, this could be due to an required reboot of one of the dependencies"
}