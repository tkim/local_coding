#Requires -Version 5.1
<#
.SYNOPSIS
    Launch openclaude with a local Ollama model.
.DESCRIPTION
    Sets the required environment variables and launches openclaude.
    Reads defaults from .env in the same directory.
    Pass -Model to override the model without editing .env.
.EXAMPLE
    .\oc.ps1
    .\oc.ps1 -Model qwen3-coder
    .\oc.ps1 -Model second_constantine/deepseek-coder-v2:16b
    .\oc.ps1 -Model gemma4:26b
    .\oc.ps1 -List
#>

param(
    [string]$Model = "",
    [switch]$List
)

# ── List available models and exit ────────────────────────────────────────────
if ($List) {
    Write-Host "`nAvailable Ollama models:" -ForegroundColor Cyan
    ollama list
    exit 0
}

# ── Load .env defaults ────────────────────────────────────────────────────────
$envFile = Join-Path $PSScriptRoot ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | Where-Object { $_ -match "^\s*[^#]" -and $_ -match "=" } | ForEach-Object {
        $parts = $_ -split "=", 2
        $key   = $parts[0].Trim()
        $val   = $parts[1].Trim().Trim('"').Trim("'")
        [Environment]::SetEnvironmentVariable($key, $val, "Process")
    }
}

# ── Resolve model ─────────────────────────────────────────────────────────────
if ($Model -ne "") {
    $env:OPENAI_MODEL = $Model
}

if (-not $env:OPENAI_MODEL) {
    $env:OPENAI_MODEL = "qwen3-coder"
}

# ── Ensure required vars are set ─────────────────────────────────────────────
$env:CLAUDE_CODE_USE_OPENAI = "1"
$env:OPENAI_BASE_URL        = "http://localhost:11434/v1"

# ── Launch ────────────────────────────────────────────────────────────────────
Write-Host "Launching openclaude with model: " -NoNewline -ForegroundColor Cyan
Write-Host $env:OPENAI_MODEL -ForegroundColor Yellow
Write-Host "Endpoint: $env:OPENAI_BASE_URL`n" -ForegroundColor DarkGray

openclaude
