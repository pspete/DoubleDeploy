<#---------------------------------
Update version number on GitHub to match build version
---------------------------------#>


if (-not ($ENV:APPVEYOR_PULL_REQUEST_NUMBER)) {

	Write-Host "Deploy Process: GitHub Repository" -ForegroundColor Yellow

	<#---------------------------------#>
	<# If Not a PR                     #>
	<# Push psd1 file to ORIGIN Branch #>
	<#---------------------------------#>

	Try {

		Write-Host "Push Updated $($env:APPVEYOR_PROJECT_NAME).psd1 to GitHub..." -ForegroundColor Yellow

		git config --global core.safecrlf false

		git config --global credential.helper store

		Add-Content "$HOME\.git-credentials" "https://$($env:access_token):x-oauth-basic@github.com`n"

		git config --global user.email "$($env:github_email)"

		git config --global user.name "Pete Maan"

		git checkout $($ENV:APPVEYOR_REPO_BRANCH) -q

		git add $(Join-Path -Path (Join-Path -Path "$env:APPVEYOR_BUILD_FOLDER" -ChildPath "$env:APPVEYOR_PROJECT_NAME") -ChildPath "$env:APPVEYOR_PROJECT_NAME.psd1")

		git status

		git commit -s -m "Update Version: $($env:APPVEYOR_BUILD_VERSION)"

		git push --porcelain origin $($ENV:APPVEYOR_REPO_BRANCH)

		Write-Host "$($env:APPVEYOR_PROJECT_NAME) version $($env:APPVEYOR_BUILD_VERSION) pushed to GitHub." -ForegroundColor Cyan

	}

	Catch {

		Write-Host "Push to GitHub failed." -ForegroundColor Red
		throw $_

	}

}
Else {
	Write-Host "Skipping Deploy Process: GitHub Repository" -ForegroundColor Yellow
}