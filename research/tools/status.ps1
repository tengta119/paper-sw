#Requires -Version 5.1
<#
.SYNOPSIS
    扫描所有论文目录，显示流水线进度，找出「读到一半停了」的论文。

.EXAMPLE
    .\tools\status.ps1

.EXAMPLE
    # 只看某一年
    .\tools\status.ps1 -Year 2026
#>
[CmdletBinding()]
param(
    [int]$Year
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$papersDir = Join-Path $root 'papers'

if (-not (Test-Path -LiteralPath $papersDir)) {
    Write-Host "还没有 papers/ 目录。" -ForegroundColor Yellow
    return
}

$stages = @(
    '00 Screening', '01 Background', '02 Reading', '03 Logic Check',
    '04 Method Check', '05 Experiment Check', '06 Review', '07 Defense', '08 Synthesis'
)

$rows = @()

$yearDirs = Get-ChildItem -LiteralPath $papersDir -Directory |
    Where-Object { $_.Name -match '^\d{4}$' }

if ($PSBoundParameters.ContainsKey('Year')) {
    $yearDirs = $yearDirs | Where-Object { [int]$_.Name -eq $Year }
}

foreach ($y in $yearDirs) {
    foreach ($p in (Get-ChildItem -LiteralPath $y.FullName -Directory)) {
        $paperMd = Join-Path $p.FullName 'paper.md'
        if (-not (Test-Path -LiteralPath $paperMd)) { continue }

        $text = Get-Content -LiteralPath $paperMd -Raw -Encoding UTF8

        $done = 0
        $flags = @()
        foreach ($s in $stages) {
            $isDone = $text -match ("\| " + [regex]::Escape($s) + " \| .*?(\u2611|\u2714|x|X)")
            if ($isDone) { $done++ ; $flags += '#' } else { $flags += '.' }
        }

        $judged = $false
        if (Test-Path -LiteralPath (Join-Path $p.FullName 'my-judgment.md')) {
            $jj = Get-Content -LiteralPath (Join-Path $p.FullName 'my-judgment.md') -Raw -Encoding UTF8
            # 只有当 「15. One-Sentence Takeaway」下面真的写了内容，才算完成判断
            $idx = $jj.IndexOf('## 15. One-Sentence Takeaway')
            if ($idx -ge 0) {
                $tail = $jj.Substring($idx)
                $judged = ($tail -match '(?m)^>[ \t]*\S')
            }
        }

        $qs = Test-Path -LiteralPath (Join-Path $p.FullName 'questions.md')

        $rows += [pscustomobject]@{
            Year      = $y.Name
            Paper     = $p.Name
            Progress  = "$done/$($stages.Count)"
            Pipeline  = ($flags -join '')
            Judgment  = if ($judged) { 'yes' } else { '-' }
            Questions = if ($qs) { 'yes' } else { '-' }
            Updated   = (Get-Item -LiteralPath $paperMd).LastWriteTime.ToString('yyyy-MM-dd')
        }
    }
}

if ($rows.Count -eq 0) {
    Write-Host "没有找到论文目录。先运行：.\tools\new-paper.ps1 -Name <paper-name>" -ForegroundColor Yellow
    return
}

Write-Host ""
$rows | Sort-Object Year, Paper | Format-Table -AutoSize

Write-Host "Pipeline 列：9 个位置对应 00..08，'#'=已完成，'.'=未完成" -ForegroundColor DarkGray
Write-Host ""
Write-Host ("未完成判断（my-judgment 还没写）的论文：" + (($rows | Where-Object { $_.Judgment -eq '-' }).Count)) -ForegroundColor Yellow
Write-Host ("已完成 9/9 全流程的论文：" + (($rows | Where-Object { $_.Progress -eq '9/9' }).Count)) -ForegroundColor Green
