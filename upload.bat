@echo off
title ISU Calc Auto-Sync to Cloudflare
chcp 65001 > nul

echo [ЗАПУСК] Скрипт автоматизации с авто-исправлением путей.
echo Мониторинг: C:\IsuCalcFS\ТестовыйФайл2627\html
echo Окно не закрывать!
echo ----------------------------------------------------------------

:loop
:: 1. Копируем напрямую из папки программы в английскую папку сайта
robocopy "C:\IsuCalcFS\ТестовыйФайл2627\html" "C:\IsuOnline\test26" /E /XO /NJH /NJS /NDL /NC

:: Переходим в рабочую папку Git
cd /d "C:\IsuOnline"

:: 2. Проверяем, появились ли новые изменения
git status --porcelain | findstr /R "^" >nul
if %errorlevel% equ 0 (
    echo [%TIME:~0,8%] 🔄 Обнаружены новые результаты. Исправление путей...
    
    :: Автоматическое исправление локальных адресов судейского ПК на относительные пути
    powershell -Command "if (Test-Path 'test26\index.html') { (Get-Content 'test26\index.html') -replace 'http://localhost:[0-9]+/', './' -replace 'http://127.0.0.1:[0-9]+/', './' | Set-Content 'test26\index.html' }"
    powershell -Command "foreach($f in Get-ChildItem -Path test26 -Filter *.html) { (Get-Content $f.FullName) -replace 'http://localhost', '.' -replace 'http://127.0.0.1', '.' | Set-Content $f.FullName }"

    echo [%TIME:~0,8%] 📤 Отправка в сеть...
    git add .
    git commit -m "Auto-update test26: %TIME:~0,8%" >nul
    git push origin main >nul
    
    if %errorlevel% equ 0 (
        echo [%TIME:~0,8%] ✅ Успешно отправлено! Проверяйте телефон.
        echo ----------------------------------------------------------------
    ) else (
        echo [%TIME:~0,8%] ❌ Ошибка сети! Не удалось отправить в Git.
        echo ----------------------------------------------------------------
    )
)

:: Пауза 10 секунд
timeout /t 10 > nul
goto loop
