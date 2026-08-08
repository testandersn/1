# =========================================================
# Configurações
# =========================================================

$repoPath      = $PSScriptRoot
if (-not $repoPath) {
    $repoPath = (Get-Location).Path
}

$year          = 2008
$commitMessage = "Contribuição"
$dummyFile     = "activity.txt"

# Identidade do Git
$githubUser = "testandersn"
$userEmail  = "andersn@test.com"

# Repositório remoto
$repoName = "1"
$remoteUrl = "https://github.com/$githubUser/$repoName.git"


# =========================================================
# Entrar na pasta do repositório
# =========================================================

Set-Location $repoPath -ErrorAction Stop


# =========================================================
# Inicializar Git
# =========================================================

if (-not (Test-Path ".git")) {
    Write-Host "Inicializando repositório Git..." -ForegroundColor Yellow

    git init

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao executar git init."
    }

    git branch -M main
}
else {
    Write-Host "Repositório Git já existe." -ForegroundColor Green
}


# =========================================================
# Configurar identidade
# =========================================================

git config user.name $githubUser
git config user.email $userEmail


# =========================================================
# Configurar arquivo
# =========================================================

if (-not (Test-Path $dummyFile)) {
    New-Item -Path $dummyFile -ItemType File -Force | Out-Null
}


# =========================================================
# Configurar origin
# =========================================================

$existingRemote = git remote get-url origin 2>$null

if (-not $existingRemote) {
    Write-Host "Configurando origin..." -ForegroundColor Yellow
    git remote add origin $remoteUrl
}
else {
    Write-Host "Origin já configurado: $existingRemote" -ForegroundColor Green
}


# =========================================================
# Gerar commits
# =========================================================

Write-Host ""
Write-Host "Gerando commits para $year..." -ForegroundColor Cyan
Write-Host "Repositório: $repoPath" -ForegroundColor Cyan
Write-Host ""

for ($month = 1; $month -le 12; $month++) {

    $daysInMonth = [DateTime]::DaysInMonth($year, $month)

    for ($day = 1; $day -le $daysInMonth; $day++) {

        # Horário aleatório entre 09:00 e 19:59:59
        $hour   = Get-Random -Minimum 9 -Maximum 20
        $minute = Get-Random -Minimum 0 -Maximum 60
        $second = Get-Random -Minimum 0 -Maximum 60

        $commitDate = "{0:D4}-{1:D2}-{2:D2}T{3:D2}:{4:D2}:{5:D2}" -f `
            $year, $month, $day, $hour, $minute, $second

        # Adicionar conteúdo
        Add-Content `
            -Path $dummyFile `
            -Value "Contribuição de $commitDate"

        # Staging
        git add $dummyFile

        if ($LASTEXITCODE -ne 0) {
            throw "Falha no git add em $commitDate"
        }

        # Data do autor e do committer
        $env:GIT_AUTHOR_DATE    = $commitDate
        $env:GIT_COMMITTER_DATE = $commitDate

        # Commit
        git commit `
            -m "$commitMessage - $commitDate" `
            --quiet

        if ($LASTEXITCODE -ne 0) {
            throw "Falha no commit em $commitDate"
        }

        Write-Host "Commit criado: $commitDate" -ForegroundColor DarkGray
    }
}


# =========================================================
# Limpar variáveis de ambiente
# =========================================================

Remove-Item Env:\GIT_AUTHOR_DATE `
    -ErrorAction SilentlyContinue

Remove-Item Env:\GIT_COMMITTER_DATE `
    -ErrorAction SilentlyContinue


# =========================================================
# Verificação
# =========================================================

Write-Host ""
Write-Host "Commits criados com sucesso!" -ForegroundColor Green

$total = git rev-list --count HEAD

Write-Host "Total de commits: $total" -ForegroundColor Cyan

Write-Host ""
Write-Host "Últimos commits:" -ForegroundColor Cyan

git log --oneline -5


# =========================================================
# Push
# =========================================================

Write-Host ""
Write-Host "Enviando para o GitHub..." -ForegroundColor Yellow

git push -u origin main

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "O push falhou." -ForegroundColor Red
    Write-Host "Verifique sua autenticação do GitHub e o nome do repositório." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Push concluído!" -ForegroundColor Green