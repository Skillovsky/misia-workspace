# Watchdog dla Misi - Auto-healing przy crashach
# Uruchom na 192.168.1.105: powershell -ExecutionPolicy Bypass -File watchdog-misia.ps1

$logFile = "C:\Users\majki\clawd\logs\watchdog.log"
$checkInterval = 60 # sekundy

function Write-Log {
    param($message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Tee-Object -FilePath $logFile -Append
}

Write-Log "Watchdog started"

while ($true) {
    try {
        # Sprawdź czy gateway działa
        $status = clawdbot status 2>&1 | Out-String
        
        if ($status -match "error|invalid|failed|crashed") {
            Write-Log "ERROR detected in gateway - attempting auto-heal"
            
            # Próba naprawy
            Write-Log "Running: clawdbot doctor --fix"
            clawdbot doctor --fix 2>&1 | Out-File -FilePath $logFile -Append
            
            Start-Sleep -Seconds 5
            
            # Restart
            Write-Log "Running: clawdbot gateway restart"
            clawdbot gateway restart 2>&1 | Out-File -FilePath $logFile -Append
            
            Write-Log "Auto-heal completed"
        } else {
            Write-Log "Gateway healthy"
        }
        
    } catch {
        Write-Log "Watchdog error: $_"
    }
    
    Start-Sleep -Seconds $checkInterval
}
