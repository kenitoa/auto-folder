@echo off
setlocal

set "ROOT=%~dp0"
set "SCRIPT=%ROOT%logic\folder_builder.ps1"
set "INPUT_DIR=%ROOT%Input"

if /I "%~1"=="-DryRun" goto dry_run
if /I "%~1"=="--dry-run" goto dry_run

if defined FOLDER_BUILDER_OUTPUT_DIR (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -OutputDir "%FOLDER_BUILDER_OUTPUT_DIR%"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"
)
set "EXITCODE=%ERRORLEVEL%"

if not "%EXITCODE%"=="0" (
    echo Build failed. Input files were not cleared.
    exit /b %EXITCODE%
)

if exist "%INPUT_DIR%\*.md" (
    del /q "%INPUT_DIR%\*.md"
)
if exist "%INPUT_DIR%\*.txt" (
    del /q "%INPUT_DIR%\*.txt"
)
if exist "%INPUT_DIR%\*.docx" (
    del /q "%INPUT_DIR%\*.docx"
)
if exist "%INPUT_DIR%\*.hwpx" (
    del /q "%INPUT_DIR%\*.hwpx"
)

echo Build complete. Input .md, .txt, .docx, and .hwpx files cleared.
exit /b 0

:dry_run
if defined FOLDER_BUILDER_OUTPUT_DIR (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -OutputDir "%FOLDER_BUILDER_OUTPUT_DIR%" -DryRun
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -DryRun
)
exit /b %ERRORLEVEL%
