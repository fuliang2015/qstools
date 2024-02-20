<#
        .NOTES
===========================================================================
        Created on:   2024-01-17
        Created by:   Wallace Chen
        Modified by:
        Modified on:
        Filename:     MultiNodeFileReplacing.ps1
===========================================================================
        .DESCRIPTION
            To Replace File and backup orginal file in a multi-node environment
#>

# Get-ExecutionPolicy to validate if the policy is restrctive and prevent your script from running
# Set execution policy to allow running unsigned scripts
#Set-ExecutionPolicy Bypass -Scope Process -Force

# Define the paths
$originalFilePath = "folderPath"

# Define multiple destination paths (including network paths)
$newFilePaths = @(
    #"\\$basePath\$driveLetter\$folderPath",
    # e.g "\\server01\d$\Program Files\Qlik\Sense\CapabilityService\capabilities.json"
    # Add more paths as needed
)

# Check if the original file exists
if (Test-Path $originalFilePath) {
    foreach ($newFilePath in $newFilePaths) {
        # Generate a timestamp for renaming the destination file
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $originalFileName = (Get-Item $originalFilePath).BaseName
        $originalFileExtension = (Get-Item $originalFilePath).Extension

        # Construct the backup file name
        $backupFileName = "${originalFileName}_$timestamp$originalFileExtension"

        # Construct the backup file path
        $backupFilePath = Join-Path -Path (Get-Item $newFilePath).Directory.FullName -ChildPath $backupFileName

        # Check if the new file exists and move it to the backup location
        if (Test-Path $newFilePath) {
            Move-Item -Path $newFilePath -Destination $backupFilePath -Force
        }

        # Copy the original file to the destination path
        Copy-Item -Path $originalFilePath -Destination $newFilePath -Force

        Write-Host "File replaced successfully. Backup created: $backupFilePath"
    }
} else {
    Write-Host "Original file not found: $originalFilePath"
}