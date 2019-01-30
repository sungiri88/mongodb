$ErrorActionPreference = 'Stop'
 
$packageName         = 'mongodb'
$softwareNamePattern = 'MongoDB 4.0.5*'
 
 
[array] $key = Get-UninstallRegistryKey $softwareNamePattern
if ($key.Count -eq 1) {
    $key | ForEach-Object {
        $packageArgs = @{
            packageName            = $packageName
            silentArgs             = '/quiet /qn /norestart'
            fileType               = 'EXE'
            validExitCodes         = @(0,3010)
            file                   = ''
        }
	$packageArgs['file'] = "$($_.UninstallString)"

	$fileStringSplit = $packageArgs['file'] -split '\s+(?=(?:[^"]|"[^"]*")*$)'

	if($fileStringSplit.Count -gt 1) {
  	$packageArgs['file'] = $fileStringSplit[0]
  	$env:chocolateyInstallArguments += " $($fileStringSplit[1..($fileStringSplit.Count-1)])"
	}

	Uninstall-ChocolateyPackage @packageArgs
    }
}
elseif ($key.Count -eq 0) {
    Write-Warning "$packageName has already been uninstalled by other means."
}
elseif ($key.Count -gt 1) {
    Write-Warning "$key.Count matches found!"
    Write-Warning "To prevent accidental data loss, no programs will be uninstalled."
    Write-Warning "Please alert package maintainer the following keys were matched:"
    $key | ForEach-Object {Write-Warning "- $_.DisplayName"}
}