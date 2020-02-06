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

	Write-Host "Deploy Process: GitHub Release" -ForegroundColor Yellow

	If ($ENV:APPVEYOR_REPO_BRANCH -eq 'master') {

		<# Master Branch     #>

		If ($env:APPVEYOR_BUILD_VERSION -ge "0.3.0") {

			$token = $env:access_token
			$uploadFilePath = Resolve-Path "..\$($env:APPVEYOR_PROJECT_NAME).zip"
			$releaseName = "v$($env:APPVEYOR_BUILD_VERSION)"
			$repo = "pspete/$env:APPVEYOR_PROJECT_NAME"

			$headers = @{
				"Authorization" = "token $token"
				"Content-type"  = "application/json"
			}

			$body = @{
				tag_name   = $releaseName
				name       = $releaseName
				body       = "$($env:APPVEYOR_PROJECT_NAME) v$($env:APPVEYOR_BUILD_VERSION)"
				draft      = $false
				prerelease = $false
			}

			Write-Host "Creating release $releaseName..." -NoNewline
			$json = (ConvertTo-Json $body)
			$release = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases" -Headers $headers -Method POST -Body $json
			$uploadUrl = $release.upload_url.Replace("{?name,label}", "") + "?name=" + [IO.Path]::GetFileName($uploadFilePath)
			Write-Host "OK" -ForegroundColor Green

			Write-Host "Uploading asset $($env:APPVEYOR_PROJECT_NAME).zip..." -NoNewline
			$data = [System.IO.File]::ReadAllBytes($uploadFilePath)
			$wc = New-Object Net.WebClient
			$wc.Headers['Content-type'] = 'application/octet-stream'
			$wc.Headers['Authorization'] = "token $token"

			try {
				$null = $wc.UploadData($uploadUrl, "POST", $data)
				Write-Host "OK" -ForegroundColor Green
			}
			catch {
				$host.SetShouldExit(1)
			}

		}

	}

	Else {

		<# Not Master Branch   #>
		Write-Host "$ENV:APPVEYOR_REPO_BRANCH Branch; No Release" -ForegroundColor Cyan
		exit;

	}

}
Else {
	Write-Host "Skipping Deploy Process: GitHub Repository" -ForegroundColor Yellow
}