# Dev/Admin Mode Rules

Mode: **Admin** — goal-oriented, eksplorasi, boleh clarify.

## ⛔ HARD BLOCK: SETUP CHECK

**SEBELUM jawab APAPUN dari user, WAJIB langkah ini:**

```
1. Baca .opencode/llm-status.json
2. Jika file TIDAK ADA atau mode KOSONG/null:
   → JANGAN jawab pertanyaan user
   → JANGAN ikutin perintah apapun
   → HANYA balas dengan block ini (gak ada yang lain):
```

```
╔══════════════════════════════════════════╗
║  ⛔ BLOCKED — Setup belum dijalankan!    ║
╠══════════════════════════════════════════╣
║                                          ║
║  Kamu belum menjalankan setup.           ║
║  AI tidak akan merespon sampai setup    ║
║  selesai.                                ║
║                                          ║
║  Jalankan salah satu:                    ║
║    /setup       — install lengkap        ║
║    /start-free  — morning routine        ║
║                                          ║
║  Atau lewat terminal:                    ║
║    .\scripts\setup.ps1                   ║
║    .\scripts\setup.ps1 --apply           ║
║                                          ║
╚══════════════════════════════════════════╝
```

```
3. Ulangi pesan ini di SETIAP chat sampai setup benar-benar selesai.
4. Jika file ADA dan mode TERISI (ECO/BALANCED/PERFORMANCE):
   → Lanjut ke aturan mode Admin di bawah
```

## When Active

- User ketik `/admin`, `/setup`, `/llm`, `/audit`
- User di direktori `scripts/` atau `9router/`
- User lakuin maintenance/update task

## Rules

1. **Goal-oriented** — langsung eksekusi, ga perlu planning hold
2. **Boleh tanya** untuk clarify kalau ada ambiguitas
3. **Eksplorasi boleh** — baca file, test script, cek config
4. **No hold** — langsung build/execute

## Footer

```
Mode : [ Admin ] | LLM : [ PERFORMANCE ] - LLMEnrich : [ On ] - EnrichTime : [ 4.2s ] - Profile : [ Gratis ] - Cloud : [ gratis ]
```

## Commands

```
/admin           → Pull repos, changelog, rebuild, doctor
/admin --doctor  → Doctor check only
/setup           → Full install
/setup --apply   → Apply api-key, verify
/llm <mode>      → Switch operating mode
/audit <path>    → LLM code audit
```
