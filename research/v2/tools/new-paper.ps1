#Requires -Version 5.1
<#
.SYNOPSIS
    新建一篇论文的阅读工作区（v2简化版模板）

.EXAMPLE
    .\tools\new-paper.ps1 -Name "rag-hallucination-survey"

.EXAMPLE
    .\tools\new-paper.ps1 -Name "agent-memory" -Year 2025 -Title "Agent Memory Benchmark"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Name,

    [int]$Year = (Get-Date).Year,

    [string]$Title = '',

    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$v2Root = Split-Path -Parent $PSScriptRoot
$researchRoot = Split-Path -Parent $v2Root
$templateDir = Join-Path $v2Root 'templates'
$papersDir = Join-Path $researchRoot 'papers'

function ConvertTo-Slug {
    param([string]$Text)
    $s = $Text.ToLowerInvariant()
    $s = $s -replace '[\s_]+', '-'
    $s = $s -replace '[^a-z0-9\-\.]', '-'
    $s = $s -replace '-{2,}', '-'
    $s = $s.Trim('-', '.')
    if ([string]::IsNullOrWhiteSpace($s)) { throw "无法从 '$Text' 生成合法目录名" }
    return $s
}

$slug = ConvertTo-Slug $Name
$targetDir = Join-Path (Join-Path $papersDir $Year) $slug
$displayTitle = if ([string]::IsNullOrWhiteSpace($Title)) { $Name } else { $Title }
$created = (Get-Date).ToString('yyyy-MM-dd')

if ((Test-Path -LiteralPath $targetDir) -and -not $Force) {
    throw "目录已存在：$targetDir`n（加 -Force 覆盖其中的模板文件）"
}

New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

# 复制模板
$templateFile = Join-Path $templateDir 'paper.md'
if (-not (Test-Path -LiteralPath $templateFile)) { 
    throw "缺少模板：$templateFile" 
}

$dstFile = Join-Path $targetDir 'paper.md'
if ((Test-Path -LiteralPath $dstFile) -and -not $Force) {
    Write-Host "  跳过（已存在）：paper.md" -ForegroundColor DarkGray
} else {
    $content = Get-Content -LiteralPath $templateFile -Raw -Encoding UTF8
    
    # 替换元数据
    $content = $content.Replace('[论文标题]', $displayTitle)
    $content = $content.Replace('Year: YYYY', "Year: $Year")
    $content = $content.Replace('Date: YYYY-MM-DD', "Date: $created")
    
    Set-Content -LiteralPath $dstFile -Value $content -Encoding UTF8
    Write-Host "  生成：paper.md" -ForegroundColor Green
}

Write-Host ""
Write-Host "已创建：$targetDir" -ForegroundColor Cyan
Write-Host ""
Write-Host "下一步：" -ForegroundColor Yellow
Write-Host "  1. 先在新对话执行背景调查（中性主题，不提供目标论文）：" -ForegroundColor White
Write-Host "     .\tools\run-stage.ps1 -Paper `"$slug`" -Year $Year -Stage 1 -Step Background -Topic `"<中性主题>`"" -ForegroundColor Gray
Write-Host "     保存输出到 $targetDir\background.md，再执行筛选：" -ForegroundColor White
Write-Host "     .\tools\run-stage.ps1 -Paper `"$slug`" -Year $Year -Stage 1 -Url `"<论文链接>`"" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. 如果值得读，继续阶段2 (Reading)：" -ForegroundColor White
Write-Host "     .\tools\run-stage.ps1 -Paper `"$slug`" -Year $Year -Stage 2" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. 最后执行阶段3 (Synthesis)：" -ForegroundColor White
Write-Host "     .\tools\run-stage.ps1 -Paper `"$slug`" -Year $Year -Stage 3" -ForegroundColor Gray
Write-Host ""
