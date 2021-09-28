@ECHO OFF
start /b rclone mount UTh: "C:/Users/%USERNAME%/.temp_google_drive_uth"
wsl exec "./rclone_multi.sh" before
ping 127.0.0.1 -n 6 > nul
cmd /k "C:\Users\%Nikos Stylianou%\.backhelp\wrapper.bat"
wsl exec "./rclone_multi.sh" after
wsl --shutdown
taskkill /IM rclone.exe /f