# Model Rotation dla Misi - oszczędza limity API

$models = @(
    "google/gemini-2.5-flash",
    "groq/llama-3.3-70b-versatile",
    "openrouter/deepseek/deepseek-chat-v3-0324:free",
    "openrouter/qwen/qwen-3-coder-32b-preview:free",
    "openrouter/meta-llama/llama-3.3-405b:free"
)

$logFile = "C:\Users\majki\clawd\logs\model-rotation.log"
$configPath = "C:\Users\majki\.clawdbot\clawdbot.json"
$stateFile = "C:\Users\majki\clawd\logs\model-state.json"

function Write-Log {
    param($message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Tee-Object -FilePath $logFile -Append
}

# Load current state
if (Test-Path $stateFile) {
    $state = Get-Content $stateFile | ConvertFrom-Json
    $currentIndex = $state.currentIndex
} else {
    $currentIndex = 0
}

# Next model
$nextIndex = ($currentIndex + 1) % $models.Count
$nextModel = $models[$nextIndex]

Write-Log "Rotating model from $($models[$currentIndex]) to $nextModel"

# Update config
$config = Get-Content $configPath | ConvertFrom-Json
$config.agents.defaults.model.primary = $nextModel
$config | ConvertTo-Json -Depth 10 | Set-Content $configPath

# Save state
@{ currentIndex = $nextIndex; lastRotation = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") } | ConvertTo-Json | Set-Content $stateFile

Write-Log "Model rotated successfully. Restarting gateway..."

# Restart gateway
clawdbot gateway restart 2>&1 | Out-File -FilePath $logFile -Append

Write-Log "Gateway restarted"
