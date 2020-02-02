Function Test-PrivateFile {
	<#
	.SYNOPSIS
	Short description

	.DESCRIPTION
	Long description

	.PARAMETER TestParam
	Parameter description

	.EXAMPLE
	An example

	.NOTES
	General notes
	#>

	[CmdletBinding()]
	Param(
		[Parameter(
			Mandatory = $false,
			ValueFromPipelineByPropertyName = $true
		)]
		[Int]
		$TestParam
	)

	If ($IsCoreCLR) {$SomeVar="SomeValue"}
	If ($TestParam -lt 5) {
		$SomeVar = $True
	}
	Else {
		$SomeVar = $false
	}

	$SomeVar

}