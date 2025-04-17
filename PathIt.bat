@echo off
set "todofy=C:\Users\sonic515\Documents\college and work\Projects\Batch_projects\todofy"

:: Check if the path is already in PATH
echo %PATH% | find /I "%todofy%" >nul
if not errorlevel 1 (
    echo ✅ Already in PATH
    goto :eof
)

:: Append todofy path to the user PATH with proper formatting
powershell -Command "[Environment]::SetEnvironmentVariable('PATH', [Environment]::GetEnvironmentVariable('PATH', 'User') + ';%todofy%', 'User')"

echo ✅ 'todofy' path added to User PATH.
echo Please restart CMD or sign out/in for changes to apply.
