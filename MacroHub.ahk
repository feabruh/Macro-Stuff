; /[V1.0.2TEST]\

#Requires AutoHotkey v2.0

global Version := "1.0.2TEST"
global InfoUI := Gui()
InfoUI.Opt("-SysMenu -Caption +AlwaysOnTop")
InfoUI.SetFont("s15")
InfoText := InfoUI.Add("Text","w600 Center","Checking Folders... | If this gets stuck, Hit F8")
InfoUI.Show()

FoldersToCheck := [
    A_MyDocuments "\PS99_Macros",
    A_MyDocuments "\PS99_Macros\MacroFiles",
    A_MyDocuments "\PS99_Macros\MacroInfo",
    A_MyDocuments "\PS99_Macros\Modules",
    A_MyDocuments "\PS99_Macros\SavedSettings",
    A_MyDocuments "\PS99_Macros\Storage",
    A_MyDocuments "\PS99_Macros\Storage\Fonts",
    A_MyDocuments "\PS99_Macros\Storage\Images"
]

for _, FolderPath in FoldersToCheck {
    if not DirExist(FolderPath) {
        DirCreate(FolderPath)
    }

}

MHLink := "https://raw.githubusercontent.com/feabruh/Macro-Stuff/main/MacroHub.ahk" ; dont have to keep this, but best to keep it (i think)
BaseIni := "https://raw.githubusercontent.com/feabruh/Macro-Stuff/main/BaseIni.ini" ; have to keep this (i think)

InfoText.Text := "Loading Settings... | If this gets stuck, Hit F8"

if not FileExist(A_MyDocuments "\PS99_Macros\MacroInfo\BaseIni.ini") {
    Download(BaseIni, A_MyDocuments "\PS99_Macros\MacroInfo\BaseIni.ini")
}

whr := ComObject("WinHttp.WinHttpRequest.5.1")
whr.Open("GET", BaseIni, true)
whr.Send()
whr.WaitForResponse()
DifferenceinIniVersion := VersionCheck(A_MyDocuments "\PS99_Macros\MacroInfo\BaseIni.ini", whr.ResponseText) ; do i really have to check for the version of the ini file? idk but i will anyways

if DifferenceinIniVersion.R {
    whr := ComObject("WinHttp.WinHttpRequest.5.1")
    whr.Open("GET", BaseIni, true)
    whr.Send()
    whr.WaitForResponse()

    Path := A_MyDocuments "\PS99_Macros\MacroInfo\BaseIni.ini"
    FileDelete(Path)
    FileAppend(whr.ResponseText, Path, "UTF-8-RAW")
}

InfoText.Text := "Checking Macro Hub... | If this gets stuck, Hit F8"   

whr := ComObject("WinHttp.WinHttpRequest.5.1")
whr.Open("GET", MHLink, true)
whr.Send()
whr.WaitForResponse()
DifferenceInMHVersion := VersionCheck(A_ScriptFullPath, whr.ResponseText)

if DifferenceInMHVersion.R {
    InfoUI.Hide()

    Path := A_ScriptFullPath
    FileDelete(Path)
    FileAppend(whr.ResponseText, Path, "UTF-8-RAW")
    Run Path
    ExitApp
}

MacroInfo := A_MyDocuments "\PS99_Macros\MacroInfo\*.ini"

Macros := Map()
Modules := Map()
Fonts := Map()
MacroHub := Map()
MacroOrder := []
ValidCategories := ["Macros", "Modules", "Fonts", "MacroHub"]

try { ; think i can make this a little more efficient
    loop files MacroInfo {
        IniFilePath := A_LoopFileFullPath
        loop read IniFilePath {
            Line := A_LoopReadLine
            if (SubStr(Line, 1, 1) = ";") or (Line = "")
                continue
            if (InStr(Line, "{") and InStr(Line, "}")) {
                SectionName := StrReplace(StrReplace(Line, "{"), "}")
                Category := DetermineCategory(SectionName)
            }
            if (InStr(Line, "[") and InStr(Line, "]")) {
                SubSectionName := StrReplace(StrReplace(Line, "["), "]")
                if (Category = "MACROS") {
                    MacroOrder.Push(SubSectionName)
                    Macros[SubSectionName] := Map()
                    FillProperties(Macros[SubSectionName], IniFilePath, SubSectionName, Category)
                } else if (Category = "Fonts") {
                    Fonts[SubSectionName] := Map()
                    FillProperties(Fonts[SubSectionName], IniFilePath, SubSectionName, Category)
                } else if (Category = "Modules") {
                    Modules[SubSectionName] := Map()
                    FillProperties(Modules[SubSectionName], IniFilePath, SubSectionName, Category)
                } else if (Category = "MacroHub") {
                    MacroHub[SubSectionName] := Map()
                    FillProperties(MacroHub[SubSectionName], IniFilePath, SubSectionName, Category)
                }
            }
        }
    }
} catch as e {
    MsgBox("Error reading file.`n(" e.Message ")",, "4096")
}

