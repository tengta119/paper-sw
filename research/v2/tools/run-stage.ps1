#Requires -Version 5.1
<#
.SYNOPSIS
    生成分阶段的 agent 任务；不会调用模型或自动回写分析。
.EXAMPLE
    .\tools\run-stage.ps1 -Paper "example" -Stage 1 -Step Background -Topic "工业视觉异常检测"
.EXAMPLE
    .\tools\run-stage.ps1 -Paper "example" -Stage 1 -Url "https://example.org/paper"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Paper,
    [Parameter(Mandatory = $true)][ValidateSet(1, 2, 3)][int]$Stage,
    [ValidateSet('Background', 'Screening')][string]$Step = 'Screening',
    [string]$Topic = '',
    [ValidateSet('Current', 'Publication')][string]$Perspective = 'Current',
    [string]$Cutoff = '',
    [string]$Url = '',
    [string]$SourcePath = '',
    [string]$BackgroundPath = '',
    [int]$Year = (Get-Date).Year,
    [switch]$NoClipboard
)
$ErrorActionPreference = 'Stop'
$v2Root = Split-Path -Parent $PSScriptRoot
$researchRoot = Split-Path -Parent $v2Root

function Read-Required([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "缺少文件：$Path" }
    $value = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    if ([string]::IsNullOrWhiteSpace($value)) { throw "文件为空：$Path" }
    return $value
}

if ($Stage -ne 1 -and $PSBoundParameters.ContainsKey('Step')) { throw '-Step 仅用于 Stage 1。' }
$values = @{}
if ($Stage -eq 1 -and $Step -eq 'Background') {
    if ([string]::IsNullOrWhiteSpace($Topic)) { throw '背景调查必须提供中性主题 -Topic，不能用目标论文摘要代替。' }
    if ($Url -or $SourcePath -or $BackgroundPath) { throw '背景调查不能传入目标论文材料；请移除 -Url、-SourcePath 和 -BackgroundPath。' }
    if ($Perspective -eq 'Publication' -and -not $Cutoff) { throw '发表时创新性调查必须提供 -Cutoff（YYYY-MM-DD）。' }
    if (-not $Cutoff) { $Cutoff = (Get-Date).ToString('yyyy-MM-dd') }
    $parsedDate = [datetime]::MinValue
    if (-not [datetime]::TryParseExact($Cutoff, 'yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::None, [ref]$parsedDate)) { throw '-Cutoff 必须是有效日期 YYYY-MM-DD。' }
    $promptName = '01-background.md'
    $values['{{TOPIC}}'] = $Topic
    $values['{{PERSPECTIVE}}'] = if ($Perspective -eq 'Publication') { '发表时创新性' } else { '当前阅读价值' }
    $values['{{CUTOFF}}'] = $Cutoff
    $cachePath = Join-Path $v2Root 'background-cache.md'
    $values['{{CACHE}}'] = if (Test-Path -LiteralPath $cachePath) { Read-Required $cachePath } else { '无缓存，请独立调查。' }
    $outputHint = '在全新对话执行背景调查。将结果保存为对应论文目录的 background.md，并更新 v2/background-cache.md；此步不完成 Screening 勾选。'
} else {
    $yearPath = Join-Path $researchRoot "papers\$Year"
    $dirs = @(Get-ChildItem -LiteralPath $yearPath -Directory -ErrorAction SilentlyContinue)
    $matchedDirs = @($dirs | Where-Object { $_.Name -eq $Paper })
    if ($matchedDirs.Count -eq 0) { $matchedDirs = @($dirs | Where-Object { $_.Name.IndexOf($Paper, [StringComparison]::OrdinalIgnoreCase) -ge 0 }) }
    if ($matchedDirs.Count -ne 1) { throw "论文匹配数为 $($matchedDirs.Count)，请检查 -Year，并用唯一完整目录名指定 -Paper。" }
    $paperDir = $matchedDirs[0].FullName
    $paperMd = Join-Path $paperDir 'paper.md'
    $notes = Read-Required $paperMd
    $values['{{PROFILE}}'] = Read-Required (Join-Path $v2Root 'profile.md')
    $knowledgePath = Join-Path $v2Root 'knowledge.md'
    $values['{{KNOWLEDGE}}'] = if (Test-Path -LiteralPath $knowledgePath) { Read-Required $knowledgePath } else { '尚无知识库。' }
    if ($Stage -eq 1) {
        $promptName = '01-screening.md'
        if (-not $BackgroundPath) { $BackgroundPath = Join-Path $paperDir 'background.md' }
        $values['{{BACKGROUND}}'] = Read-Required $BackgroundPath
    } elseif ($Stage -eq 2) { $promptName = '02-reading.md' }
    else { $promptName = '03-synthesis.md' }
    if (-not $Url -and $notes -match '(?m)^\*\*Link\*\*:[ \t]*(https?://\S+)') { $Url = $Matches[1] }
    $material = "已有论文笔记（不是论文原文）：`n$notes"
    if ($Url) { $material += "`n论文链接：$Url（需实际读取后分析）" }
    if ($SourcePath) {
        $resolvedSource = (Resolve-Path -LiteralPath $SourcePath -ErrorAction Stop).Path
        if ([IO.Path]::GetExtension($resolvedSource) -in @('.md', '.txt')) {
            $material += "`n用户提供的论文文本：`n$(Read-Required $resolvedSource)"
        } else { $material += "`n本地论文材料：$resolvedSource（请用相应读取工具打开；此提示词未嵌入文件内容）" }
    }
    if (-not $Url -and -not $SourcePath) { $material += "`n未提供论文原文或链接。先检查笔记材料是否足够；需要原文才能判断的内容应暂停并请求材料，不能编造。" }
    $values['{{PAPER}}'] = $material
    $outputHint = "输出保存至 $paperMd 的 §$Stage；完成后手动勾选对应阶段。Stage 3 同时更新知识库、问题库和必要的背景修正。"
}
$prompt = Read-Required (Join-Path $v2Root "prompts\$promptName")
# 一次性替换，避免再次处理注入正文中的字面占位符。
$prompt = [regex]::Replace($prompt, '\{\{[A-Z]+\}\}', [System.Text.RegularExpressions.MatchEvaluator]{
    param($match)
    if (-not $values.ContainsKey($match.Value)) { throw "未定义占位符：$($match.Value)" }
    return [string]$values[$match.Value]
})
Write-Host $prompt
Write-Host "`n$outputHint" -ForegroundColor Green
if (-not $NoClipboard) {
    try { Set-Clipboard -Value $prompt; Write-Host '已复制到剪贴板。' }
    catch { Write-Warning '无法复制到剪贴板，请手动复制。' }
}
