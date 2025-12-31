
# ====================================================================
# GraTech X — ALL-IN-ONE EXECUTOR (Verify → Fix → Commit → Push)
# ====================================================================
$ErrorActionPreference = 'Stop'

# ---- Settings
$UserName   = 'gratechx'
$ProfileRepo= "$UserName/$UserName"
$WorkDir    = "C:\\Users\\admin\\gratechx"

# ---- Helpers
function Write-Ok($msg){ Write-Host ("✅ " + $msg) -ForegroundColor Green }
function Write-No($msg){ Write-Host ("❌ " + $msg) -ForegroundColor Red }
function Run($cmd){ Write-Host ("→ " + $cmd) -ForegroundColor Cyan; iex $cmd }

# ---- Ensure GitHub CLI
try { gh --version | Out-Null; Write-Ok "gh موجود" }
catch {
  try { winget install --id GitHub.cli -e | Out-Null; Write-Ok "gh تم تثبيته" }
  catch { Write-No "ثبّت GitHub CLI يدويًا: https://cli.github.com"; throw }
}

# ---- Auth & active account
try { gh auth status | Out-Null }
catch { gh auth login }

# اجعل الحساب الفعّال هو المستخدم الشخصي المطلوب
try { gh auth switch -u $UserName | Out-Null; Write-Ok "الحساب الفعّال: $UserName" }
catch { Write-No "تعذّر switch للحساب $UserName" }

# ---- Ensure special profile repo
try { gh repo view $ProfileRepo --json name | Out-Null; Write-Ok "الريبو $ProfileRepo موجود" }
catch { gh repo create $UserName --public --confirm; Write-Ok "تم إنشاء $ProfileRepo" }

# ---- Clone / Enter workdir
if (!(Test-Path $WorkDir)) {
  git clone "https://github.com/$ProfileRepo.git" $WorkDir
}
Set-Location $WorkDir

# ---- Remote sanity
try { git ls-remote --exit-code origin | Out-Null }
catch { git remote add origin "https://github.com/$ProfileRepo.git" }

# ---- Assets: SVG base + Dark/3D/Neon variations
New-Item -ItemType Directory -Path assets -Force | Out-Null

# Base X mark
$svgBase = @'
<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 240 240">
  <rect width="240" height="240" rx="28" fill="#0f1318"/>
  <g stroke="#5DE2FF" stroke-width="18" stroke-linecap="round">
    <line x1="60" y1="60" x2="180" y2="180"/>
    <line x1="180" y1="60" x2="60" y2="180"/>
  </g>
  <text x="120" y="215" text-anchor="middle" fill="#A8F0FF" font-family="Segoe UI,Roboto" font-size="24">GraTech X</text>
</svg>
'@
Set-Content assets/logo.svg -Value $svgBase -Encoding UTF8

# Dark variant (same background, thicker glow)
$svgDark = @'
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 240 240">
  <defs>
    <filter id="softGlow" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur stdDeviation="2" result="blur"/>
      <feMerge>
        <feMergeNode in="blur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>
  <rect width="240" height="240" rx="28" fill="#0b1116"/>
  <g stroke="#5DE2FF" stroke-width="20" stroke-linecap="round" filter="url(#softGlow)">
    <line x1="60" y1="60" x2="180" y2="180"/>
    <line x1="180" y1="60" x2="60" y2="180"/>
  </g>
  <text x="120" y="215" text-anchor="middle" fill="#A8F0FF" font-family="Segoe UI,Roboto" font-size="24">GraTech X</text>
</svg>
'@
Set-Content assets/logo-dark.svg -Value $svgDark -Encoding UTF8

# 3D variant (pseudo depth via offset)
$svg3D = @'
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 240 240">
  <rect width="240" height="240" rx="28" fill="#0f1318"/>
  <g stroke="#0AAFD0" stroke-width="18" stroke-linecap="round">
    <line x1="66" y1="66" x2="186" y2="186" opacity="0.45"/>
    <line x1="186" y1="66" x2="66" y2="186" opacity="0.45"/>
  </g>
  <g stroke="#5DE2FF" stroke-width="18" stroke-linecap="round">
    <line x1="60" y1="60" x2="180" y2="180"/>
    <line x1="180" y1="60" x2="60" y2="180"/>
  </g>
  <text x="120" y="215" text-anchor="middle" fill="#A8F0FF" font-family="Segoe UI,Roboto" font-size="24">GraTech X</text>