DetermineCategory(SectionName) {
    for index, Category in ValidCategories {
        if (InStr(SectionName, Category)) {
            return Category
        }
    }
    return "UNKNOWN"
}
    
FillProperties(SectionMap, IniFilePath, SubSectionName, Category) { ; this could prob be way more efficient but wtv
    if (Category = "Macros") {
        SectionMap.Status := IniRead(IniFilePath, SubSectionName, "Status", "")
        SectionMap.StatusColor := IniRead(IniFilePath, SubSectionName, "StatusColor", "")
        SectionMap.RawLink := IniRead(IniFilePath, SubSectionName, "RawLink", "")
        SectionMap.APILink := IniRead(IniFilePath, SubSectionName, "APILink", "")
        SectionMap.FileName := IniRead(IniFilePath, SubSectionName, "FileName", "false")
        ExistantStr := IniRead(IniFilePath, SubSectionName, "Existant", "false")
        SectionMap.Existant := (ExistantStr = "true") 
    } else if (Category = "MacroHub"){
        SectionMap.RawLink := IniRead(IniFilePath, SubSectionName, "RawLink", "")
    } else if (Category = "Fonts") {
        SectionMap.FileName := IniRead(IniFilePath, SubSectionName, "FileName", "")
        SectionMap.RawLink := IniRead(IniFilePath, SubSectionName, "RawLink", "")
        Fonts[SectionMap.FileName] := SectionMap.RawLink
        DownloadFonts(SectionMap.FileName, SectionMap.RawLink)
    } else if (Category = "Modules") {
        SectionMap.FileName := IniRead(IniFilePath, SubSectionName, "FileName", "")
        SectionMap.RawLink := IniRead(IniFilePath, SubSectionName, "RawLink", "")
        Modules[SectionMap.FileName] := SectionMap.RawLink
        DownloadModules(SectionMap.FileName, SectionMap.RawLink)
    } else { ; other categories that arent defined yet
        MsgBox("hi")
    }
}

Xs := [40, 270, 500]
Ys := [60, 220, 440]

