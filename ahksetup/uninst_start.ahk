#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

if !A_IsCompiled
	ExitApp
FileCreateDir, %A_Temp%\Uninstall
FileInstall, #uninstaller#, %A_Temp%\Uninstall\Uninstaller.exe, 1
Run, %A_Temp%\Uninstall\Uninstaller.exe "%A_ScriptDir%"
ExitApp