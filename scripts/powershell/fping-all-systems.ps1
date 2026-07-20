$targets = [ordered]@{
    "WireGuardTunnel" = "10.6.0.1"
    "WireGuardVM1"    = "10.0.0.36"
    "TestClientVM1"   = "10.0.0.21"
    "TestClientVM2"   = "10.0.0.22"
    "TestClientVM3"   = "10.0.0.23"
    "TestClientVM4"   = "10.0.0.24"
    "TestClientVM5"   = "10.0.0.25"
    "TestClientVM6"   = "10.0.0.26"
    "NetMonVM1"       = "10.0.0.132"
    "TestLinuxServer1" = "10.0.0.4"
}

$targets.GetEnumerator() | ForEach-Object {
    $reachable = Test-Connection -ComputerName $_.Value -Count 2 -Quiet

    [pscustomobject]@{
        Name      = $_.Key
        IP        = $_.Value
        Reachable = $reachable
    }
} | Format-Table -AutoSize