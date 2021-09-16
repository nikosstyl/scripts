
start /b rclone mount UTh: "C:\Users\Nikos Stylianou\.temp_google_drive_uth"
awsl exec "./$(pwd)/rclone_multi.sh" before
cmd /k "C:\Users\Nikos Stylianou\.backhelp\wrapper.bat"
wsl exec "$(pwd)/rclone_multi.sh" after
wsl --shutdown
taskkill /IM rclone.exe /f
