$SearchRoot = "C:\Users\shuri\Documents"
$DestinationRoot = "C:\Users\shuri\Documents\Azure Network Infrastructure Lab\evidence\powershell-batch-deployment"

$PhaseFiles = [ordered]@{
    "phase-01-network-foundation" = @(
        "Phase One Bicep Deployment Powershell output(1).txt"
        "Phase One Bicep Deployment AZ CLI Help output(1).txt"
    )

    "phase-02-client-vm-deployment" = @(
        "PowerShell_transcript.MAGA.MQRVtGYo.20260628051348.txt"
        "PowerShell_transcript.MAGA.ENONVlts.20260627055739.txt"
        "PowerShell_transcript.MAGA.xiXOhJ_H.20260627203123.txt"
        "PowerShell_transcript.MAGA._J+gn03I.20260625073856(1).txt"
        "SIG-creation-PowerShell_transcript.MAGA.dhUs05iY.20260625032336.txt"
    )

    "phase-03-wireguard-vm-deployment" = @(
        "powershell-session-7-7-2026-successful-batch-dep.txt"
        "wg module dep test output 07-03-2026.txt"
        "PowerShell_transcript.MAGA.6WhaHcgC.20260703050449.txt"
        "PowerShell_transcript.MAGA.BIHTk+hY.20260708043810.txt"
    )

    "phase-04-wireguard-configuration-validation" = @(
        "PowerShell_transcript.MAGA.MCMhvRPd.20260708080939.txt"
        "PowerShell_transcript.MAGA.7tfHDGk6.20260709212008.txt"
        "PowerShell_transcript.MAGA.6Ve01MNm.20260710044616.txt"
        "phase 5.txt"
    )

    "phase-05-teardown" = @(
        "phase five client vm, nic, and os d.txt"
        "PowerShell_transcript.MAGA.pkcWL9iU.20260712051903.txt"
    )
}

# Create the destination and phase folders.
New-Item -ItemType Directory -Path $DestinationRoot -Force | Out-Null

foreach ($PhaseFolder in $PhaseFiles.Keys) {
    New-Item `
        -ItemType Directory `
        -Path (Join-Path $DestinationRoot $PhaseFolder) `
        -Force | Out-Null
}

# Build a searchable index while excluding the destination itself.
$FileIndex = Get-ChildItem `
    -LiteralPath $SearchRoot `
    -Recurse `
    -File `
    -ErrorAction SilentlyContinue |
    Where-Object {
        $_.FullName -notlike "$DestinationRoot\*"
    } |
    Group-Object -Property Name -AsHashTable -AsString

foreach ($PhaseFolder in $PhaseFiles.Keys) {
    $PhaseDestination = Join-Path $DestinationRoot $PhaseFolder

    foreach ($FileName in $PhaseFiles[$PhaseFolder]) {
        if (-not $FileIndex.ContainsKey($FileName)) {
            Write-Warning "Not found: $FileName"
            continue
        }

        $Matches = @($FileIndex[$FileName])

        if ($Matches.Count -gt 1) {
            Write-Warning "Multiple copies found for: $FileName"
            $Matches | ForEach-Object {
                Write-Host "  $($_.FullName)" -ForegroundColor Yellow
            }

            Write-Warning "The first copy will be used."
        }

        $SourceFile = $Matches[0].FullName

        Copy-Item `
            -LiteralPath $SourceFile `
            -Destination $PhaseDestination `
            -Force

        Write-Host "Copied: $FileName -> $PhaseFolder" -ForegroundColor Green
    }
}

Write-Host "`nFinished. Files were copied to:" -ForegroundColor Cyan
Write-Host $DestinationRoot