# Create Component — Generate kode boilerplate
# Usage: .\create.ps1 -Type widget|api|test|model -Name login -ProjectPath "C:\project"

param(
    [ValidateSet("widget", "api", "test", "model")]
    [string]$Type,
    
    [string]$Name,
    [string]$ProjectPath
)

$ErrorActionPreference = "Stop"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR

# Source project-resolve
. "$SETUP_DIR\project-resolve.ps1"
. "$SETUP_DIR\llm-adapter.ps1"

# ============================================================
# Resolve project
# ============================================================

if (-not $ProjectPath) {
    $ProjectPath = Get-ActiveProject
}

if (-not $ProjectPath) { Write-Host "[ERROR] No project path" -ForegroundColor Red; exit 1 }
if (-not $Name) { $Name = Read-Host "Nama component" }

$namePascal = ($Name -replace '(^\w|_\w)', { $_.Value.Replace('_','').ToUpper() }).Substring(0,1).ToUpper() + ($Name -replace '(^\w|_\w)', { $_.Value.Replace('_','').ToUpper() }).Substring(1)
$nameCamel = $namePascal.Substring(0,1).ToLower() + $namePascal.Substring(1)

$enrichedContext = Invoke-LLMEnrich -Text "Enhance this component for code generation. Name: $namePascal, Type: $Type, Project: $ProjectPath"
Write-Host "  [LLM] Context enriched for $Type generation" -ForegroundColor Cyan
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║         Generate - $namePascal $Type" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

# ============================================================
# Detect project type
# ============================================================

$isFlutter = Test-Path "$ProjectPath\pubspec.yaml"
$isNode = Test-Path "$ProjectPath\package.json"
$isGo = Test-Path "$ProjectPath\go.mod"

# ============================================================
# Widget (Flutter)
# ============================================================

if ($Type -eq "widget" -and $isFlutter) {
    $outDir = "$ProjectPath\lib\widgets"
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    $file = "$outDir\$nameCamel.dart"
    
@"
import 'package:flutter/material.dart';

class ${namePascal}Widget extends StatelessWidget {
  const ${namePascal}Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('$namePascal'),
    );
  }
}
"@ | Set-Content -Path $file -Encoding UTF8
    Write-Host "  [OK] Created: $file" -ForegroundColor Green
}

# ============================================================
# API Route (Node.js/Go)
# ============================================================

elseif ($Type -eq "api") {
    if ($isGo) {
        $outDir = "$ProjectPath\internal\handler"
        New-Item -ItemType Directory -Force -Path $outDir | Out-Null
        $file = "$outDir\$nameCamel.go"
@"
package handler

import (
    "net/http"
)

func Handle${namePascal}(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusOK)
    w.Write([]byte(`{"message":"$namePascal endpoint"}`))
}
"@ | Set-Content -Path $file -Encoding UTF8
        Write-Host "  [OK] Created: $file" -ForegroundColor Green
    } elseif ($isNode) {
        $outDir = "$ProjectPath\src\api"
        New-Item -ItemType Directory -Force -Path $outDir | Out-Null
        $file = "$outDir\$nameCamel.ts"
@"
import { Router, Request, Response } from 'express';

const router = Router();

router.get('/', (req: Request, res: Response) => {
    res.json({ message: '$nameCamel endpoint' });
});

export default router;
"@ | Set-Content -Path $file -Encoding UTF8
        Write-Host "  [OK] Created: $file" -ForegroundColor Green
    } else {
        Write-Host "  [ERROR] Unsupported project type for API" -ForegroundColor Red
    }
}

# ============================================================
# Test file
# ============================================================

elseif ($Type -eq "test") {
    if ($isFlutter) {
        $outDir = "$ProjectPath\test"
        New-Item -ItemType Directory -Force -Path $outDir | Out-Null
        $file = "$outDir\${nameCamel}_test.dart"
@"
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('${namePascal}', () {
    test('should work correctly', () {
      // Arrange
      // Act
      // Assert
      expect(true, isTrue);
    });
  });
}
"@ | Set-Content -Path $file -Encoding UTF8
    } elseif ($isNode) {
        $outDir = "$ProjectPath\__tests__"
        New-Item -ItemType Directory -Force -Path $outDir | Out-Null
        $file = "$outDir\${nameCamel}.test.ts"
@"
describe('${namePascal}', () => {
  it('should work correctly', () => {
    expect(true).toBe(true);
  });
});
"@ | Set-Content -Path $file -Encoding UTF8
    } elseif ($isGo) {
        $outDir = "$ProjectPath\internal\handler"
        New-Item -ItemType Directory -Force -Path $outDir | Out-Null
        $file = "$outDir\${nameCamel}_test.go"
@"
package handler

import "testing"

func Test${namePascal}(t *testing.T) {
    // Arrange
    // Act
    // Assert
}
"@ | Set-Content -Path $file -Encoding UTF8
    }
    Write-Host "  [OK] Created: $file" -ForegroundColor Green
}

# ============================================================
# Model/Entity
# ============================================================

elseif ($Type -eq "model") {
    if ($isFlutter) {
        $outDir = "$ProjectPath\lib\models"
        New-Item -ItemType Directory -Force -Path $outDir | Out-Null
        $file = "$outDir\${nameCamel}.dart"
@"
class ${namePascal} {
  final String id;
  
  const ${namePascal}({
    required this.id,
  });

  factory ${namePascal}.fromJson(Map<String, dynamic> json) {
    return ${namePascal}(
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
"@ | Set-Content -Path $file -Encoding UTF8
    } elseif ($isGo) {
        $outDir = "$ProjectPath\internal\model"
        New-Item -ItemType Directory -Force -Path $outDir | Out-Null
        $file = "$outDir\$nameCamel.go"
@"
package model

type ${namePascal} struct {
    ID string ` + "`" + `json:"id"` + "`" + `
}
"@ | Set-Content -Path $file -Encoding UTF8
    }
    Write-Host "  [OK] Created: $file" -ForegroundColor Green
}

else {
    Write-Host "  [ERROR] Unsupported type or project" -ForegroundColor Red; exit 1
}

Write-Host ""
Write-Host "  Next: /code-review $file" -ForegroundColor Cyan
Write-Host ""
