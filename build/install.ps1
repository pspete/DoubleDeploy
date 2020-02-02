#---------------------------------#
# Header                          #
#---------------------------------#
Write-Host "Installing Required Modules:" -ForegroundColor Yellow

$RequiredModules = @(
	"Pester",
	"PSScriptAnalyzer",
	"coveralls",
	"PSCodeCovIo"
)

#---------------------------------#
# Install NuGet                   #
#---------------------------------#
if(-not $IsCoreCLR) {
	Write-Host "`tNuGet..."
	$pkg = Install-PackageProvider -Name NuGet -Confirm:$false -Force -ErrorAction Stop
	Write-Host "`t`tInstalled NuGet version '$($pkg.version)'"
}
#---------------------------------#
# Install Required Modules        #
#---------------------------------#
foreach ($Module in $RequiredModules) {

	Try {
		Write-Host "`tInstalling: $Module..."
		Install-Module -Name $Module -Repository PSGallery -Confirm:$false -Force -SkipPublisherCheck -ErrorAction Stop | Out-Null
	}Catch { throw "`t`tError Installing $Module" }

}