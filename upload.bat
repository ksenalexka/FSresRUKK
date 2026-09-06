@echo off
title ISU Calc Auto-Sync to Cloudflare
chcp 65001 > nul

:: ==========================================
:: НАСТРОЙКА ПЕРЕД ТУРНИРОМ:
:: 1. Имя папки на компьютере (в программе IsuCalcFS)
set "COMP_FOLDER=ТестовыйФайл2627"

:: 2. Как папка будет называться на сайте в интернете (ТОЛЬКО ЛАТИНИЦА!)
set "SITE_FOLDER=test26"
:: ==========================================

echo [ЗАПУСК] Мониторинг папки: %COMP_FOLDER% -> Интернет-адрес: /%SITE_FOLDER%/
echo Проверка обновлений каждые 10 секунд. Окно не закрывать!
echo ----------------------------------------------------------------

:loop
:: Копируем из русской папки программы в английскую папку сайта
robocopy "C:\IsuCalcFS\%COMP_FOLDER%\html" "C:\IsuOnline\%SITE_FOLDER%" /E /XO /NJH /NJS /NDL /NC

:: Переходим в рабочую папку Git
cd /d "C:\IsuOnline"

:: Проверяем, появились ли новые изменения
git status --porcelain | findstr /R "^" >nul
if %errorlevel% equ 0 (
    echo [%TIME:~0,8%] 🔄 Обнаружены изменения в результатах. Отправка...
    
    git add .
    git commit -m "Auto-update %SITE_FOLDER%: %TIME:~0,8%" >nul
    git push origin main >nul
    
    if %errorlevel% equ 0 (
        echo [%TIME:~0,8%] ✅ Успешно отправлено! Cloudflare обновляет сайт.
        echo ----------------------------------------------------------------
    ) else (
        echo [%TIME:~0,8%] ❌ Ошибка сети! Не удалось отправить в Git. Проверьте интернет.
        echo ----------------------------------------------------------------
    )
)

:: Пауза 10 секунд
timeout /t 10 > nul
goto loop
