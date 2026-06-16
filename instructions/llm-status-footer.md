# LLM Status Footer

You MUST include a status footer at the end of EVERY response AND write the status file.

## Step 1: Write Status File

Before appending the footer, run this PowerShell command to write `.opencode/llm-status.json`:

```powershell
$status = @{
  mode = "9ROUTER"
  model = "mimo-v2.5-free"
  last_tokens = <YOUR_OUTPUT_TOKEN_COUNT>
  session_tokens = <YOUR_OUTPUT_TOKEN_COUNT>
  tokens_per_second = 0
  latency_ms = 0
  gpu_available = $false
  last_updated = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
} | ConvertTo-Json -Depth 3
$status | Set-Content -Path ".opencode\llm-status.json" -Encoding UTF8
```

Replace `<YOUR_OUTPUT_TOKEN_COUNT>` with your estimated output token count (roughly 1 token per 4 characters of your response).

## Step 2: Append Footer

After writing the file, append this footer:

```
---
LLM [9ROUTER] Tokens [X] | model
```

Where:
- `Tokens [X]` = your estimated output token count
- `model` = the model you are using (e.g., mimo-v2.5-free)

## Example

```
Here is the answer to your question about React hooks...

---
LLM [9ROUTER] Tokens [245] | mimo-v2.5-free
```

## ECO Mode

When in ECO mode, show:
```
---
LLM [ECO] Tokens [0] | passthrough
```