DownloadFonts(Font, FontLink) {
    InfoText.Text := "Checking " Font "... | If this gets stuck, Hit F8"
    Download(FontLink, A_MyDocuments "\PS99_Macros\Storage\Fonts\" Font)
}

DownloadModules(ModuleName, ModuleLink) {
    InfoText.Text := "Checking " ModuleName "... | If this gets stuck, Hit F8"
    whr := ComObject("WinHttp.WinHttpRequest.5.1")
    whr.Open("GET", ModuleLink, true)
    whr.Send()
    whr.WaitForResponse()

    if FileExist(A_MyDocuments "\PS99_Macros\Modules\" ModuleName) {
        FileDelete(A_MyDocuments "\PS99_Macros\Modules\" ModuleName)
    }

    FileAppend(whr.ResponseText, A_MyDocuments "\PS99_Macros\Modules\" ModuleName, "UTF-8-RAW")
}

InfoText.Text := "Checking Macros... | If this gets stuck, Hit F8"

GoodTimeDiff(IsoTime) {
    Reformatted := ""

    Split1 := StrSplit(IsoTime, "T")
    Split2 := StrSplit(Split1[1], "-")
    Reformatted := Split2[1] Split2[2] Split2[3]

    Split3 := StrSplit(Split1[2], "Z")
    Split4 := StrSplit(Split3[1], ":")
    Reformatted := Reformatted Split4[1] Split4[2] Split4[3]

    if DateDiff(A_NowUTC, Reformatted, "Days") > 0 {
        return {Time:DateDiff(A_NowUTC, Reformatted, "Days"), Word:"Day(s)"}
    } else if DateDiff(A_NowUTC, Reformatted, "Hours") > 0 {
        return {Time:DateDiff(A_NowUTC, Reformatted, "Hours"), Word:"Hour(s)"}
    } else if DateDiff(A_NowUTC, Reformatted, "Minutes") > 0 {
        return {Time:DateDiff(A_NowUTC, Reformatted, "Minutes"), Word:"Minute(s)"}
    }

    return {Time:"A Couple", Word:"seconds"}
}

VersionCheck(FileMain, ResponseText) {
    FileText := FileRead(FileMain)
    MainFileVersionTag := StrSplit(StrSplit(FileText, "]\")[1], "/[")[2]
    SecondaryFileVersionTag := StrSplit(StrSplit(ResponseText, "]\")[1], "/[")[2]

    if MainFileVersionTag = SecondaryFileVersionTag {
        return {R:false, Main:MainFileVersionTag, Secondary:SecondaryFileVersionTag}
    } else {
        return {R:true, Main:MainFileVersionTag, Secondary:SecondaryFileVersionTag}

    }
}

MacrosLoaded := 0
MacrosOnLine := 0
MacrosOnColoumn := 1

MacroHubUI := Gui(,"Macro Hub | Version: " Version)
MacroHubUI.Opt("+AlwaysOnTop")
MHTabs := MacroHubUI.AddTab3("", ["Main"])
MacroHubUI.AddText("Section w700 h30 Center", "Macro Hub | V" Version).SetFont("s15 w700")


MHTabs.UseTab(1)
CreateMacroBox(MacroObject) {
    MacroHubUI.AddGroupBox("x" Xs[MacrosOnLine] " y" Ys[MacrosOnColoumn] " w200 h180 Section","").SetFont("s11")
    MacroHubUI.AddText("xs+5 ys+15 h30 w190 Center", MacroName).SetFont("s12 w600")
    MacroHubUI.AddText("xs+5 ys+40 h30 w190 Center", "Status").SetFont("s11 w600 underline")
    MacroHubUI.AddText("xs+5 ys+60 h30 w190 Center", MacroObject.Status).SetFont("s11 c" MacroObject.StatusColor)
    MacroHubUI.AddText("xs+5 ys+90 h30 w190 Center", "Last Updated").SetFont("s11 w600 underline")
    MacroHubUI.AddText("xs+5 ys+110 h30 w190 Center", LastUpdateTimeObj.Time " " LastUpdateTimeObj.Word " Ago").SetFont("s11")

    if MacroObject.Existant {
        RunMacroButton := MacroHubUI.AddButton("xs+5 ys+140 h30 w190 Center", "Run Macro")
        RunMacroButton.SetFont("s11")
        RunMacroButton.OnEvent("Click", RunButtonFunction)
    }

    RunButtonFunction(*) {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", MacroObject.RawLink, true)
        whr.Send()
        whr.WaitForResponse()

        if FileExist(A_MyDocuments "\PS99_Macros\MacroFiles\" MacroObject.FileName) {
            IsDifferenceInVersion := VersionCheck(A_MyDocuments "\PS99_Macros\MacroFiles\" MacroObject.FileName, whr.ResponseText)

            if IsDifferenceInVersion.R {
                Result := MsgBox(
                    "There is a difference inbetween macro versions.`nYour Version: " IsDifferenceInVersion.Main "`nGitHub Version: " IsDifferenceInVersion.Secondary "`nWould you like to update your version?",
                    "Macro Update", 
                    "0x1032 0x4"
                )
                if Result = "Yes" {
                    FileDelete(A_MyDocuments "\PS99_Macros\MacroFiles\" MacroObject.FileName)
                    FileAppend(whr.ResponseText, A_MyDocuments "\PS99_Macros\MacroFiles\" MacroObject.FileName, "UTF-8-RAW" )
                    
                    Result2 := MsgBox("Macro has been updated, would you like to run it?", "Macro Update", "0x1040 0x4")
                    if Result2 = "Yes" {
                        Run(A_MyDocuments "\PS99_Macros\MacroFiles\" MacroObject.FileName)
                        ExitApp()
                    }

                } else if Result = "No" {
                    Run(A_MyDocuments "\PS99_Macros\MacroFiles\" MacroObject.FileName)
                    ExitApp()
                }
            } else {
                Run(A_MyDocuments "\PS99_Macros\MacroFiles\" MacroObject.FileName)
                ExitApp()
            }
        } else {
            Result := MsgBox("It seems you currently don't have this macro installed, would you like to install it?", "Macro Installation", "0x1032 0x4")

            if Result = "Yes" {
                FileAppend(whr.ResponseText, A_MyDocuments "\PS99_Macros\MacroFiles\" MacroObject.FileName, "UTF-8-RAW")

                Result2 := MsgBox("Macro has been installed, would you like to run it?", "Macro Installation", "0x1040 0x4")
                if Result2 = "Yes" {
                    Run(A_MyDocuments "\PS99_Macros\MacroFiles\" MacroObject.FileName)
                    ExitApp()
                }
            }
        }
    }
}

for _, MacroName in MacroOrder {
    MacroObject := Macros[MacroName]

    MacrosLoaded += 1
    MacrosOnLine += 1
    
    if MacrosOnLine > 3 {
        MacrosOnLine := 1
        MacrosOnColoumn += 1
    }

    whr := ComObject("WinHttp.WinHttpRequest.5.1")
    whr.Open("GET", MacroObject.APILink, true)
    whr.Send()
    whr.WaitForResponse()
    APIString := whr.ResponseText

    LastUpdateTimeObj := GoodTimeDiff(Jxon_Load(&APIString)[1]["commit"]["author"]["date"])

    CreateMacroBox(MacroObject)
}

InfoUI.Hide()
MacroHubUI.Show()
MacroHubUI.OnEvent("Close", (*) => ExitApp())

;- cuz i cant do a stupid include im going to blow up and die
Jxon_Load(&src, args*) {
	key := "", is_key := false
	stack := [ tree := [] ]
	next := '"{[01234567890-tfn'
	pos := 0
	
	while ( (ch := SubStr(src, ++pos, 1)) != "" ) {
		if InStr(" `t`n`r", ch)
			continue
		if !InStr(next, ch, true) {
			testArr := StrSplit(SubStr(src, 1, pos), "`n")
			
			ln := testArr.Length
			col := pos - InStr(src, "`n",, -(StrLen(src)-pos+1))

			msg := Format("{}: line {} col {} (char {})"
			,   (next == "")      ? ["Extra data", ch := SubStr(src, pos)][1]
			  : (next == "'")     ? "Unterminated string starting at"
			  : (next == "\")     ? "Invalid \escape"
			  : (next == ":")     ? "Expecting ':' delimiter"
			  : (next == '"')     ? "Expecting object key enclosed in double quotes"
			  : (next == '"}')    ? "Expecting object key enclosed in double quotes or object closing '}'"
			  : (next == ",}")    ? "Expecting ',' delimiter or object closing '}'"
			  : (next == ",]")    ? "Expecting ',' delimiter or array closing ']'"
			  : [ "Expecting JSON value(string, number, [true, false, null], object or array)"
			    , ch := SubStr(src, pos, (SubStr(src, pos)~="[\]\},\s]|$")-1) ][1]
			, ln, col, pos)

			throw Error(msg, -1, ch)
		}
		obj := stack[1]
        is_array := (obj is Array)
		
		if i := InStr("{[", ch) { ; start new object / map?
			val := (i = 1) ? Map() : Array()	; ahk v2
			
			is_array ? obj.Push(val) : obj[key] := val
			stack.InsertAt(1,val)
			
			next := '"' ((is_key := (ch == "{")) ? "}" : "{[]0123456789-tfn")
		} else if InStr("}]", ch) {
			stack.RemoveAt(1)
            next := (stack[1]==tree) ? "" : (stack[1] is Array) ? ",]" : ",}"
		} else if InStr(",:", ch) {
			is_key := (!is_array && ch == ",")
			next := is_key ? '"' : '"{[0123456789-tfn'
		} else { ; string | number | true | false | null
			if (ch == '"') { ; string
				i := pos
				while i := InStr(src, '"',, i+1) {
					val := StrReplace(SubStr(src, pos+1, i-pos-1), "\\", "\u005C")
					if (SubStr(val, -1) != "\")
						break
				}
				if !i ? (pos--, next := "'") : 0
					continue

				pos := i ; update pos

				val := StrReplace(val, "\/", "/")
				val := StrReplace(val, '\"', '"')
				, val := StrReplace(val, "\b", "`b")
				, val := StrReplace(val, "\f", "`f")
				, val := StrReplace(val, "\n", "`n")
				, val := StrReplace(val, "\r", "`r")
				, val := StrReplace(val, "\t", "`t")

				i := 0
				while i := InStr(val, "\",, i+1) {
					if (SubStr(val, i+1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
						continue 2

					xxxx := Abs("0x" . SubStr(val, i+2, 4)) ; \uXXXX - JSON unicode escape sequence
					if (xxxx < 0x100)
						val := SubStr(val, 1, i-1) . Chr(xxxx) . SubStr(val, i+6)
				}
				
				if is_key {
					key := val, next := ":"
					continue
				}
			} else { ; number | true | false | null
				val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$",, pos)-pos)
				
                if IsInteger(val)
                    val += 0
                else if IsFloat(val)
                    val += 0
                else if (val == "true" || val == "false")
                    val := (val == "true")
                else if (val == "null")
                    val := ""
                else if is_key {
                    pos--, next := "#"
                    continue
                }
				
				pos += i-1
			}
			
			is_array ? obj.Push(val) : obj[key] := val
			next := obj == tree ? "" : is_array ? ",]" : ",}"
		}
	}
	
	return tree[1]
}

F8::ExitApp()
