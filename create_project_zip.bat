@echo off
setlocal

:: اسم الملف الناتج
set ZIP_NAME=MariaKindergartenERP.zip

:: حذف النسخة القديمة إن وجدت
if exist "%ZIP_NAME%" del "%ZIP_NAME%"

echo Creating project archive...

powershell -NoProfile -Command ^
"$exclude=@('build','.dart_tool','.git','.idea','.vscode','.tmpdrivedownload','.tmpdriveupload');" ^
"$files=Get-ChildItem -Path . -Recurse | Where-Object { $ok=$true; foreach($e in $exclude){ if($_.FullName -like ('*\' + $e + '\*') -or $_.Name -eq $e){ $ok=$false } }; $ok };" ^
"Compress-Archive -Path $files.FullName -DestinationPath '%ZIP_NAME%' -Force"

echo.
echo =====================================
echo ZIP created successfully:
echo %ZIP_NAME%
echo =====================================
pause