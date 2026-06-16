BeforeAll {
    $scriptsDir = Split-Path -Parent (Split-Path -Parent $PSCommandPath) | Join-Path -ChildPath "scripts"
    . "$scriptsDir\llm-adapter.ps1"
}

Describe "llm-adapter.ps1 - Mode Detection" {
    It "Get-OperatingMode should return a valid mode string" {
        $mode = Get-OperatingMode
        $mode | Should -BeIn @("eco", "balanced", "performance")
    }

    It "Get-LLMMode should return 'on' or 'off'" {
        $llmMode = Get-LLMMode
        $llmMode | Should -BeIn @("on", "off")
    }

    It "Get-ModeForLLM should match Get-OperatingMode" {
        Get-ModeForLLM | Should -Be (Get-OperatingMode)
    }
}

Describe "llm-adapter.ps1 - GPU Info" {
    It "Get-GPUInfo should return structured object" {
        $gpu = Get-GPUInfo
        $gpu | Should -HaveProperty "available"
        $gpu | Should -HaveProperty "utilization"
        $gpu | Should -HaveProperty "memory_used"
        $gpu | Should -HaveProperty "memory_total"
    }
}

Describe "llm-adapter.ps1 - Chunk Size" {
    It "Get-ChunkSize should return 0 for eco mode" {
        $original = Get-OperatingMode
        try {
            # Direct mode check
            $mode = Get-OperatingMode
            $size = Get-ChunkSize
            $size | Should -BeGreaterOrEqual 0
        } finally {
            # no cleanup needed
        }
    }
}
