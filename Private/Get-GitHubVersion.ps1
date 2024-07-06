function Get-GitHubVersion {
    <#
    .SYNOPSIS
    Retrieves the latest version information from a GitHub repository and compares it with the currently installed version of a specified cmdlet.

    .DESCRIPTION
    The Get-GitHubVersion function retrieves the latest version information from a specified GitHub repository and compares it with the version of a specified cmdlet. It then provides feedback on whether an update is available or if the installed version is up to date.

    .PARAMETER Cmdlet
    The name of the cmdlet to check for updates.

    .PARAMETER RepositoryOwner
    The owner of the GitHub repository where the releases are hosted.

    .PARAMETER RepositoryName
    The name of the GitHub repository.

    .EXAMPLE
    Get-GitHubVersion -Cmdlet "MyCmdlet" -RepositoryOwner "MyRepoOwner" -RepositoryName "MyRepo"

    Description:
    Retrieves the latest version information for "MyCmdlet" from the GitHub repository owned by "MyRepoOwner" with the name "MyRepo".

    #>
    [cmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $Cmdlet,
        [Parameter(Mandatory)][string] $RepositoryOwner,
        [Parameter(Mandatory)][string] $RepositoryName
    )
    $App = Get-Command -Name $Cmdlet -ErrorAction SilentlyContinue
    if ($App) {
        [Array] $GitHubReleases = (Get-GitHubLatestRelease -Url "https://api.github.com/repos/$RepositoryOwner/$RepositoryName/releases" -Verbose:$false)
        $LatestVersion = $GitHubReleases[0]
        if (-not $LatestVersion.Errors) {
            if ($App.Version -eq $LatestVersion.Version) {
                "Current/Latest: $($LatestVersion.Version) at $($LatestVersion.PublishDate)"
            } elseif ($App.Version -lt $LatestVersion.Version) {
                "Current: $($App.Version), Published: $($LatestVersion.Version) at $($LatestVersion.PublishDate). Update?"
            } elseif ($App.Version -gt $LatestVersion.Version) {
                "Current: $($App.Version), Published: $($LatestVersion.Version) at $($LatestVersion.PublishDate). Lucky you!"
            }
        } else {
            "Current: $($App.Version)"
        }
    }
}