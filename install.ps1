#Requires -RunAsAdministrator
param(
    [string[]]$Sections
)

$ErrorActionPreference = "Stop"

$DotfilesDir = $PSScriptRoot
$Config = Join-Path $DotfilesDir "paths.ini"
$HomeDir = $env:USERPROFILE

if (-not (Test-Path $Config)) {
    Write-Error "paths.ini not found in $DotfilesDir"
    exit 1
}

function New-Symlink {
    param(
        [string]$Src,
        [string]$Dest
    )

    if (-not (Test-Path $Src)) {
        Write-Host "  SKIP (source missing): $Src"
        return
    }

    $DestDir = Split-Path $Dest -Parent
    if (-not (Test-Path $DestDir)) {
        New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
        Write-Host "  MKDIR $DestDir"
    }

    if (Test-Path $Dest) {
        $Item = Get-Item $Dest -Force
        if ($Item.LinkType -eq "SymbolicLink") {
            $CurrentTarget = $Item.Target
            if ($CurrentTarget -eq $Src) {
                Write-Host "  OK (already linked): $Dest"
                return
            }
            Remove-Item $Dest -Force
            Write-Host "  REMOVE (old symlink): $Dest"
        } else {
            $Backup = "$Dest.bak"
            Move-Item $Dest $Backup -Force
            Write-Host "  BACKUP $Dest -> $Backup"
        }
    }

    $IsDirectory = (Get-Item $Src) -is [System.IO.DirectoryInfo]
    New-Item -ItemType SymbolicLink -Path $Dest -Target $Src | Out-Null
    Write-Host "  LINK $Dest -> $Src"
}

function Get-ConfigSections {
    $lines = Get-Content $Config
    foreach ($line in $lines) {
        if ($line -match '^\[([^\]]+)\]$') {
            $Matches[1]
        }
    }
}

function Install-Section {
    param([string]$Section)

    Write-Host "[$Section]"

    $InSection = $false
    $lines = Get-Content $Config

    foreach ($line in $lines) {
        $line = $line.Trim()
        if ([string]::IsNullOrEmpty($line) -or $line.StartsWith("#")) { continue }

        if ($line -match '^\[([^\]]+)\]$') {
            $InSection = ($Matches[1] -eq $Section)
            continue
        }

        if (-not $InSection) { continue }

        $parts = $line -split '=', 2
        $SrcRel = $parts[0].Trim()
        $DestRel = $parts[1].Trim()

        $Src = Join-Path $DotfilesDir (Join-Path $Section $SrcRel)
        $Dest = Join-Path $HomeDir $DestRel

        New-Symlink -Src $Src -Dest $Dest
    }
}

if ($Sections.Count -gt 0) {
    $AllSections = Get-ConfigSections
    foreach ($s in $Sections) {
        if ($s -notin $AllSections) {
            Write-Error "Section [$s] not found in paths.ini"
            exit 1
        }
    }
} else {
    $Sections = Get-ConfigSections
}

foreach ($s in $Sections) {
    Install-Section -Section $s
}

Write-Host "Done."
