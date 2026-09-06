@echo off
title ISU Calc Auto-Sync to Cloudflare
chcp 65001 > nul

echo [ЗАПУСК] Скрипт автоматизации активен.
echo Мониторинг: C:\IsuCalcFS\ТестовыйФайл2627\html
echo Окно не закрывать!
echo ----------------------------------------------------------------

:loop
:: Копируем напрямую из папки программы в английскую папку сайта
robocopy "C:\IsuCalcFS\ТестовыйФайл2627\html" "C:\IsuOnline\test26" /E /XO /NJH /NJS /NDL /NC

:: Переходим в рабочую папку Git
cd /d "C:\IsuOnline"

:: Проверяем, появились ли новые изменения
git status --porcelain | findstr /R "^" >nul
if %errorlevel% equ 0 (
    echo [%TIME:~0,8%] 🔄 Обнаружены новые результаты из ISU Calc. Отправка...
    
    git add .
    git commit -m "Auto-update test26: %TIME:~0,8%" >nul
    git push origin main >nul
    
    if %errorlevel% equ 0 (
        echo [%TIME:~0,8%] ✅ Успешно отправлено! Cloudflare обновляет сайт.
        echo ----------------------------------------------------------------
    ) else (
        echo [%TIME:~0,8%] ❌ Ошибка сети! Не удалось отправить в Git.
        echo ----------------------------------------------------------------
    )
)

:: Пауза 10 секунд
timeout /t 10 > nul
goto loop
