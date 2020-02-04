if (-not ($ENV:APPVEYOR_PULL_REQUEST_NUMBER)) {

	#---------------------------------#
	# Push to Master Branch        #
	#---------------------------------#

	Try {

		Write-Host "Update Version number, push to GitHub..."

		git config --global core.safecrlf false

		git config --global credential.helper store

		Add-Content "$HOME\.git-credentials" "https://$($env:access_token):x-oauth-basic@github.com`n"

		git config --global user.email "$($env:github_email)"

		git config --global user.name "Pete Maan"

		Write-Host "Checking out branch: $($ENV:APPVEYOR_REPO_BRANCH)"
		git checkout master -q

		git add $(Join-Path -Path (Join-Path -Path "$env:APPVEYOR_BUILD_FOLDER" -ChildPath "$env:APPVEYOR_PROJECT_NAME") -ChildPath "$env:APPVEYOR_PROJECT_NAME.psd1")

		git status

		git remote -v

		git commit -s -m "Update Version"

		git status
		Write-Host "Push"
		git push --porcelain origin $($ENV:APPVEYOR_REPO_BRANCH)

		Write-Host "$($env:APPVEYOR_PROJECT_NAME) updated version pushed to GitHub." -ForegroundColor Cyan

	}

	Catch {

		Write-Host "Push to GitHub failed."
		throw $_

	}

}