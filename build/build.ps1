#---------------------------------#
# Header                          #
#---------------------------------#
Write-Host 'Build Information:' -ForegroundColor Yellow

#Get current module version from manifest
$ManifestPath = Join-Path "$pwd" $(Join-Path "$env:APPVEYOR_PROJECT_NAME" "$env:APPVEYOR_PROJECT_NAME.psd1")
$CurrentVersion = (Import-PowerShellDataFile $ManifestPath).ModuleVersion

#display module information
Write-Host "ModuleName       : $env:APPVEYOR_PROJECT_NAME"
Write-Host "Build version    : $env:APPVEYOR_BUILD_VERSION"
Write-Host "Manifest version : $CurrentVersion"
Write-Host "Author           : $env:APPVEYOR_REPO_COMMIT_AUTHOR"
Write-Host "Branch           : $env:APPVEYOR_REPO_BRANCH"
Write-Host "Build Folder     : $env:APPVEYOR_BUILD_FOLDER"

If ([System.Version]$($env:APPVEYOR_BUILD_VERSION) -le [System.Version]$CurrentVersion) {

	throw "Build Version Not Greater than Current Version"

}
Else {

	Try {

		#---------------------------------#
		# BuildScript                     #
		#---------------------------------#
		#---------------------------------#
		# Update module manifest          #
		#---------------------------------#
		Write-Host "Updating Manifest Version to $env:APPVEYOR_BUILD_VERSION" -ForegroundColor Cyan

		#Replace version in manifest with build version from appveyor
		((Get-Content $ManifestPath).replace("= '$($currentVersion)'", "= '$($env:APPVEYOR_BUILD_VERSION)'")) |
		Set-Content $ManifestPath -ErrorAction Stop

		<#-- Package Version Release    --#>

		$Directory = New-Item -ItemType Directory -Path "Release\$($env:APPVEYOR_PROJECT_NAME)\$($env:APPVEYOR_BUILD_VERSION)" -Force -ErrorAction Stop
		$OutputArchive = "$($env:APPVEYOR_PROJECT_NAME)-v$($env:APPVEYOR_BUILD_VERSION).zip"
		$ReleaseSource = $(Resolve-Path .\$env:APPVEYOR_PROJECT_NAME)
		Copy-Item -Path $ReleaseSource -Recurse -Destination $($Directory.Fullname) -Force -ErrorAction Stop
		Compress-Archive $(Split-Path -Parent (Split-Path -Parent $Directory)) -DestinationPath .\$OutputArchive -ErrorAction Stop

		Write-Host "Release Package  : $OutputArchive"
		Push-AppveyorArtifact .\$OutputArchive -FileName $OutputArchive -DeploymentName "($env:APPVEYOR_PROJECT_NAME)-latest"
	}

	Catch {

		throw $_

	}

}