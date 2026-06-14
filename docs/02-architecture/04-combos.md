# Combos — Auto-Fallback Chain

## Apa Itu Combo?

Combo adalah rantai model yang otomatis berganti jika model sebelumnya gagal. Berguna untuk:
- Menghindari rate limit (429)
- Menangani server down (503)
- Memastikan selalu ada model yang tersedia

## Combo yang Tersedia

### gratis

```
oc/mimo-v2.5-free → oc/deepseek-v4-flash-free → kr/claude-sonnet-4.5
```

| Pos | Model | Provider | Status |
|-----|-------|----------|--------|
| 1 | mimo-v2.5-free | OpenCode Free | Gratis, unlimited |
| 2 | deepseek-v4-flash-free | OpenCode Free | Gratis, unlimited |
| 3 | claude-sonnet-4.5 | Kiro AI | Gratis (OAuth) |

### go

```
ocg/kimi-k2.6 → ocg/qwen3.6-plus → ocg/glm-5.1
```

| Pos | Model | Provider | Status |
|-----|-------|----------|--------|
| 1 | kimi-k2.6 | OpenCode Go | Limited quota |
| 2 | qwen3.6-plus | OpenCode Go | Limited quota |
| 3 | glm-5.1 | OpenCode Go | Limited quota |

### gratis-small

```
oc/deepseek-v4-flash-free → kr/glm-5 → oc/north-mini-code-free
```

| Pos | Model | Provider | Status |
|-----|-------|----------|--------|
| 1 | deepseek-v4-flash-free | OpenCode Free | Gratis |
| 2 | glm-5 | Kiro AI | Gratis |
| 3 | north-mini-code-free | OpenCode Free | Gratis |

## Cara Kerja

```
Request ke combo "gratis"
    │
    ├── Coba: mimo-v2.5-free
    │   ├── OK → return response
    │   └── FAIL (429/503) → lanjut
    │
    ├── Coba: deepseek-v4-flash-free
    │   ├── OK → return response
    │   └── FAIL → lanjut
    │
    └── Coba: claude-sonnet-4.5
        ├── OK → return response
        └── FAIL → return error
```

## Membuat Combo Baru

Via 9Router API:

```powershell
# Login dulu
Invoke-RestMethod -Uri "http://localhost:20128/api/auth/login" `
  -Method POST -Body '{"password":"123456"}' `
  -ContentType "application/json" -SessionVariable session

# Buat combo
Invoke-RestMethod -Uri "http://localhost:20128/api/combos" `
  -Method POST `
  -Body '{"name":"my-combo","models":["oc/mimo-v2.5-free","kr/claude-sonnet-4.5"]}' `
  -ContentType "application/json" -WebSession $session
```

## Menggunakan Combo

Di config OpenCode:

```jsonc
{
  "model": "9router/gratis",        // pakai combo "gratis"
  "small_model": "9router/gratis-small"  // pakai combo "gratis-small"
}
```

## Lihat Juga

- [9Router](02-9router.md) — AI gateway
- [Gratis Profile](../03-profiles/01-gratis.md) — Model gratis
- [Go Profile](../03-profiles/02-go.md) — Model berbayar
