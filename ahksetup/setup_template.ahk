﻿RunAsAdmin()

#Include ../lang_packages/DE.lp
CONST_SETUP_TITLE := "Example Program 1.7"
CONST_SETUP_STD_FOLDER := "ExampleProgram"

;===INITIALIZATION END===
;lines above are inserted by builder
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

MAIN_INSTALLATION_FINISHED := 0
MAIN_SITE := 0

FileInstall, ../setupicon.jpg, %A_Temp%/setupicon.jpg, 1
FileInstall, ../license.txt, %A_Temp%/license.txt, 1
FileRead, CONST_LICENSE_TEXT, %A_Temp%/license.txt

Gui, Color, FFFFFF
Gui, Add, Pic, x6 y6 w47 h47, %A_Temp%/setupicon.jpg
Gui, Font, s14, Arial
Gui, Add, Text, x77 y6, % CONST_SETUP_TITLE . "`n" . LANG_INSTALLATION
Gui, Add, Progress, cD4D0C8 x0 y57 h1 w500 +Border, 100
Gui, Add, Progress, cF0F0F0 x0 y252 h1 w500 +Border, 100
Gui, Font, s10 c888888, Segoe UI
Gui, Add, Text, x5 y282 gAbout, ahksetup 0.3
Gui, Font, s8 c000000, Segoe UI

;text + button initialization
Gui, Add, Button, gBack vbuttonback x251 y265 h22 w75, % "< " . LANG_BACK
Gui, Add, Button, gNext vbuttonnext x326 y265 h22 w75, % LANG_NEXT . " >"
Gui, Add, Button, gGuiClose vbuttoncancel x413 y265 h22 w73, % LANG_CANCEL

Gui, Font, s9 c000000 bold, Segoe UI
Gui, Add, Text, vlabel1 x10 y65, % LANG_WELCOME
Gui, Font, s9 c000000 normal, Segoe UI
Gui, Add, Text, vlabel2 x10 y82 w480, % LANG_WELCOME_TEXT . " " . CONST_SETUP_TITLE . "."
Gui, Add, Text, vlabel3 x10 y120 w480, % LANG_RECOMMENDATION

Gui, Font, s9 c000000 bold, Segoe UI
Gui, Add, Text, vlabel4 x10 y65, % LANG_LICENSE
Gui, Font, s9 c000000 normal, Segoe UI
Gui, Add, Text, vlabel5 x10 y82 w480, % LANG_LICENSE_REVIEW . " " . CONST_SETUP_TITLE . "."
Gui, Add, Edit, vlabel6 x10 y100 w480 h120 ReadOnly, % CONST_LICENSE_TEXT
Gui, Add, Text, vlabel7 x10 y227 w480, % LANG_LICENSE_AGREE

Gui, Font, s9 c000000 bold, Segoe UI
Gui, Add, Text, vlabel8 x10 y65, % LANG_DESTINATION
Gui, Font, s9 c000000 normal, Segoe UI
Gui, Add, Text, vlabel9 x10 y82 w480, % LANG_DESTINATION_TEXT
Gui, Add, GroupBox, vlabel10 x10 y160 w480 h60, % LANG_DESTINATION_GROUPBOX
Gui, Add, Edit, vlabel11 x20 y182 w365 h25 ReadOnly, % A_ProgramFiles . "\" . CONST_SETUP_STD_FOLDER
Gui, Add, Button, gChooseFolder vlabel12 x390 y182 w90 h25, % LANG_BROWSE

