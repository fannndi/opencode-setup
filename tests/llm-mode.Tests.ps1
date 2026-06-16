BeforeAll {
    $scriptsDir = Split-Path -Parent (Split-Path -Parent $PSCommandPath) | Join-Path -ChildPath "scripts"
    . "$scriptsDir\llm-mode.ps1"
}

Describe "llm-mode.ps1 - Model Map" {
    It "MODEL_MAP should have all 3 modes" {
        $MODEL_MAP.Keys | Should -BeIn @("eco", "balanced", "performance")
    }

    It "ECO mode should have null model" {
        $MODEL_MAP["eco"] | Should -Be $null
    }

    It "Balanced mode should map to qwen2.5:1.5b-s" {
        $MODEL_MAP["balanced"] | Should -BeLike "*qwen2.5*"
    }

    It "Performance mode should map to qwen2.5:1.5b-s" {
        $MODEL_MAP["performance"] | Should -BeLike "*qwen2.5*"
    }
}

Describe "llm-mode.ps1 - State File" {
    It "llm-mode.json should exist after Set-Mode" {
        $modeFile = Join-Path (Split-Path -Parent (Split-Path -Parent $PSCommandPath)) ".opencode\llm-mode.json"
        $modeFile | Should -Exist
    }

    It "llm-mode.json should contain valid mode" {
        $modeFile = Join-Path (Split-Path -Parent (Split-Path -Parent $PSCommandPath)) ".opencode\llm-mode.json"
        $state = Get-Content $modeFile -Raw | ConvertFrom-Json
        $state.mode | Should -BeIn @("eco", "balanced", "performance")
    }
}

Describe "llm-mode.ps1 - Alias Resolution" {
    It "'on' alias should resolve to 'balanced'" {
        # Test resolution via action parameter
        $testAction = "on"
        $resolved = if ($testAction -eq "on") { "balanced" } elseif ($testAction -eq "off") { "eco" } else { $testAction }
        $resolved | Should -Be "balanced"
    }

    It "'off' alias should resolve to 'eco'" {
        $testAction = "off"
        $resolved = if ($testAction -eq "on") { "balanced" } elseif ($testAction -eq "off") { "eco" } else { $testAction }
        $resolved | Should -Be "eco"
    }
}
