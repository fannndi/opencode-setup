# LLM Status Footer

You MUST include a status footer at the end of EVERY response.

## Format

```
---
LLM [MODE] Tokens [X] | model | latency
```

## How to Get Values

Read the file `.opencode/llm-status.json` and display it exactly as formatted:

- `mode` -> `[MODE]` (e.g., 9ROUTER, BALANCED, PERFORMANCE, ECO)
- `last_tokens` -> `Tokens [X]`
- `model` -> model name (e.g., oc/mimo-v2.5-free)
- `latency_ms` -> latency in milliseconds (e.g., `3200ms`)

## Token Calculation

- `last_tokens` = completion_tokens (output tokens)
- `session_tokens` = prompt_tokens + completion_tokens (total tokens in this response)

## GPU Fields

GPU fields are always `N/A` for remote APIs (9Router, OpenAI, etc.). Only show GPU when `gpu_available` is true.

## ECO Mode

When in ECO mode, show:
```
---
LLM [ECO] Tokens [0] | passthrough | N/A
```

## File Not Found

If `.opencode/llm-status.json` does not exist, show:
```
---
LLM [INIT] Tokens [0] | waiting for first response...
```

## Example Output

```
Here is the answer to your question about React hooks...

---
LLM [9ROUTER] Tokens [245] | oc/mimo-v2.5-free | 3200ms
```
