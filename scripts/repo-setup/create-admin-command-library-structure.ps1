#Create subfolder and accompanying docs

# Define the target directory path
$rootDir = "C:\Users\shuri\Documents\Azure Network Infrastructure Lab\operations\admin-command-library"

#Create the main subfolder

New-Item -Path $targetDir -ItemType Directory -Force | Out-Null


# List of files for the main subfolder
$mainFiles = @(
	"README.md"
	"azure-cli.md"
	"bash-Linux.md"
	"powershell.md"
	"wireguard.md"
)

# List of files for the syntax subfolder
$syntaxFiles = @(
	"bash-syntax.md"
	"powershell-syntax.md"
	"azure-cli-query-syntax.md"
	"wireguard-config-syntax.md"
)


# 1. Create the main files (and the admin-command-library folder if missing)
foreach ($file in $mainFiles) {
	New-Item -Path "$rootDir\$file" -ItemType File -Force | Out-Null
}

# 2. Create the syntax subfolder and its files
$syntaxDir = "$rootDir\syntax"
foreach ($file in $syntaxFiles) {
	New-Item -Path "$syntaxDir\$file" -ItemType File -Force | Out-Null
}

Write-Host "Verified! Full lab substructure created successfully." -ForegroundColor Green