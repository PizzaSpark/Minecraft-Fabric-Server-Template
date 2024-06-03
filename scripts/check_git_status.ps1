# Fetch updates from the remote repository
git fetch

# Check if the local repository is up-to-date
$local = git rev-parse @
$remote = git rev-parse @{u}
$base = git merge-base @ @{u}

if ($local -eq $remote) {
    Write-Host "Up-to-date"
} elseif ($local -eq $base) {
    Write-Host "Need to pull"
    git pull
} elseif ($remote -eq $base) {
    Write-Host "Need to push"
} else {
    Write-Host "Diverged"
}