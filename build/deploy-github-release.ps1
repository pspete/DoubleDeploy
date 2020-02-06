
if (-not ($ENV:APPVEYOR_PULL_REQUEST_NUMBER)) {

	Write-Host "Deploy Process: GitHub Release" -ForegroundColor Yellow

	<#---------------------------------#>
	<# If Not a PR                     #>
	<#---------------------------------#>
	If ($ENV:APPVEYOR_REPO_BRANCH -eq 'master') {

		<# Master Branch     #>

		If ($env:APPVEYOR_BUILD_VERSION -ge "0.3.0") {

			$token = $env:access_token
			$uploadFilePath = Resolve-Path ".\$($env:APPVEYOR_PROJECT_NAME).zip"
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

			Write-Host "Creating release..." -NoNewline
			$json = (ConvertTo-Json $body)
			$release = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases" -Headers $headers -Method POST -Body $json
			$uploadUrl = $release.upload_url.Replace("{?name,label}", "") + "?name=" + [IO.Path]::GetFileName($uploadFilePath)
			Write-Host "OK" -ForegroundColor Green

			$uploadUrl

			Write-Host "Uploading asset..." -NoNewline
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
		Else {

			<# Less Than version 1.0 - No Deployment   #>
			Write-Host "Nothing to Deploy - Exiting" -ForegroundColor Cyan
			exit;

		}

	}

}
Else {

	Write-Host "Skipping Deploy Process: GitHub Release" -ForegroundColor Yellow

}