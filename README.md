# local_coding

Local offline coding setup using [openclaude](https://github.com/Gitlawb/openclaude) + [Ollama](https://ollama.com) on Windows.

No cloud API keys. No internet required after setup.

---

## Hardware

This setup runs on an Asus Z13 with models served locally via Ollama.

**Models used:**
- `deepseek-coder-v2:16b` — primary coding model
- `qwen3-coder` — alternative

---

## Prerequisites

| Tool | Version | Download |
|---|---|---|
| Node.js | 20+ | https://nodejs.org (LTS) |
| Ollama | latest | https://ollama.com/download/windows |

Your models should already be pulled:
```powershell
ollama list
# deepseek-coder-v2:16b   ...
# qwen3-coder             ...
```

If not:
```powershell
ollama pull deepseek-coder-v2:16b
ollama pull qwen3-coder
```

---

## Setup

```powershell
# Clone the repo
git clone https://github.com/YOUR_USERNAME/local_coding.git
cd local_coding

# Copy and edit env config
cp .env.example .env
# Edit .env: set OPENAI_MODEL to your preferred model

# Run setup (installs openclaude, configures env for this session)
.\setup.ps1

# Or specify a model directly
.\setup.ps1 -Model "deepseek-coder-v2:16b"

# To also persist config to your PowerShell profile (survives new terminals)
.\setup.ps1 -Model "deepseek-coder-v2:16b" -Persist
```

---

## Usage

Make sure Ollama is running (check the system tray), then:

```powershell
openclaude
```

**Switch models on the fly:**
```powershell
$env:OPENAI_MODEL = "qwen3-coder"
openclaude
```

**One-liner without persisting:**
```powershell
$env:CLAUDE_CODE_USE_OPENAI="1"; $env:OPENAI_BASE_URL="http://localhost:11434/v1"; $env:OPENAI_MODEL="deepseek-coder-v2:16b"; openclaude
```

---

## How it works

openclaude normally targets the Anthropic API. Setting `CLAUDE_CODE_USE_OPENAI=1` switches it to use any OpenAI-compatible endpoint. Ollama exposes one at `http://localhost:11434/v1`, so the two connect without any API keys or internet access.

```
openclaude  →  http://localhost:11434/v1  →  Ollama  →  deepseek-coder-v2:16b (local)
```

---

## Troubleshooting

**`openclaude` not found after install**
Close and reopen PowerShell — npm's global bin path needs a fresh session.

**Model not responding**
- Confirm Ollama is running: `ollama ps`
- Confirm model name matches exactly: `ollama list`
- Confirm API is up: `Invoke-RestMethod http://localhost:11434/api/version`

**Env vars reset between terminals**
Run `.\setup.ps1 -Persist` once to add them to your PowerShell profile permanently.

---

## Updating openclaude

```powershell
npm install -g @gitlawb/openclaude@latest
```
