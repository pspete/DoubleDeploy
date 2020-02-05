<#---------------------------------
Auto-publish changes to master branch as a new module version in the PSGallery.
- Only publish if build version is greater than 1.0
- Skip Auto-publish with specific commit message of "Manual Deployment"
---------------------------------#>


if (-not ($ENV:APPVEYOR_PULL_REQUEST_NUMBER)) {

	Write-Host "Deploy Process: PowerShell Gallery" -ForegroundColor Yellow

	<#---------------------------------#>
	<# If Not a PR                     #>
	<#---------------------------------#>
	If ($ENV:APPVEYOR_REPO_BRANCH -eq 'master') {

		<# Master Branch     #>

		If ($env:APPVEYOR_BUILD_VERSION -ge "1.0.0") {

			<# Version 1.0+     #>

			If ($ENV:APPVEYOR_REPO_COMMIT_MESSAGE -eq "Manual Deployment") {

				<# Manual Deploy to PSGallery #>
				Write-Host "Finished testing of branch: $env:APPVEYOR_REPO_BRANCH" -ForegroundColor Cyan
				Write-Host "Manual Deployment to PSGallery Required" -ForegroundColor Cyan
				Write-Host "Exiting" -ForegroundColor Cyan
				exit;

			}
			Else {

				<#---------------------------------#
		 		# Publish to PS Gallery            #
		 		#----------------------------------#>

				Try {

					Write-Host 'Publish to Powershell Gallery...'

					$ModulePath = Join-Path $env:APPVEYOR_BUILD_FOLDER $env:APPVEYOR_PROJECT_NAME

					Write-Host "Publishing: $ModulePath"

					Publish-Module -Path $ModulePath -NuGetApiKey $($env:psgallery_key) -SkipAutomaticTags -Confirm:$false -ErrorAction Stop -Force

					Write-Host "$($env:APPVEYOR_PROJECT_NAME) published." -ForegroundColor Cyan

				}
				Catch {

					Write-Host "Publish Failed." -ForegroundColor Red
					throw $_

				}
				Finally {
					exit;
				}

			}

		}
		Else {

			<# Less Than version 1.0 - No Deployment   #>
			Write-Host "Nothing to Deploy - Exiting" -ForegroundColor Cyan
			exit;

		}

	}
	Else {

		<# Not Master Branch - No Deployment      #>

		Write-Host "Finished testing of branch: $env:APPVEYOR_REPO_BRANCH - Exiting" -ForegroundColor Cyan
		exit;

	}

}
Else {

	Write-Host "Skipping Deploy Process: PowerShell Gallery" -ForegroundColor Yellow

}