@ECHO OFF
start /b rclone mount UTh: "C:\Users\Nikos Stylianou\.temp_google_drive_uth"
wsl exec "$(pwd)/rclone_read.sh"
cmd /k "C:\Users\Nikos Stylianou\.backhelp\wrapper.bat"
wsl exec "$(pwd)/rclone_read.sh"
wsl --shutdown
taskkill /IM rclone.exe /f