BeforeAll {
    $rootDir = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
}

Describe "Profile Configs - Syntax" {
    It "Gratis profile should be valid JSONC" {
        $path = Join-Path $rootDir "profiles\gratis\opencode.jsonc"
        $path | Should -Exist
        $content = Get-Content $path -Raw
        # Must have valid JSON structure — should contain opening and closing braces
        $content | Should -Match '\A\s*\{'
        $content | Should -Match '\}\s*\Z'
    }

    It "Go profile should be valid JSONC" {
        $path = Join-Path $rootDir "profiles\go\opencode.jsonc"
        $path | Should -Exist
        $content = Get-Content $path -Raw
        $content | Should -Match '\A\s*\{'
        $content | Should -Match '\}\s*\Z'
    }
}

Describe "Profile Configs - Commands" {
    It "Gratis profile should have unique command keys" {
        $path = Join-Path $rootDir "profiles\gratis\opencode.jsonc"
        $content = Get-Content $path -Raw
        $commands = [regex]::Matches($content, '"(\w[\w-]+)":\s*\{')
        $names = $commands.Groups[1].Value
        $names.Count | Should -Be ($names | Select-Object -Unique).Count
    }

    It "Go profile should have unique command keys" {
        $path = Join-Path $rootDir "profiles\go\opencode.jsonc"
        $content = Get-Content $path -Raw
        $commands = [regex]::Matches($content, '"(\w[\w-]+)":\s*\{')
        $names = $commands.Groups[1].Value
        $names.Count | Should -Be ($names | Select-Object -Unique).Count
    }
}

Describe "Scripts - Required Functions" {
    It "llm-adapter.ps1 should define Invoke-LLM" {
        $path = Join-Path $rootDir "scripts\llm-adapter.ps1"
        $content = Get-Content $path -Raw
        $content | Should -Match "function Invoke-LLM"
    }

    It "llm-adapter.ps1 should define Invoke-LLMEnrich" {
        $path = Join-Path $rootDir "scripts\llm-adapter.ps1"
        $content = Get-Content $path -Raw
        $content | Should -Match "function Invoke-LLMEnrich"
    }

    It "llm-mode.ps1 should define MODEL_MAP" {
        $path = Join-Path $rootDir "scripts\llm-mode.ps1"
        $content = Get-Content $path -Raw
        $content | Should -Match '\$MODEL_MAP'
    }
}

Describe "Instructions - Required Files" {
    It "llm-status-footer.md should exist" {
        Join-Path $rootDir "instructions\llm-status-footer.md" | Should -Exist
    }

    It "llm-preprocess.md should exist in ecc" {
        Join-Path $rootDir "ecc\.opencode\instructions\llm-preprocess.md" | Should -Exist
    }
}
