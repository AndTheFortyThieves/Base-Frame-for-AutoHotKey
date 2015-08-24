#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

FileInstall, gnu_gpl_EN.txt, % A_Temp . "\gnu_gpl_EN.txt", 1
FileInstall, gnu_gpl_DE.txt, % A_Temp . "\gnu_gpl_DE.txt", 1

If(!DllCall("AttachConsole", "int", -1)){
	ExitApp
}


next_param := "source"
single := 0
gnu_gpl := 0
language := "EN"

param1=%1%
param2=%2%
param3=%3%
param4=%4%
param5=%5%
Loop, 5
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

SplitPath, source,, source_dir

FileDelete, log.txt

console_log("`n")
console_log("starting...`n")
if !FileExist(source_dir . "\appinfo.ini"){
	console_log("ERROR: Couldn't find " . source_dir . "\appinfo.ini")
}
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
	FileRead, license_content, %license%
}
if(!FileExist(source)){
	console_log("ERROR: source file does not exist!`n")
	gosub, Exit
}
if(!FileExist(license)){
	console_log("ERROR: license file does not exist!`n")
	gosub, Exit
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

instructions := "instr_count := 0`ninstr_amount := " instr_amount_counter . "`n" . instructions
console_log("----- instruction output -----`n" . instructions . "------------------------------`n")
console_log("processing:`n")
console_log("adding setup_template...`n")
uniquename := A_TickCount
while (FileExist("build\" . uniquename . "`.ahk")){
	uniquename .= 0
}
template_file := "build\" . uniquename . "`.ahk"
FileCopy, setup_template.ahk, % template_file
console_log("instructions to file...`n")
FileAppend, % instructions, instructions
console_log("license to file...`n")
FileAppend, % license_content, license.txt
/*

console_log("processing: '" . source . "'...`n")
FileDelete, instructions
FileAppend, % "GuiControl,, label14, `% 0`n", instructions
FileAppend, % "GuiControl,, label15, `% A_Index . " . qm . "```%" . qm . "`n", instructions
FileAppend, % "Gui, Submit, NoHide`n", instructions
FileAppend, % "log(label11 . " . qm . "\" . source . qm . ")`n`n", instructions

*/


console_log("`nbuild completed")

Exit:
console_log("`n---`nbuild.exe is terminated`n")
ExitApp


console_log(text){
	FileAppend, % text, CONOUT$
	FileAppend, % text, log.txt
}