#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

FileInstall, gnu_gpl_EN.txt, % A_Temp . "\gnu_gpl_EN.txt", 1
FileInstall, gnu_gpl_DE.txt, % A_Temp . "\gnu_gpl_DE.txt", 1

If(!DllCall("AttachConsole", "int", -1)){
	ExitApp
}

SplitPath, A_AhkPath,, AhkRoot
next_param := "source"
single := 0
gnu_gpl := 0
destination := ""
language := "EN"

param1=%1%
param2=%2%
param3=%3%
param4=%4%
param5=%5%
param6=%6%
param7=%7%
param8=%8%
Loop, 8
{
	tmp := param%A_Index%
	if(tmp == "")
		break
	if(next_param != ""){
		%next_param% := tmp
		next_param := ""
		continue
	}
	if(tmp == "-li")
	{
		next_param := "license"
		continue
	}
	if(tmp == "-lang")
	{
		next_param := "language"
		continue
	}
	if(tmp == "-gnu_gpl")
	{
		gnu_gpl := 1
		license := 1
		continue
	}
	if(tmp == "-s")
	{
		single := 1
		continue
	}
	if(tmp == "-d")
	{
		next_param := "destination"
		continue
	}
	;in case of wrong parameter, show syntax help:
	source := ""
	break
}

if(!source or !license)
{
	FileAppend, % "`n`nSYNTAX:`nbuild [Source] [-li License | -gnu_gpl] [-d Dest] [-lang Language] [-s]`n`n", CONOUT$
	FileAppend, % "    [Source]`n", CONOUT$
	FileAppend, % "       Can be any executable. Source folder must contain appinfo`.ini`n`n", CONOUT$
	FileAppend, % "    [-li License | -gnu_gpl]`n", CONOUT$
	FileAppend, % "       LicenseFile: Can be any txt file holding the license text.`n", CONOUT$
	FileAppend, % "       -gnu_gpl:    Use standard GNU General Public License v3`n`n", CONOUT$
	FileAppend, % "    [-d Dest]            (optional)`n", CONOUT$
	FileAppend, % "       The setup file's destination (defaults to directory of 'Source')`n`n", CONOUT$
	FileAppend, % "    [-lang Language]     (optional)`n", CONOUT$
	FileAppend, % "       The setup language (and gpl language in case of -gnu_gpl)`n", CONOUT$
	FileAppend, % "       Available languages: EN, DE  (defaults to EN)`n`n", CONOUT$
	FileAppend, % "    [-s]                 (optional)`n", CONOUT$
	FileAppend, % "       'single-mode', don't include resources from 'Source' directory", CONOUT$
	gosub, Exit
}

SplitPath, source, source_exe, source_dir

FileDelete, log.txt

console_log("`n")
console_log("starting...`n")
if !FileExist(source_dir . "\appinfo.ini"){
	console_log("ERROR: Couldn't find " . source_dir . "\appinfo.ini")
	gosub, Exit
} else {
	IniRead, AppName, % source_dir . "\appinfo.ini", AppInfo, AppName, % A_Space
	IniRead, AppVersion, % source_dir . "\appinfo.ini", AppInfo, AppVersion, % A_Space
	IniRead, AppUpdateVersion, % source_dir . "\appinfo.ini", AppInfo, AppUpdateVersion, % A_Space
	IniRead, AppAuthorName, % source_dir . "\appinfo.ini", AppInfo, AppAuthorName, % A_Space
	IniRead, AppAuthorEmail, % source_dir . "\appinfo.ini", AppInfo, AppAuthorEmail, % A_Space
	IniRead, AppChangelog, % source_dir . "\appinfo.ini", AppInfo, AppChangelog, % A_Space
	IniRead, AppStdInstall, % source_dir . "\appinfo.ini", AppInfo, AppStdInstall, % AppName
	IniRead, AppWebsite, % source_dir . "\appinfo.ini", AppInfo, AppWebsite, % A_Space
	IniRead, AppIcon, % source_dir . "\appinfo.ini", AppInfo, AppIcon, %A_WorkingDir%\setupicon.ico
	AppInfoIncomplete := (!AppName or !AppVersion or !AppUpdateVersion or !AppAuthorName or !AppAuthorEmail)
	if AppInfoIncomplete {
		console_log("ERROR: Incomplete appinfo.ini!")
		gosub, Exit
	}
	AppChangelogAvailable := !(!AppChangelog)
	AppWebsiteAvailable := !(!AppWebsite)
}
console_log("Application Info:`n")
console_log("AppName=" . AppName . "`n")
console_log("AppVersion=" . AppVersion . "`n")
console_log("AppUpdateVersion=" . AppUpdateVersion . "`n")
console_log("AppAuthorName=" . AppAuthorName . "`n")
console_log("AppAuthorEmail=" . AppAuthorEmail . "`n")
console_log("AppStdInstall=" . AppAuthorEmail . "`n")
console_log("AppChangelogAvailable=" . AppChangelogAvailable . "`n")
if AppChangelogAvailable
	console_log("AppChangelog=" . AppChangelog . "`n")
