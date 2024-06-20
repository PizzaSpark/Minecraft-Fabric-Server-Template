# Confirm backup
$confirmation = Read-Host -Prompt 'Are you sure you want to backup the worlds? (yes/no)'
if ($confirmation -ne 'yes') {
    Write-Host 'Backup cancelled.'
    exit
}

# Define server path and backup path
$serverPath = 'fabricmc_server'
$backupPath = 'backups'

# Create a directory for the backups if it doesn't exist
if (!(Test-Path -Path $backupPath)) {
    New-Item -ItemType Directory -Path $backupPath
}

# Get current date as a string
$date = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'

# Define source paths and destination path
$sourceWorld = $serverPath + '\world'
$sourceNether = $serverPath + '\world_nether'
$sourceEnd = $serverPath + '\world_the_end'
$destination = $backupPath + '\worlds_backup_' + $date + '.7z'

# Compress worlds into a 7z file with maximum compression
& '7z' a -t7z -mx=9 $destination $sourceWorld $sourceNether $sourceEnd

# Log completion
Write-Host "`nBackup completed: $destination"