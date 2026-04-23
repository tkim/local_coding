#Requires -Version 5.1
<#
.SYNOPSIS
    Sets up openclaude with a local Ollama backend for offline coding.
.DESCRIPTION
    Checks for Node.js 20+, installs openclaude globally, configures
    environment variables to point at your local Ollama instance, and
    optionally persists the config to your PowerShell profile.
#>

param(
    [string]$Model = "",
    [switch]$Persist
)

# ── Helpers ────────────────────────────────────────────────────────────────────
function Write-Step  { param($msg) Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-Ok    { param($msg) Write-Host "    [OK] $msg" -ForegroundColor Green }
function Write-Warn  { param($msg) Write-Host "    [WARN] $msg" -ForegroundColor Yellow }
function Write-Fail  { param($msg) Write-Host "    [FAIL] $msg" -ForegroundColor Red }

# ── Step 1: Node.js ────────────────────────────────────────────────────────────
Write-Step "Checking Node.js..."
try {
    $nodeVer = (node --version 2>&1) -replace "^v",""
    $semVer  = [Version]($nodeVer -replace "^(\d+\.\d+\.\d+).*",'$1')
    if ($semVer.Major -lt 20) {
        Write-Fail "Node.js $nodeVer found - need 20+. Download: https://nodejs.org"
        exit 1
    }
    Write-Ok "Node.js $nodeVer"
} catch {
    Write-Fail "Node.js not found. Download from https://nodejs.org (LTS) then re-run."
    exit 1
}

# ── Step 2: Ollama ─────────────────────────────────────────────────────────────
Write-Step "Checking Ollama..."
try {
    $ollamaVer = (ollama --version 2>&1) -replace "ollama version ",""
    Write-Ok "Ollama $ollamaVer"
} catch {
    Write-Fail "Ollama not found. Download from https://ollama.com/download/windows then re-run."
    exit 1
}

# Verify Ollama API is reachable
try {
    Invoke-RestMethod -Uri "http://localhost:11434/api/version" -Method GET -EA Stop | Out-Null
    Write-Ok "Ollama API reachable at http://localhost:11434"
} catch {
    Write-Warn "Ollama API not responding. Make sure Ollama is running (check system tray)."
}

# ── Step 3: Available models ───────────────────────────────────────────────────
Write-Step "Local models available..."
try {
    $models = (ollama list 2>&1)
    $models | ForEach-Object { Write-Host "    $_" }
} catch {
    Write-Warn "Could not list models. Run 'ollama list' manually."
}

# ── Step 4: Resolve model to use ──────────────────────────────────────────────
Write-Step "Selecting model..."

# Load .env if present (same directory as this script)
$envFile = Join-Path $PSScriptRoot ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | Where-Object { $_ -match "^\s*[^#]" -and $_ -match "=" } | ForEach-Object {
        $parts = $_ -split "=", 2
        $key   = $parts[0].Trim()
        $val   = $parts[1].Trim().Trim('"').Trim("'")
        if (-not [Environment]::GetEnvironmentVariable($key, "Process")) {
            [Environment]::SetEnvironmentVariable($key, $val, "Process")
        }
    }
    Write-Ok "Loaded .env"
}

if ($Model -eq "") {
    $Model = $env:OPENAI_MODEL
}
if ($Model -eq "" -or $null -eq $Model) {
    Write-Warn "No model specified. Pass -Model 'qwen3-coder:latest' or set OPENAI_MODEL in .env"
    Write-Host "    Defaulting to: qwen3-coder:latest"
    $Model = "qwen3-coder:latest"
}
Write-Ok "Model: $Model"

# ── Step 5: Install openclaude ─────────────────────────────────────────────────
Write-Step "Installing openclaude..."
npm install -g @gitlawb/openclaude@0.5.2 --legacy-peer-deps
if ($LASTEXITCODE -ne 0) {
    Write-Fail "npm install failed."
    exit 1
}
Write-Ok "openclaude installed"

# ── Step 6: Set environment variables for this session ────────────────────────
Write-Step "Configuring environment (current session)..."
$env:CLAUDE_CODE_USE_OPENAI = "1"
$env:OPENAI_BASE_URL        = "http://localhost:11434/v1"
$env:OPENAI_MODEL           = $Model
Write-Ok "CLAUDE_CODE_USE_OPENAI=1"
Write-Ok "OPENAI_BASE_URL=http://localhost:11434/v1"
Write-Ok "OPENAI_MODEL=$Model"

# ── Step 7: Optionally persist to PowerShell profile ──────────────────────────
if ($Persist) {
    Write-Step "Persisting config to PowerShell profile ($PROFILE)..."
    $lines = @(
        "",
        "# openclaude - local Ollama backend",
        "`$env:CLAUDE_CODE_USE_OPENAI = '1'",
        "`$env:OPENAI_BASE_URL        = 'http://localhost:11434/v1'",
        "`$env:OPENAI_MODEL           = '$Model'"
    )
    $lines | Add-Content -Path $PROFILE -Encoding UTF8
    Write-Ok "Added to $PROFILE - takes effect in new terminals"
}

# ── Done ───────────────────────────────────────────────────────────────────────
Write-Host @"

Setup complete!

    Run:    openclaude
    Switch: `$env:OPENAI_MODEL = 'qwen3-coder' ; openclaude

Flags:
    .\setup.ps1 -Model 'qwen3-coder'          # use a specific model
    .\setup.ps1 -Model 'deepseek-coder-v2:16b' -Persist  # also save to profile
"@ -ForegroundColor Green
