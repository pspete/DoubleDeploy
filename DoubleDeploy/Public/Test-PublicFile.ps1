Function Test-PublicFile {
	<#
	.SYNOPSIS
	Short description

	.DESCRIPTION
	Long description

	.PARAMETER Scope
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
		$Scope
	)

	Test-PrivateFile -TestParam $Scope

}