</svg>
'@
Set-Content assets/logo-3d.svg -Value $svg3D -Encoding UTF8

# Neon variant
$svgNeon = @'
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 240 240">
  <defs>
    <filter id="neonGlow" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur stdDeviation="3" result="g1"/>
      <feGaussianBlur stdDeviation="6" in="g1" result="g2"/>
      <feMerge>
        <feMergeNode in="g2"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
    <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%"  stop-color="#00f0ff"/>
      <stop offset="100%" stop-color="#ff00f7"/>
    </linearGradient>
  </defs>
  <rect width="240" height="240" rx="28" fill="#0b0f14"/>
  <g stroke="url(#grad)" stroke-width="18" stroke-linecap="round" filter="url(#neonGlow)">
    <line x1="60" y1="60" x2="180" y2="180"/>
    <line x1="180" y1="60" x2="60" y2="180"/>
  </g>
  <text x="120" y="215" text-anchor="middle" fill="#A8F0FF" font-family="Segoe UI,Roboto" font-size="24">GraTech X</text>
</svg>
'@
Set-Content assets/logo-neon.svg -Value $svgNeon -Encoding UTF8

# Optional PNG export if Inkscape exists
$ink = 'C:\\Program Files\\Inkscape\\inkscape.exe'
if (Test-Path $ink) {
  & $ink assets/logo-dark.svg  --export-type=png --export-filename=assets/logo-dark.png
  & $ink assets/logo-3d.svg    --export-type=png --export-filename=assets/logo-3d.png
  & $ink assets/logo-neon.svg  --export-type=png --export-filename=assets/logo-neon.png
}

# ---- README Brand Kit injection (idempotent)
$brand = @'
## Brand Kit · شعارات GraTech X

**Dark**
<img src='assets/logo-dark.png' alt='GraTech X Dark' height='120' />

**3D**
<img src='assets/logo-3d.png' alt='GraTech X 3D' height='120' />

**Neon**
<img src='assets/logo-neon.png' alt='GraTech X Neon' height='120' />
'@
if (Test-Path README.md) {
  $r = Get-Content README.md -Raw
  if ($r -match '## Brand Kit') { $r = $r -replace '## Brand Kit[\s\S]*$', $brand }
  else { $r = $r + "`n`n" + $brand }
  Set-Content README.md -Value $r -Encoding UTF8
} else {
  Set-Content README.md -Value $brand -Encoding UTF8
}

# ---- Workflow YAML (use single-quoted here-string to avoid pwsh expansion)
$wf = @'
name: Update Profile README
on:
  schedule:
    - cron: '0 3 * * *'
  workflow_dispatch:
jobs:
  refresh:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Heartbeat
        shell: bash
        run: echo "profile heartbeat: $(date -u)" >> .profile.log
'@
New-Item -ItemType Directory -Path .github/workflows -Force | Out-Null
Set-Content .github/workflows/update-profile.yml -Value $wf -Encoding UTF8

# ---- Commit & Push with retry if 403/permission issues
function Try-Push {
  git add -A
  git commit -m "chore(profile): assets+README+workflow" 2>$null
  git push
  if ($LASTEXITCODE -ne 0) {
    Write-No "push فشل — محاولة إصلاح الاعتماد"
    gh auth switch -u $UserName
    git remote set-url origin "https://github.com/$ProfileRepo.git"
    git config user.name  $UserName
    git config user.email "$UserName@users.noreply.github.com"
    git push
  } else { Write-Ok "push نجح" }
}
Try-Push

# ---- Trigger workflow (best-effort)
try { gh workflow run "Update Profile README" | Out-Null } catch {}
try { gh run list --limit 1 } catch {}

# ---- Open Billing & Support (optional)
Start-Process "https://github.com/settings/billing"
Start-Process "https://support.github.com/contact"

Write-Ok "تم التنفيذ — راجع البروفايل والريلز."
# ====================================================================