console_log("AppWebsiteAvailable=" . AppWebsiteAvailable . "`n")
if AppWebsiteAvailable
	console_log("AppWebsite=" . AppWebsite . "`n")
if(gnu_gpl){
	console_log("license: GNU General Public License v3`n")
	console_log("         language: " . language . "`n")
	if(!FileExist(A_Temp . "\gnu_gpl_" . language . ".txt")){
		console_log("WARNING: GNU GPL not available in language " . language . "`n")
		console_log("         (check www.gnu.org/licenses/translations.html and download manually)`n")
		console_log("         GNU GPL language set to default (EN)`n")
		language := "EN"
	}
	license := A_Temp . "\gnu_gpl_" . language . "`.txt"
}
if(!FileExist(source)){
	console_log("ERROR: source file does not exist!`n")
	gosub, Exit
}
if(!FileExist(license)){
	console_log("ERROR: license file does not exist!`n")
	gosub, Exit
}
FileRead, license_content, %license%
if(!FileExist(AppIcon) or (AppIcon == "setupicon.ico")){
	AppIcon := source_dir . "\" . AppIcon
	if(!FileExist(AppIcon)){
		console_log("ERROR: specified icon file does not exist!`n")
		gosub, Exit
	}
}
if(destination == ""){
	destination := source_dir . "\" . AppName . " Setup.exe"
	console_log("Using standard destination.`n")
}
console_log("creating environment`, writing instruction file 1/2...`n")
FileRemoveDir, build, 1
FileCreateDir, build
instructions := "Gui`,Submit`,NoHide`n"
instr_amount_counter := 0
qm="
FileDelete, instructions
FileDelete, license.txt
if(single) {
	console_log("single mode`n")
} else {
	rel_pos := StrLen(source_dir) + 2
	console_log("copying directory structure from " . source_dir . ":`n")
	Loop, Files, %source_dir%\*.*, DR
	{
		rel_path := SubStr(A_LoopFileFullPath, rel_pos)
		console_log(instr_amount_counter . ": " . rel_path . " - ")
		console_log(" create dir...")
		FileCreateDir, build\%rel_path%
		console_log(" write instr...`n")
		instructions .= "log(label11 `. " . qm . "\" . rel_path  . qm . ")`nFileCreateDir`, `% label11 `. " . qm . "\" . rel_path  . qm . "`ninstr_count++`nprogress := floor(100*(instr_count/instr_amount))`nGuiControl,, label14, `% progress`nGuiControl,, label15, `%progress`% ```%`n"
		instr_amount_counter ++
	}
	console_log("copying resources from " . source_dir . ":`n")
	Loop, Files, %source_dir%\*.*, FR
	{
		rel_path := SubStr(A_LoopFileFullPath, rel_pos)
		console_log(instr_amount_counter . ": " . rel_path . " -")
		console_log(" copy file...")
		FileCopy, %A_LoopFileFullPath%, build\%rel_path%
		console_log(" write instr...`n")
		instructions .= "log(label11 `. " . qm . "\" . rel_path  . qm . ")`nFileInstall`," . rel_path . "`, `% label11 `. " . qm . "\" . rel_path  . qm . ",1`ninstr_count++`nprogress := floor(100*(instr_count/instr_amount))`nGuiControl,, label14, `% progress`nGuiControl,, label15, `%progress`% ```%`n"
		instr_amount_counter ++
	}
}
console_log("writing instruction file 2/2...`n")

