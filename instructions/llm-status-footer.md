# LLM Status Footer

You MUST include a status footer at the end of EVERY response.

## Format

```
---
LLM [MODE] Tokens [X] Session [Y] | model | Z tok/s | GPU [A%] B/C MiB
```

## How to Get Values

Read the file `.opencode/llm-status.json` and display it exactly as formatted:

- `mode` -> `[MODE]` (e.g., BALANCED, PERFORMANCE, ECO)
- `last_tokens` -> `Tokens [X]`
- `session_tokens` -> `Session [Y]`
- `model` -> model name (e.g., qwen3:1.7b)
- `tokens_per_second` -> `Z tok/s`
- `gpu_utilization` -> `GPU [A%]`
- `gpu_memory_used` / `gpu_memory_total` -> `B/C MiB`

## ECO Mode

When in ECO mode, show:
```
---
LLM [ECO] Tokens [0] Session [0] | passthrough | N/A | GPU [N/A]
```

## No GPU Available

When GPU is not available (AMD/Intel), show `GPU [N/A]` instead of utilization.

## Example Output

```
Here is the answer to your question about React hooks...

---
LLM [BALANCED] Tokens [245] Session [12450] | qwen3:1.7b | 15.2 tok/s | GPU [32%] 360/2048 MiB
```