Gui, Font, s9 c000000 bold, Segoe UI
Gui, Add, Text, vlabel13 x10 y65, % LANG_INSTALLING
Gui, Font, s9 c000000 normal, Segoe UI
Gui, Add, Progress, vlabel14 x10 y82 h20 w450 +Border c1111DD, 0
Gui, Add, Text, vlabel15 x465 y83 w35, 0`%
Gui, Add, Edit, vlabel16 x10 y110 w480 h120 ReadOnly, % "-- " . CONST_SETUP_TITLE . " " . LANG_SETUP

Gui, Font, s9 c000000 bold, Segoe UI
Gui, Add, Text, vlabel17 x10 y65, % LANG_COMPLETED
Gui, Font, s9 c000000 normal, Segoe UI
Gui, Add, Text, vlabel18 x10 y82 w480, % CONST_SETUP_TITLE . " " . LANG_COMPLETED_TEXT
Gui, Add, Checkbox, vlabel19 x20 y140 +Checked, % LANG_DESKTOP_SHORTCUT
Gui, Add, Checkbox, vlabel20 x20 y165 +Checked, % LANG_STARTPROG_SHORTCUT
Gui, Add, Checkbox, vlabel21 x20 y190 +Checked, % LANG_RUN . " " . CONST_SETUP_TITLE


gosub, Next
Gui, Show, w500 h300, % CONST_SETUP_TITLE . " " . LANG_SETUP
Return
;FileInstall, Source, Dest [, Flag]

GuiClose:
if(!MAIN_INSTALLATION_FINISHED) {
	MsgBox, 36, % LANG_EXIT_SETUP, % LANG_EXIT_SETUP_TEXT
	IfMsgBox, Yes
		ExitApp
} else {
	ExitApp
}
Return

Back:
MAIN_SITE -= 2
Next:
MAIN_SITE++

;clear all labels
Loop, 21
	GuiControl, Hide, label%A_Index%
GuiControl, Text, buttonnext, % LANG_NEXT . " >"
GuiControl, Text, buttoncancel, % LANG_CANCEL

if(MAIN_SITE = 1){
	Loop, 3
		GuiControl, Show, label%A_Index%
	GuiControl, Hide, buttonback
}
if(MAIN_SITE = 2){
	Loop, 4
		GuiControl, Show, % "label" . A_Index + 3
	GuiControl, Show, buttonback
	GuiControl, Text, buttonnext, % LANG_AGREE
	GuiControl, Text, buttoncancel, % LANG_DECLINE
}
if(MAIN_SITE = 3){
	Loop, 5
		GuiControl, Show, % "label" . A_Index + 7
	GuiControl, Show, buttonback
	GuiControl, Text, buttonnext, % LANG_INSTALL
}
if(MAIN_SITE = 4){
	Loop, 4
		GuiControl, Show, % "label" . A_Index + 12
	GuiControl, Hide, buttonback
	GuiControl, Text, buttonnext, % LANG_NEXT
	GuiControl, +Disabled, buttonnext
	gosub, Install
}
if(MAIN_SITE = 5){
	Loop, 5
		GuiControl, Show, % "label" . A_Index + 16
	GuiControl, Hide, buttonback
	GuiControl, Text, buttonnext, % LANG_FINISH
	GuiControl, -Disabled, buttonnext
	GuiControl, +Disabled, buttoncancel
	MAIN_INSTALLATION_FINISHED := 1
}
if(MAIN_SITE = 6){
	gosub, GuiClose
}
Return

About:
	Run, https://github.com/AndTheFortyThieves/ahksetup/blob/master/README.md
Return

ChooseFolder:
	FileSelectFolder, new_folder,, 1, % LANG_DESTINATION_SELECT
	If (new_folder != "")
		GuiControl, Text, label11, % new_folder
Return

Install:
	Gui, Submit, NoHide
	if !FileExist(label11)
		FileCreateDir, % label11
	#Include ../instructions
	log(LANG_FINISHED . " --")
	GuiControl, -Disabled, buttonnext
	GuiControl, +Disabled, buttoncancel
Return

log(message){
	global
	Gui, Submit, NoHide
	GuiControl, Text, label16, % label16 . "`n" . message
	Return
}

^X::
ExitApp





/*           ,---,                                          ,--,    
           ,--.' |                                        ,--.'|    
           |  |  :                      .--.         ,--, |  | :    
  .--.--.  :  :  :                    .--,`|       ,'_ /| :  : '    
 /  /    ' :  |  |,--.  ,--.--.       |  |.   .--. |  | : |  ' |    
|  :  /`./ |  :  '   | /       \      '--`_ ,'_ /| :  . | '  | |    
|  :  ;_   |  |   /' :.--.  .-. |     ,--,'||  ' | |  . . |  | :    
 \  \    `.'  :  | | | \__\/: . .     |  | '|  | ' |  | | '  : |__  
  `----.   \  |  ' | : ," .--.; |     :  | |:  | : ;  ; | |  | '.'| 
 /  /`--'  /  :  :_:,'/  /  ,.  |   __|  : ''  :  `--'   \;  :    ; 
'--'.     /|  | ,'   ;  :   .'   \.'__/\_: |:  ,      .-./|  ,   /  
  `--'---' `--''     |  ,     .-./|   :    : `--`----'     ---`-'   
                      `--`---'     \   \  /                         
                                    `--`-'  
------------------------------------------------------------------
Function: To check if the user has Administrator rights and elevate it if needed by the script
URL: http://www.autohotkey.com/forum/viewtopic.php?t=50448
------------------------------------------------------------------
*/

RunAsAdmin() {
  Loop, %0%  ; For each parameter:
    {
      param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
      params .= A_Space . param
    }
  ShellExecute := A_IsUnicode ? "shell32\ShellExecute":"shell32\ShellExecuteA"
      
  if not A_IsAdmin
  {
      If A_IsCompiled
         DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params , str, A_WorkingDir, int, 1)
      Else
         DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """" . A_Space . params, str, A_WorkingDir, int, 1)
      ExitApp
  }
}