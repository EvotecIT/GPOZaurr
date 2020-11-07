function Get-GitHubVersion {
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