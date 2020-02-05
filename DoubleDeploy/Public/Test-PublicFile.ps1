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