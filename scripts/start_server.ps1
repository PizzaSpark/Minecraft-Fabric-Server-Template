# Define server path
$serverPath = "fabricmc_server"

# Load configuration
$config = ConvertFrom-StringData (Get-Content -Path config.txt -Raw)

# Log configuration values
Write-Host "`nConfiguration:"
Write-Host "`tversion: $($config.version)"
Write-Host "`tallocated_ram: $($config.allocated_ram)GB"
Write-Host "`tcheck_for_updates: $($config.check_for_updates)"

# Start the playit.gg program
Invoke-Item $($config.playitgg_path + "\playit.exe")

# Function to download the latest FabricMC jar
function Download-LatestFabric {
    if ($config.check_for_updates -eq "true") {
        # Create a directory for the server if it doesn't exist
        if (!(Test-Path -Path $serverPath)) {
            New-Item -ItemType Directory -Path $serverPath
        }

        # Download the latest FabricMC loader data
        Write-Host "`nChecking for the latest FabricMC build for version $($config.version)..."
        $version = $config.version
        $fabricApiUrl = "https://meta.fabricmc.net/v2/versions/loader/$version"
        $latestFabricData = Invoke-RestMethod -Uri $fabricApiUrl

        # Find the latest stable loader
        $latestLoader = $null
        foreach ($loader in $latestFabricData.loader) {
            if ($loader.stable -eq $true) {
                if ($latestLoader -eq $null -or [Version]$loader.version -gt [Version]$latestLoader.version) {
                    $latestLoader = $loader
                }
            }
        }

        if ($latestLoader -ne $null) {
            $jarName = "fabric-$version.jar"
            $downloadUrl = "https://meta.fabricmc.net/v2/versions/loader/$version/$($latestLoader.version)/$($latestLoader.intermediary.version)/server/jar"
            $localBuild = Get-Content -Path "$serverPath\build.txt" -ErrorAction SilentlyContinue

            if ($localBuild -ne $latestLoader.version) {
                Write-Host "`tLatest Fabric loader version: $($latestLoader.version)"
                (New-Object Net.WebClient).DownloadFile($downloadUrl, "$serverPath\fabric.jar")
                Write-Host "`tDownload complete: $jarName"
                $latestLoader.version | Out-File -FilePath "$serverPath\build.txt"
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
    if (Test-Path -Path .\fabric.jar) {
        java -Xmx"$($config.allocated_ram)G" -Xms"$($config.allocated_ram)G" -jar .\fabric.jar nogui
    } else {
        Write-Host "Error: Unable to access jarfile fabric.jar"
    }

    Set-Location -Path ..
}

# Call the functions
Download-LatestFabric
Run-Server

# End script
Write-Host "`nScript execution completed."
