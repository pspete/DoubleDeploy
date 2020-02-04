#---------------------------------#
# Header                          #
#---------------------------------#
Write-Host "Testing: PSVersion $($PSVersionTable.PSVersion)" -ForegroundColor Yellow

$TestsResults = $(Join-Path $HOME "TestsResults.xml")
$CodeCoverage = $(Join-Path $HOME "coverage.json")
$OutFile = $(Join-Path $HOME "codecov.sh")

#---------------------------------#
# Run Pester Tests                #
#---------------------------------#
$files = Get-ChildItem $(Join-Path $ENV:APPVEYOR_BUILD_FOLDER $env:APPVEYOR_PROJECT_NAME) -Include *.ps1 -Recurse

$res = Invoke-Pester -Path ".\Tests" -OutputFormat NUnitXml -OutputFile $TestsResults -CodeCoverage $files -PassThru

Write-Host 'Uploading Test Results'
(New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", $TestsResults)

if ($env:APPVEYOR_REPO_COMMIT_AUTHOR -eq "Pete Maan") {

	Write-Host 'Formating Code Coverage'
	$coverage = Format-Coverage -PesterResults $res -CoverallsApiToken $($env:coveralls_key) -BranchName $($env:APPVEYOR_REPO_BRANCH)

	Export-CodeCovIoJson -CodeCoverage $res.CodeCoverage -RepoRoot $pwd -Path $CodeCoverage -Verbose:$false

	Write-Host 'Publishing Code Coverage'

	Publish-Coverage -Coverage $coverage

	Invoke-WebRequest -Uri 'https://codecov.io/bash' -OutFile $OutFile

	bash $OutFile -f $CodeCoverage


}
#---------------------------------#
# Validate                        #
#---------------------------------#
if (($res.FailedCount -gt 0) -or ($res.PassedCount -eq 0)) {

	throw "$($res.FailedCount) tests failed."

}
else {

	Write-Host 'All tests passed' -ForegroundColor Green

}