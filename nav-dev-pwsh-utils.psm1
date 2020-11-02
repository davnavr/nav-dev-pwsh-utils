
<#
  .SYNOPSIS
  Opens a Git repository.
#>
function Open-Repo {
  [CmdletBinding()]
  param (
    # The path to the Git repository to open.
    [Parameter(Mandatory, Position = 0)]
    [ValidateScript({
      ($_.Exists) -and ($_.GetDirectories(".git").Length -gt 0)
    }, ErrorMessage = "{0} is not a valid Git repository")]
    [IO.DirectoryInfo]
    $Repo,

    # Specifies that the Git repository should be opened in the file explorer.
    [Alias("ex", "fx")]
    [Switch]
    $FileExplorer,

    # Specifies that the Git repository should be opened in GitHub Desktop.
    [Alias("gh")]
    [Switch]
    $GitHubDesktop,

    # Specifies that the Git repository should be opened in Visual Studio.
    [Alias("vs")]
    [ValidateScript({
      (-not $_) -or (Get-Command devenv -ErrorAction SilentlyContinue)
    }, ErrorMessage = "Unable to locate Visual Studio executable")]
    [Switch]
    $VisualStudio
  )

  if ($FileExplorer) { Start-Process $Repo.FullName }
  if ($VisualStudio) {
    $slns = $Repo.GetFiles("*.sln")
    if ($slns.Length -gt 0) {
      foreach ($sln in $slns) {
        devenv $sln
      }
    }
    else { devenv $Repo }
  }
  if ($GitHubDesktop) { github $Repo }

  Set-Location $Repo
}

function Start-FakeBuild {
  $workingdir = Get-Location
  $args =
    "-Command",
    "&{ try { dotnet fake build } finally { Read-Host } }",
    "-WorkingDirectory",
    $workingdir,
    "-WindowStyle",
    "Normal",
    "-NoExit"
  Start-Process -FilePath "pwsh" -ArgumentList $args -WorkingDirectory $workingdir
}
