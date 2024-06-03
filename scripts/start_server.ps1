# Define server path
$serverPath = "papermc_server"

# Load configuration
$config = ConvertFrom-StringData (Get-Content -Path config.txt -Raw)

# Log configuration values
Write-Host "`nConfiguration:"
Write-Host "`tversion: $($config.version)"
Write-Host "`tallocated_ram: $($config.allocated_ram)GB"
Write-Host "`tcheck_for_updates: $($config.check_for_updates)"

# Function to download the latest PaperMC jar
function Download-LatestPaper {
    if ($config.check_for_updates -eq "true") {
        # Create a directory for the server if it doesn't exist
        if (!(Test-Path -Path $serverPath)) {
            New-Item -ItemType Directory -Path $serverPath
        }

        # Download the specified PaperMC build
        Write-Host "`nChecking PaperMC build for version $($config.version)..."
        $version = $config.version
        $builds = Invoke-RestMethod -Uri "https://api.papermc.io/v2/projects/paper/versions/$version/builds"
        $latestBuild = $builds.builds | Where-Object { $_.channel -eq "default" } | ForEach-Object { $_.build } | Select-Object -Last 1
        if ($latestBuild -ne $null) {
            $jarName = "paper-$version-$latestBuild.jar"
            $downloadUrl = "https://api.papermc.io/v2/projects/paper/versions/$version/builds/$latestBuild/downloads/$jarName"
            $localBuild = Get-Content -Path "$serverPath\build.txt" -ErrorAction SilentlyContinue
            if ($localBuild -ne $latestBuild) {
                Write-Host "`tLatest build number: $latestBuild"
                (New-Object Net.WebClient).DownloadFile($downloadUrl, "$serverPath\paper.jar")
                Write-Host "`tDownload complete: $jarName"
                $latestBuild | Out-File -FilePath "$serverPath\build.txt"
            } else {
                Write-Host "`tLocal version is up-to-date."
            }
        }
    } else {
        Write-Host "`nSkipping update check as per configuration."
    }
}

# Function to start the server
function Run-Server {
    Set-Location -Path $serverPath
    Write-Host "`nStarting server with $($config.allocated_ram)GB of RAM..."
    if (Test-Path -Path .\paper.jar) {
        java -Xmx"$($config.allocated_ram)G" -Xms"$($config.allocated_ram)G" -jar .\paper.jar --nogui
    } else {
        Write-Host "Error: Unable to access jarfile paper.jar"
    }

    Set-Location -Path ..
}

# Call the functions
Download-LatestPaper
Run-Server

# End script
Write-Host "`nScript execution completed."