#Requires -Version 5.1
<#
.SYNOPSIS
    新建一篇论文的阅读工作区，自动套用模板。

.EXAMPLE
    .\tools\new-paper.ps1 -Name "rag-hallucination-survey"

.EXAMPLE
    .\tools\new-paper.ps1 -Name "agent-memory-benchmark" -Tier A -Year 2025 -Title "Agent Memory Benchmark"

.EXAMPLE
    .\tools\new-paper.ps1 -Name "long-context-attention" -Tier C
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Name,

    [int]$Year = (Get-Date).Year,

    # A = 核心论文（全流程）  B = 重要论文  C = 普通论文
    [ValidateSet('A', 'B', 'C', '')]
    [string]$Tier = '',

    # 论文真实标题，留空则使用 Name
    [string]$Title = '',

    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot          # research/
$templateDir = Join-Path $root 'templates'
$papersDir = Join-Path $root 'papers'

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
$folderName = if ([string]::IsNullOrWhiteSpace($Tier)) { $slug } else { "$Tier-$slug" }

$targetDir = Join-Path (Join-Path $papersDir $Year) $folderName
$displayTitle = if ([string]::IsNullOrWhiteSpace($Title)) { $Name } else { $Title }
$tierLabel = if ([string]::IsNullOrWhiteSpace($Tier)) { '未标注' } else { $Tier }
$created = (Get-Date).ToString('yyyy-MM-dd')

if ((Test-Path -LiteralPath $targetDir) -and -not $Force) {
    throw "目录已存在：$targetDir（加 -Force 覆盖其中的模板文件）"
}

New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

function Initialize-FromTemplate {
    param(
        [string]$TemplateName,
        [string]$FileName,
        [scriptblock]$Transform
    )

    $src = Join-Path $templateDir $TemplateName
    if (-not (Test-Path -LiteralPath $src)) { throw "缺少模板：$src" }

    $dst = Join-Path $targetDir $FileName
    if ((Test-Path -LiteralPath $dst) -and -not $Force) {
        Write-Host "  跳过（已存在）：$FileName" -ForegroundColor DarkGray
        return
    }

    $lines = @(Get-Content -LiteralPath $src -Encoding UTF8)
    $text = ($lines -join "`n")
    $text = & $Transform $text
    Set-Content -LiteralPath $dst -Value $text -Encoding UTF8
    Write-Host "  生成：$FileName" -ForegroundColor Green
}

# ---- paper.md：在标题后插入论文标识块 ----
Initialize-FromTemplate -TemplateName 'paper.md' -FileName 'paper.md' -Transform {
    param($text)
    $block = "> **$displayTitle**`n> Year: $Year · Tier: $tierLabel · Created: $created"
    $safe = $block -replace '\$', '$$'
    $text -replace '(?m)^# Paper Reading[ \t]*$', "# Paper Reading`n`n$safe"
}

# ---- my-judgment.md：填 Metadata 表 ----
Initialize-FromTemplate -TemplateName 'my-judgment.md' -FileName 'my-judgment.md' -Transform {
    param($text)
    $t = $text -replace '(?m)^\| Paper \| \|[ \t]*$',         ("| Paper | $displayTitle |" -replace '\$', '$$')
    $t = $t -replace '(?m)^\| Year / Venue \| \|[ \t]*$', ("| Year / Venue | $Year |" -replace '\$', '$$')
    $t = $t -replace '(?m)^\| 判断日期 \| \|[ \t]*$',      ("| 判断日期 | $created |" -replace '\$', '$$')
    $t
}

# ---- questions.md：无占位符，直接复制 ----
Initialize-FromTemplate -TemplateName 'questions.md' -FileName 'questions.md' -Transform {
    param($text)
    $text
}

Write-Host ""
Write-Host "已创建：$targetDir" -ForegroundColor Cyan
Write-Host "下一步：" -ForegroundColor Cyan
Write-Host "  1. 打开 paper.md，先做 00 Screening（用 prompts/00-screening.md）"
Write-Host "  2. 对话时先给 AI 提供 profile.md + knowledge.md，再给论文"
Write-Host "  3. 每完成一个阶段，把结果写回 paper.md 对应章节"
