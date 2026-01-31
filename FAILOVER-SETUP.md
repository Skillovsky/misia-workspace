# Failover & Auto-Healing - Setup Guide

## Status
- ✅ **Majki:** Config zaktualizowany na darmowe modele
- 🔧 **Misia:** Wymaga naprawy

## Co zrobiłem (Majki)

### 1. Zmiana modeli na 100% darmowe
- Primary: `google/gemini-2.5-flash`
- Fallbacks: Gemini → Groq → DeepSeek → OpenRouter free → Sonnet/Opus (backup)

### 2. Watchdog auto-healing
Skrypt: `C:\Users\jacke\clawd\scripts\watchdog-majki.ps1`
- Sprawdza gateway co 60s
- Przy błędzie: `clawdbot doctor --fix` + restart
- Logi: `C:\Users\jacke\clawd\logs\watchdog.log`

---

## Co musisz zrobić (Jacke)

### A. Napraw Misię (192.168.1.105)

**Opcja 1: Zdalnie przez RDP/TeamViewer**
```powershell
# Połącz się z 192.168.1.105

# 1. Sprawdź status
cd C:\Users\majki\clawd
clawdbot status

# 2. Zastosuj config failsafe
clawdbot gateway config.patch --file "\\192.168.1.3\Users\jacke\clawd\config-misia-failsafe.json"

# 3. Restart
clawdbot gateway restart

# 4. Uruchom watchdog
powershell -ExecutionPolicy Bypass -File "\\192.168.1.3\Users\jacke\clawd\scripts\watchdog-misia.ps1"
```

**Opcja 2: Lokalnie na 192.168.1.105**
1. Skopiuj `config-misia-failsafe.json` i `watchdog-misia.ps1` do maszyny Misi
2. Uruchom komendy z Opcji 1

### B. Uruchom watchdog dla Majkiego

```powershell
# Na tej maszynie (192.168.1.3)
powershell -ExecutionPolicy Bypass -File "C:\Users\jacke\clawd\scripts\watchdog-majki.ps1"
```

### C. Automatyczne uruchamianie watchdogów (opcjonalnie)

**Task Scheduler dla Majkiego:**
```powershell
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File C:\Users\jacke\clawd\scripts\watchdog-majki.ps1"
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -TaskName "Clawdbot Watchdog Majki" -Action $action -Trigger $trigger -RunLevel Highest
```

**Task Scheduler dla Misi (na 192.168.1.105):**
```powershell
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File C:\Users\majki\clawd\scripts\watchdog-misia.ps1"
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -TaskName "Clawdbot Watchdog Misia" -Action $action -Trigger $trigger -RunLevel Highest
```

---

## Kolejność darmowych modeli (priority)

1. **Gemini 2.5 Flash** - najszybszy, 1M context
2. **Gemini 2.0 Flash** - backup Gemini
3. **Groq Llama 3.3 70B** - ultra szybki (200+ tok/s)
4. **Groq DeepSeek R1** - reasoning model
5. **OpenRouter free tier** - DeepSeek, Qwen, Llama 405B
6. **Sonnet/Opus** - ostatnia deska ratunku (OAuth limit)

---

## Co to daje

- ✅ **Zero kosztów** - tylko darmowe modele
- ✅ **Auto-healing** - sam się naprawia przy crashu
- ✅ **Multi-fallback** - 9 poziomów zapasowych
- ✅ **Logging** - wszystko w `logs/watchdog.log`

---

*Utworzono: 2026-01-31 21:17*
*Autor: Majki*
