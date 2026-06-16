# /setup — OpenCode + ECC + 9Router Setup

Setup all-in-one: ECC skills, 9Router, config, profiles.

## Usage

```
/setup              # First run: install everything, stop at api-key
/setup --apply      # Second run: apply api-key, verify, done
/setup --profile go # Use go profile (default: gratis)
```

## Workflow

### First Run (`/setup`)

1. Pre-flight checks (node, git, opencode)
2. Detect 9Router (installed? running?)
3. Clone/pull ECC
4. Install ECC deps + build plugin
5. Apply profile config
6. Generate `api-key.txt`
7. **STOP** — user fills api-key.txt

### Second Run (`/setup --apply`)

8. Read api-key.txt → set `NINEROUTER_API_KEY`
9. Start 9Router if not running
10. Verify health + summary

## Execution

Run the setup script:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\FANNNDI\Documents\opencode-setup\scripts\setup.ps1" $ARGUMENTS
```

## After Setup

1. Fill `api-key.txt` with your 9Router API key
2. Run `/setup --apply`
3. Open terminal → `opencode`
4. Start coding!
