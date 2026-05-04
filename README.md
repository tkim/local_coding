# local_coding

Local offline coding setup using [openclaude](https://github.com/Gitlawb/openclaude) + [Ollama](https://ollama.com) on Windows.

No cloud API keys. No internet required after setup.

---

## Hardware

This setup runs on an Asus Z13 with models served locally via Ollama.

**Models used:**
- `qwen3-coder` - primary coding model (default)
- `second_constantine/deepseek-coder-v2:16b` - alternative
- `gemma4:26b` - alternative

---

## Prerequisites

| Tool | Version | Download |
|---|---|---|
| Node.js | 20+ | https://nodejs.org (LTS) |
| Ollama | latest | https://ollama.com/download/windows |

Your models should already be pulled:
```powershell
ollama list
```

If not:
```powershell
ollama pull qwen3-coder
ollama pull second_constantine/deepseek-coder-v2:16b
```

---

## Setup

Run once to install openclaude and configure your environment:

```powershell
# Clone the repo
git clone https://github.com/YOUR_USERNAME/local_coding.git
cd local_coding

# Copy env config (default model: qwen3-coder)
cp .env.example .env

# Run setup
.\setup.ps1

# To persist env vars across new terminals
.\setup.ps1 -Persist
```

---

## Usage

Make sure Ollama is running (check the system tray), then launch with the `oc.ps1` wrapper:

```powershell
# Use default model (qwen3-coder)
.\oc.ps1

# Specify a model at launch
.\oc.ps1 -Model qwen3-coder
.\oc.ps1 -Model second_constantine/deepseek-coder-v2:16b
.\oc.ps1 -Model gemma4:26b

# List all available local models
.\oc.ps1 -List
```

> **Note:** `.\setup.ps1` only needs to be re-run if you open a new terminal and haven't used `-Persist`, or after a fresh install.

---

## How it works

openclaude normally targets the Anthropic API. Setting `CLAUDE_CODE_USE_OPENAI=1` switches it to use any OpenAI-compatible endpoint. Ollama exposes one at `http://localhost:11434/v1`, so the two connect without any API keys or internet access.

```
.\oc.ps1  ->  OPENAI_MODEL=qwen3-coder  ->  http://localhost:11434/v1  ->  Ollama  ->  qwen3-coder (local)
```

---

## Files

| File | Purpose |
|---|---|
| `oc.ps1` | Launcher with `-Model` flag - use this daily |
| `setup.ps1` | One-time install + env config |
| `.env` | Default model and endpoint (gitignored) |
| `.env.example` | Template for `.env` |

---

## Troubleshooting

**`openclaude` not found after install**
Close and reopen PowerShell, or re-run `.\setup.ps1`.

**`invalid model name` error**
- Run `.\oc.ps1 -List` to see exact model names Ollama has
- Use the name exactly as shown (without `:latest` suffix)

**Model not responding**
- Confirm Ollama is running: `ollama ps`
- Confirm API is up: `Invoke-RestMethod http://localhost:11434/api/version`

**Env vars reset between terminals**
Run `.\setup.ps1 -Persist` once to add them to your PowerShell profile permanently.

---

## Updating openclaude

```powershell
npm install -g @gitlawb/openclaude@0.5.2 --legacy-peer-deps
```
