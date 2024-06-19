@echo off
setlocal

REM Install Git (64-bit)
echo Installing Git...
curl -Lo git-installer.exe https://github.com/git-for-windows/git/releases/download/v2.40.0.windows.1/Git-2.40.0-64-bit.exe
start /wait git-installer.exe /SILENT /NORESTART

REM Add Git to PATH
setx PATH "%PATH%;C:\Program Files\Git\bin"

REM Install Node.js 18 (64-bit)
echo Installing Node.js 18...
curl -Lo node-installer.msi https://nodejs.org/dist/v18.16.0/node-v18.16.0-x64.msi
msiexec /i node-installer.msi /quiet /norestart

REM Install Python 3.11 (64-bit)
echo Installing Python 3.11...
curl -Lo python-installer.exe https://www.python.org/ftp/python/3.11.0/python-3.11.0-amd64.exe
start /wait python-installer.exe /quiet InstallAllUsers=1 PrependPath=1

REM Clone the project from GitHub
echo Cloning the project...
git clone https://github.com/barunespadhy/rangolio
cd rangolio

REM Navigate to the editable-ui folder and install npm dependencies
echo Installing npm dependencies for editable-ui...
powershell -Command "Start-Process powershell -ArgumentList ' -NoProfile -ExecutionPolicy Bypass -Command \"cd frontend\editable-ui;npm install\"' -Wait"
powershell -Command "Start-Process powershell -ArgumentList ' -NoProfile -ExecutionPolicy Bypass -Command \"cd frontend\editable-ui;npm run build\"' -Wait"

REM Navigate to the viewable-ui folder and install npm dependencies
echo Installing npm dependencies for viewable-ui...
powershell -Command "Start-Process powershell -ArgumentList ' -NoProfile -ExecutionPolicy Bypass -Command \"cd frontend\viewable-ui;npm install\"' -Wait"
powershell -Command "Start-Process powershell -ArgumentList ' -NoProfile -ExecutionPolicy Bypass -Command \"cd frontend\viewable-ui;npm run build:ghpages\"' -Wait"
powershell -Command "Start-Process powershell -ArgumentList ' -NoProfile -ExecutionPolicy Bypass -Command \"cd frontend\viewable-ui;npm run build:server\"' -Wait"

REM Navigate to the backend folder
echo Setting up the backend...
cd backend

REM Create Python virtual environment and install dependencies
python -m venv .env
call .env\Scripts\activate.bat
pip install -r requirements.txt

REM Run Django commands
echo Running Django commands...
python manage.py collectstatic --noinput
xcopy /s ..\frontend\editable-ui\dist\index.html .\templates\
python manage.py makemigrations
python manage.py migrate

REM Create a desktop shortcut for managing content
echo Creating desktop shortcut...
powershell -command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut($env:USERPROFILE + '\Desktop\Rangolio - Manage content.lnk'); $s.TargetPath = 'cmd.exe'; $s.Arguments = '/k cd /d %CD% & .env\Scripts\activate.bat & python manage.py runserver & start https://127.0.0.1:8000/'; $s.IconLocation = '%CD%\rangolio\backend\icons\128x128\icon.ico'; $s.Save()"

REM Create a start menu entry for managing content
echo Creating start menu entry...
powershell -command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut($env:APPDATA + '\Microsoft\Windows\Start Menu\Programs\Rangolio - Manage content.lnk'); $s.TargetPath = 'cmd.exe'; $s.Arguments = '/k cd /d %CD% & .env\Scripts\activate.bat & python manage.py runserver & start https://127.0.0.1:8000/'; $s.IconLocation = '%CD%\rangolio\backend\icons\256x256.png'; $s.Save()"

echo Installation completed successfully.

endlocal
pause
