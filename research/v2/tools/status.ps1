#Requires -Version 5.1
<#
.SYNOPSIS
    扫描所有论文目录，显示进度

.EXAMPLE
    .\tools\status.ps1

.EXAMPLE
    .\tools\status.ps1 -Year 2024
#>
[CmdletBinding()]
param(
    [int]$Year
)

$ErrorActionPreference = 'Stop'

$v2Root = Split-Path -Parent $PSScriptRoot
$researchRoot = Split-Path -Parent $v2Root
$papersDir = Join-Path $researchRoot 'papers'

if (-not (Test-Path -LiteralPath $papersDir)) {
    Write-Host "还没有 papers/ 目录。" -ForegroundColor Yellow
    return
}

$stages = @('01 Screening', '02 Reading', '03 Synthesis')

$rows = @()

$yearDirs = Get-ChildItem -LiteralPath $papersDir -Directory -ErrorAction SilentlyContinue |
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
            $isDone = $text -match ("\[x\] " + [regex]::Escape($s))
            if ($isDone) { 
                $done++ 
                $flags += '✓' 
            } else { 
                $flags += '·' 
            }
        }

        # 检查是否有One-Sentence Summary
        # 空引用后的分隔线或标题不能被当作总结正文。
        $hasSummary = $text -match '(?m)^### One-Sentence Summary[^\r\n]*\r?\n(?:[ \t]*\r?\n)*>[ \t]*[^\s>][^\r\n]*\r?$'

        $rows += [pscustomobject]@{
            Year      = $y.Name
            Paper     = $p.Name
            Progress  = "$done/3"
            Pipeline  = ($flags -join ' ')
            Summary   = if ($hasSummary) { '✓' } else { '·' }
            Updated   = (Get-Item -LiteralPath $paperMd).LastWriteTime.ToString('yyyy-MM-dd')
        }
    }
}

if ($rows.Count -eq 0) {
    Write-Host "没有找到论文目录。" -ForegroundColor Yellow
    Write-Host "创建第一篇论文：.\tools\new-paper.ps1 -Name <paper-name>" -ForegroundColor Cyan
    return
}

Write-Host ""
$rows | Sort-Object Year, Paper | Format-Table -AutoSize

Write-Host "Pipeline: ✓=完成  ·=未完成  (Screening | Reading | Synthesis)" -ForegroundColor DarkGray
Write-Host "Summary:  ✓=有One-Sentence Summary  ·=没有" -ForegroundColor DarkGray
Write-Host ""
Write-Host ("已完成论文（3/3）：" + (($rows | Where-Object { $_.Progress -eq '3/3' }).Count)) -ForegroundColor Green
Write-Host ("进行中论文：" + (($rows | Where-Object { $_.Progress -ne '3/3' -and $_.Progress -ne '0/3' }).Count)) -ForegroundColor Yellow
Write-Host ("未开始论文（0/3）：" + (($rows | Where-Object { $_.Progress -eq '0/3' }).Count)) -ForegroundColor Cyan