instr_amount_counter ++
instructions .= "log(" . qm . "Registry..." . qm . ")`n"
instructions .= "AppKey := " . qm . "SOFTWARE\" . AppName . qm . "`n"
instructions .= "UninstallKey := " . qm . "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" . AppName . qm . "`n"
instructions .= "AppPathKey := " . qm . "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\" . source_exe . qm . "`n"
instructions .= "SetRegView `% (A_Is64bitOS ? 64 : 32)`n"
instructions .= "RegWrite REG_SZ, HKLM, `%AppKey`%, InstallDir, `%label11`%`n"
instructions .= "RegWrite REG_SZ, HKLM, `%AppKey`%, Version, `%CONST_SETUP_APPVERSION`%`n"
instructions .= "RegWrite REG_SZ, HKLM, `%UninstallKey`%, DisplayName, `%CONST_SETUP_TITLE`%`n"
instructions .= "RegWrite REG_SZ, HKLM, `%UninstallKey`%, UninstallString, " . qm . "`%label11`%\Uninstall.exe" . qm . "`n"
instructions .= "RegWrite REG_SZ, HKLM, `%UninstallKey`%, DisplayIcon, " . qm . "`%label11`%\" . source_exe . qm . "`n"
instructions .= "RegWrite REG_SZ, HKLM, `%UninstallKey`%, DisplayVersion, `%CONST_SETUP_APPVERSION`%`n"
instructions .= "RegWrite REG_SZ, HKLM, `%UninstallKey`%, URLInfoAbout, `%CONST_SETUP_APPWEBSITE`%`n"
instructions .= "RegWrite REG_SZ, HKLM, `%UninstallKey`%, Publisher, `%CONST_SETUP_APPAUTHORNAME`%`n"
instructions .= "RegWrite REG_SZ, HKLM, `%UninstallKey`%, NoModify, 1`n"
instructions .= "RegWrite REG_SZ, HKLM, `%AppPathKey`%,, `%label11`%\" . source_exe . "`n"
instructions .= "instr_count++`nprogress := floor(100*(instr_count/instr_amount))`nGuiControl,, label14, `% progress`nGuiControl,, label15, `%progress`% ```%`n"

instructions := "instr_count := 0`ninstr_amount := " instr_amount_counter . "`n" . instructions
console_log("----- instruction output -----`n" . instructions . "------------------------------`n")
console_log("processing:`n")
console_log("adding setup_template...`n")
uniquename := A_TickCount
while (FileExist("build\" . uniquename . "`.ahk")){
	uniquename .= 0
}
template_file := "build\" . uniquename . "`.ahk"

FileAppend, RunAsAdmin()`n, % template_file
FileAppend, #Include ../lang_packages/%language%.lp`n, % template_file
FileAppend, CONST_SETUP_TITLE := "%AppName% %AppVersion%"`n, % template_file
FileAppend, CONST_SETUP_APPNAME := "%AppName%"`n, % template_file
FileAppend, CONST_SETUP_APPEXE := "%source_exe%"`n, % template_file
FileAppend, CONST_SETUP_APPVERSION := "%AppVersion%"`n, % template_file
FileAppend, CONST_SETUP_STD_FOLDER := "%AppStdInstall%"`n, % template_file
FileAppend, CONST_SETUP_APPWEBSITE := "%AppWebsite%"`n, % template_file
FileAppend, CONST_SETUP_APPAUTHORNAME := "%AppAuthorName%"`n, % template_file
FileAppend, CONST_SETUP_APPWEBSITEAVAILABLE := %AppWebsiteAvailable%`n, % template_file
FileRead, template_content, setup_template.ahk
FileAppend, % template_content, % template_file


console_log("instructions to file...`n")
FileAppend, % instructions, instructions
console_log("license to file...`n")

keywords := "AppName|AppVersion|AppUpdateVersion|AppAuthorName|AppAuthorEmail"
Loop, Parse, keywords, |
StringReplace, license_content, license_content, % "%" . A_LoopField . "%", % %A_LoopField%, 1
FileAppend, % license_content, license.txt

console_log("compiling setup executable... ")

RunWait, %AhkRoot%\Compiler\Ahk2Exe.exe /in "%A_WorkingDir%\build\%uniquename%.ahk" /out "%destination%" /icon "%AppIcon%"

console_log("(" . errorlevel . ")`n")
CompilingError := (errorlevel != 0)
if (CompilingError) {
	console_log("ERROR occured while compiling. See error message for further information.")
	gosub, Exit
}

console_log("build completed! Setup file saved as: " . destination)

Exit:
console_log("`nremoving temporary files...")
FileDelete, instructions
FileDelete, license.txt
FileRemoveDir, build, 1
console_log("`n---`nbuild.exe is terminated`n")
ExitApp


console_log(text){
	FileAppend, % text, CONOUT$
	FileAppend, % text, log.txt
}