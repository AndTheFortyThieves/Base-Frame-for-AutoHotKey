#NoEnv

;SYNTAX:
;build [Source] [-li License | -gnu_gpl] [-d Dest] [-lang Language] [-s]

build_source := "Testsuite\Example Program\start.ahk"
build_license := "-gnu_gpl"
build_dest := ""
build_lang := ""
build_single := ""

build_cmd=build "%build_source%" "%build_license%" "%build_dest%" "%build_lang%" "%build_single%"
RunWait, %comspec% /c " %build_cmd% && exit",,hide
FileRead, build_log, log.txt
;MsgBox % build_log
ExitApp