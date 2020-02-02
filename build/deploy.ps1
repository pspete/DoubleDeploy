#---------------------------------#
# Header                          #
#---------------------------------#
Write-Host "Deploy Process:" -ForegroundColor Yellow

if (-not ($ENV:APPVEYOR_PULL_REQUEST_NUMBER)) {

	#---------------------------------#
	# Push to Master Branch        #
	#---------------------------------#

	Try {

		Write-Host "Update Version number, push to GitHub..."

		git config --global core.safecrlf false

		git config --global credential.helper store

		Add-Content "$HOME\.git-credentials" "https://$($env:access_token):x-oauth-basic@github.com`n"

		git config --global user.email "pete.maan+github@gmail.com"

		git config --global user.name "Pete Maan"

		Write-Host "Checking out branch: $($ENV:APPVEYOR_REPO_BRANCH)"
		git checkout -q master

		Write-Host "Staging Change"
		git add $(Join-Path -Path (Join-Path -Path "$env:APPVEYOR_BUILD_FOLDER" -ChildPath "$env:APPVEYOR_PROJECT_NAME") -ChildPath "$env:APPVEYOR_PROJECT_NAME.psd1")

		Write-Host "Status"
		git status
		Write-Host "Commit"
		git commit -s -m "Update Version"
		Write-Host "Push"
		git push origin master --verbose

		Write-Host "$($env:APPVEYOR_PROJECT_NAME) updated version pushed to GitHub." -ForegroundColor Cyan

	}

	Catch {

		Write-Host "Push to GitHub failed."
		throw $_

	}

	#---------------------------------#
	# Publish to PS Gallery           #
	#---------------------------------#

	If ($ENV:APPVEYOR_REPO_COMMIT_MESSAGE -eq "Manual Deployment") {

		Write-Host "Finished testing of branch: $env:APPVEYOR_REPO_BRANCH"
		Write-Host "Manual Deployment to PSGallery Required"
		Write-Host "Exiting"
		exit;

	}

	Elseif (($ENV:APPVEYOR_REPO_BRANCH -eq 'master') -and ($env:APPVEYOR_BUILD_VERSION -ge "1.0.0")) {

		Try {

			Write-Host 'Publish to Powershell Gallery...'

			$ModulePath = Join-Path $env:APPVEYOR_BUILD_FOLDER $env:APPVEYOR_PROJECT_NAME

			Write-Host "Publishing: $ModulePath"

			Publish-Module -Path $ModulePath -NuGetApiKey $($env:psgallery_key) -SkipAutomaticTags -Confirm:$false -ErrorAction Stop -Force

			Write-Host "$($env:APPVEYOR_PROJECT_NAME) published." -ForegroundColor Cyan

		}
		Catch {

			Write-Warning "Publish Failed."
			throw $_

		}
		Finally {
			exit;
		}

	}

	Else {

		Write-Host "Finished testing of branch: $env:APPVEYOR_REPO_BRANCH - Exiting"
		exit;

	}

}

Else {

	Write-Host "Nothing to Deploy - Exiting"
	exit;

}