#Requires AutoHotkey v2.0 
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"
SendMode "Event"

; i just copy and pasted this gui from basement so thank him for this

;gui part
TypeToFunction := Map(
    "Toggle", Create_TNTP_UI,
    "Number", Create_TNTP_UI,
    "Text", Create_TNTP_UI,
    "Position", Create_TNTP_UI,
    "Selection", CreateSelectionUI,
    "Object", CreateObjectUI
)

global CurrentPostionLabel := ""
global FredokaOneFont := "%A_MyDocuments%\PetCatchers_Macros\Storage\Fonts\F_One.ttf"
global TimesNewRomanFont := "%A_MyDocuments%\PetCatchers_Macros\Storage\Fonts\T_NR.ttf"
global CB := ""

global VariablisticMap := Map()

;-- Expects Map("Main", {Title:X, Video:X, Description:X, Version:X, DescY:X, MacroName:X, IncludeFonts:True}, "Settings", [{Map:X,Name:X,Type:X,SaveName:X}], "SettingsFolder:X")
CreateBaseUI(MapIndex) {
    DBevent(*) {
        Run "https://discord.com/invite/JrwB6jVxkR"
    }
    YTBevent(*) {
        Run MapIndex["Main"].Video
    }

    EMBevent(*) {
        BaseGui.Hide()
        EnableMacro()
    }


    UIObject := {}
    BaseGui := Gui(,MapIndex["Main"].MacroName " | V" MapIndex["Main"].Version)
    if MapIndex["Main"].noCaptions {
        BaseGui.Opt("-Caption +AlwaysOnTop")
    } else {
        BaseGui.Opt("+AlwaysOnTop")
    }

    UITabs := BaseGui.AddTab3("", ["Main", "Settings", "Extras"])
    BaseGui.AddText("Section w240 h20 x20 y35", MapIndex["Main"].Title).SetFont("s15 w700")
    BaseGui.AddText("w240 h20 x20 yp+20", "Version: " MapIndex["Main"].Version).SetFont("s12 w500")
    BaseGui.AddLink("w250 h20 x20 yp+20", 'I copied the gui from <a href="https://www.youtube.com/channel/UCKOkQGvHO71nqQjwTiJX5Ww">A Basement</a> / <a href="https://www.roblox.com/users/128699642/profile">Oliyopi</a>').SetFont("s10 w500")
    BaseGui.AddText("w200 h" MapIndex["Main"].DescY " x20 yp+40 Wrap", MapIndex["Main"].Description).SetFont("s10 w500")

    EMB := BaseGui.AddButton("w100 h30 xs y350", "Enable Macro")
    ;YTB := BaseGui.AddButton("w70 h30 xp+100 y350", "YT Video")
    ;DB := BaseGui.AddButton("w75 h30 xp+70 y350", "Discord")
  
    EMB.SetFont("s10")
    ;YTB.SetFont("s10")
    ;DB.SetFont("s10")

    EMB.OnEvent("Click", EMBevent)
    ;DB.OnEvent("Click", DBevent)
    ;YTB.OnEvent("Click", YTBevent)

    UITabs.UseTab(2)
    SettingButtonSpacing := 0
    BaseGui.GetClientPos(&u, &u, &UIWidth, &UIHeight)

    BaseGui.Show()
    BaseGui.Hide()

    for _, SettingObject in MapIndex["Settings"] {
        SettingButtonSpacing += 35
        
        NewButton := BaseGui.AddButton("w160 h30 x" (UIWidth/2 + 75 - BaseGui.MarginX) " y" SettingButtonSpacing, SettingObject.Name)

        if SettingObject.type = "Selection" {
            NewUIObject := TypeToFunction[SettingObject.type](SettingObject, BaseGui, {Button:NewButton})
            NewButton.SetFont("s10")

            SettingObject.UIObject := NewUIObject
        } else {
            NewUIObject := TypeToFunction[SettingObject.type](SettingObject, BaseGui)
            NewButton.SetFont("s10")
            NewButton.OnEvent("Click", NewUIObject.ShowFunction)
        }
    }

    UITabs.UseTab(3)
    if MapIndex["Main"].IncludeFonts {
        BaseGui.Add("Button","x15 y30 h30 w200","Set Font To Times New Roman").OnEvent("Click", SetToTimesNewRoman)
        BaseGui.Add("Button","x15 y60 h30 w200","Reset Font to Default").OnEvent("Click", SetToFredokaOne)
        
        SetToTimesNewRoman(*) {
            try {
                StringCoolness := WinGetProcessPath("ahk_exe RobloxPlayerBeta.exe")
                FontPath := SubStr(StringCoolness, 1, (StrLen(StringCoolness) - StrLen("RobloxPlayerBeta.exe"))) "content\fonts"

                FileCopy(TimesNewRomanFont, FontPath "\FredokaOne-Regular.ttf", true)
            } catch as e {
                MsgBox("Roblox aint open you fuhalatoogin`n(" e.Message ")",,"4096")
            }
        }
        
        SetToFredokaOne(*) {  
            try {
                StringCoolness := WinGetProcessPath("ahk_exe RobloxPlayerBeta.exe")
                FontPath := SubStr(StringCoolness, 1, (StrLen(StringCoolness) - StrLen("RobloxPlayerBeta.exe"))) "content\fonts"

                FileCopy(FredokaOneFont, FontPath "\FredokaOne-Regular.ttf", true)
            } catch as e {
                MsgBox("Roblox aint open you fuhalatoogin`n(" e.Message ")",,"4096")
            }
        }
    }

    SettingsMap := Map()
    SettingsArray := []
    Path := MapIndex["SettingsFolder"].Folder "\" MapIndex["SettingsFolder"].FolderName

    if not DirExist(Path) {
        DirCreate(Path)
        DirCreate(Path "\MacroSettings")
        if not FileExist(Path "\BaseSettings.ini") {
            IniWrite("nil", Path "\BaseSettings.ini", "LLS", "LastLoaded")
        }
    }

    LLS := IniRead(Path "\BaseSettings.ini", "LLS", "LastLoaded")
    SettingNum := 0

    loop files, Path "\MacroSettings\*.ini" {
        SettingsArray.InsertAt(SettingsArray.Length + 1, A_LoopFileName)
        SettingsMap[A_LoopFileName] := SettingsArray.Length

        if LLS != "nil" {
            if LLS = A_LoopFileName {
                SettingNum := SettingsArray.Length
            }
        }
    }
    OutputDebug(LLS)
    
    if SettingNum > 0 {
        LoadSetting(Path "\MacroSettings\" SettingsArray[SettingNum])
    }

    BaseGui.SetFont("s11")
    BaseGui.Add("Button","x15 y270","Save Settings").OnEvent("Click", ButtonSaveSettings)
    BaseGui.Add("Button","x15 y305","Save Settings As New File").OnEvent("Click", SaveNewSettingsShow)
    BaseGui.Add("Text", "x15 y335", "↓ Load Setting File ↓")
    SettingDD := BaseGui.Add("DropDownList", "w200 x15 y355 vLoadSetting choose" SettingNum, SettingsArray)
    SettingDD.OnEvent("Change", SettingChanged)

    SaveSettingAsNewGUI := Gui()
    SaveSettingAsNewGUI.SetFont("s11 q5 w500", "Arial")
    SaveSettingAsNewGUI.Add("Text", "", "Enter File Name`n(Duplicate Named Files Will Overwrite)`n(No Need to add .ini)")
    SaveSettingAsNewGUI.Opt("+AlwaysOnTop")
    SSWText := SaveSettingAsNewGUI.Add("Edit", "vName w200", "NewSettingFile" SettingsArray.Length + 1)
    SaveSettingAsNewGUI.Add("Button", "", "Save").OnEvent("Click", ButtonSaveNewSettings)

    SaveNewSettingsShow(*) {
        SaveSettingAsNewGUI.Show()
    }

    ButtonSaveSettings(*) {
        if SettingNum = 0 {
            SaveSettings(true)
        } else {
            SaveSettings(false)
        }
    }

    ButtonSaveNewSettings(*) {
        SaveSettings(true)
    }

    SaveSettings(NewFile) {
        FileName := SaveSettingAsNewGUI.submit().Name
        FileToSaveTo := ""
        

        if NewFile {
            IniWrite(FileName ".ini", Path "\BaseSettings.ini", "LLS", "LastLoaded")
            FileToSaveTo := Path "\MacroSettings\" FileName ".ini"
        } else {
            FileToSaveTo := Path "\MacroSettings\" LLS
            OutputDebug(LLS)
        }

        for _, SettingObject in MapIndex["Settings"] {
            switch SettingObject.Type {
                case "Position":
                    for Key, Value in SettingObject.Map {
                        IniWrite(Value[1] "|" Value[2], FileToSaveTo, SettingObject.SaveName, Key)
                    }
                case "Selection":
                    FormattedText := ""

                    for Selection, Status in SettingObject.Map {
                        if FormattedText = "" {
                            FormattedText := Selection ":" Status
                        } else {
                            FormattedText := FormattedText "|" Selection ":" Status
                        }
                    }

                    IniWrite(FormattedText, FileToSaveTo, SettingObject.SaveName, "FormatString")
                case "Object":
                    for Name, Objective in SettingObject.Map {
                        for I, V in Objective.OwnProps() {
                            if SettingObject.ObjectIgnore.Has(I) {
                                continue
                            }

                            switch Type(V) {
                                case "Array":
                                    IniWrite(V[1] "|" V[2], FileToSaveTo, SettingObject.SaveName, Name I)
                                default:
                                    IniWrite(V, FileToSaveTo, SettingObject.SaveName, Name I)
                            }
                        }
                    }
                default:
                    for Key, Value in SettingObject.Map {
                        IniWrite(Value, FileToSaveTo, SettingObject.SaveName, Key)
                    }
            }
        }

        if NewFile {
            SettingsMap := Map()
            SettingsArray := []

            LLS := FileName ".ini"
            SettingNum := 0
        
            loop files, Path "\MacroSettings\*.ini" {
                SettingsArray.InsertAt(SettingsArray.Length + 1, A_LoopFileName)
                SettingsMap[A_LoopFileName] := SettingsArray.Length
        
                if LLS != "nil" {
                    if LLS = A_LoopFileName {
                        SettingNum := SettingsArray.Length
                    }
                }
            }

            SettingDD.Delete()
            SettingDD.add(SettingsArray)
            SettingDD.choose(SettingNum)
            SSWText.Text := "NewSettingFile" SettingsArray.Length + 1
        }
    }

    SettingChanged(*) {
        falseifiedUISumbit := BaseGui.submit(false)
        SettingNum := SettingsMap[falseifiedUISumbit.LoadSetting]

        OutputDebug(SettingNum)

        LoadFile := Path "\MacroSettings\" falseifiedUISumbit.LoadSetting
        IniWrite(falseifiedUISumbit.LoadSetting, Path "\BaseSettings.ini", "LLS", "LastLoaded")
        LLS := falseifiedUISumbit.LoadSetting
        LoadSetting(LoadFile)
    }

    LoadSetting(LoadFile) {
        for _, SettingObject in MapIndex["Settings"] {
            switch SettingObject.Type {
                case "Selection":
                    SettingObject.Map.Clear()
                    FormattedText := IniRead(LoadFile, SettingObject.SaveName, "FormatString")

                    for _, SelectionToStatus in StrSplit(FormattedText, "|") {
                        SecondSplit := StrSplit(SelectionToStatus, ":")

                        SettingObject.Map[SecondSplit[1]] := SecondSplit[2]
                    }

                    SettingObject.UIObject.RefreshFunc()
                default:
                    for Key, Value in SettingObject.Map {
                        switch SettingObject.type {
                            case "Position":
                                SettingObject.Map[Key] := StrSplit(IniRead(LoadFile, SettingObject.SaveName, Key), "|")
                                VariablisticMap[SettingObject.SaveName][Key][1].Value := SettingObject.Map[Key][1]
                                VariablisticMap[SettingObject.SaveName][Key][2].Value := SettingObject.Map[Key][2]
                            case "Object":
                                for I, V in Value.OwnProps() {
                                    if SettingObject.ObjectIgnore.Has(I) {
                                        continue
                                    }

                                    switch Type(V) {
                                        case "Array":
                                            SettingObject.Map[Key].%I% := StrSplit(IniRead(LoadFile, SettingObject.SaveName, Key I), "|")
                                            VariablisticMap[SettingObject.SaveName][Key I][1].Value := SettingObject.Map[Key].%I%[1]
                                            VariablisticMap[SettingObject.SaveName][Key I][2].Value := SettingObject.Map[Key].%I%[2]
                                        default:
                                            SettingObject.Map[Key].%I% := IniRead(LoadFile, SettingObject.SaveName, Key I)
                                            VariablisticMap[SettingObject.SaveName][Key I].Value := SettingObject.Map[Key].%I%
                                    }
                                }
                            default:
                                try {
                                    SettingObject.Map[Key] := IniRead(LoadFile, SettingObject.SaveName, Key)
                                    VariablisticMap[SettingObject.SaveName][Key].Value := SettingObject.Map[Key]
                                } catch as e {
                                    MsgBox('Error Loading Setting File`nTo fix this, click the "OK" button here `nthen click the "Save Settings As New File" button in the extras tab`n`n(' e.Message ')',,'4096')
                                } ; i could make it so i dont have to catch this but im too lazy rn
                        }
                    }
            }
        }
    }

    UIObject.BaseUI := BaseGui
    UIObject.EnableButton := EMB
    return UIObject
}

CreatePosHelper(UI, Name, PosArray, Num, I := "", Objective := false) {
    PushButton := 0
    if Objective {
        PushButton += 48
        UI.Add("Text","Section xs y" Num, Name ":")
    } else {
        UI.Add("Text","Section xs y" (Num * 25 + (40)), Name ":")
    }

    
    UI.Add("Button", "w25 h25 x" (220 - PushButton) " ys", "S").OnEvent("Click", ButtonClicked)
    Ud1 := ""
    ud2 := ""

    if Objective {
        Ud1 := UI.Add("Edit","ys w60 x" (250-PushButton),)
        UI.AddUpDown("v" Name I "XPos Range1-40000", PosArray[1])
        ud2 := UI.Add("Edit","ys w60 x" (320-PushButton),)
        UI.AddUpDown("v" Name I "YPos Range1-40000", PosArray[2])
    } else {
        Ud1 := UI.Add("Edit","ys w60 x250",)
        UI.AddUpDown("v" Name "XPos Range1-40000", PosArray[1])
        ud2 := UI.Add("Edit","ys w60 x320",)
        UI.AddUpDown("v" Name "YPos Range1-40000", PosArray[2])
    }
  
    ButtonClicked(*) {
        global CurrentPostionLabel := [UD1, UD2]
    }

    return [UD1, UD2]
}


;-- Create Toggle/Number/Text/Positioning UI
Create_TNTP_UI(_MapOBJ, BaseUI) {
    global CB
    _Map := _MapOBJ.Map
    SettingsUI := Gui()
    
    TotalSettings := 0
    NumericalSetting := 0
    CurrentTab := 0
    TabsArray := []

    loop (Ceil(_Map.Count / 15)) {
        TabsArray.InsertAt(TabsArray.Length + 1, "Settings[" A_Index "]")
    }

    TSTabs := SettingsUI.AddTab3("", TabsArray)
    if not _MapOBJ.Type = "Position" {
        SettingsUI.AddText("w200 h20 Section", _MapOBJ.Type " Settings").SetFont("s12 w700")
    } else {
        SettingsUI.SetFont("s15 q5 w800", "Constantia")
        SettingsUI.Add("Text", "Section", "Positioning")
        SettingsUI.Add("Text"," ys+5 x270 c0x000000","X")
        SettingsUI.Add("Text"," ys+5 x340 c0x000000","Y")
        SettingsUI.SetFont("s9 q5 w500", "Arial")
    }

    if not VariablisticMap.Has(_MapOBJ.SaveName) {
        VariablisticMap[_MapOBJ.SaveName] := Map()
    }


    for Setting, SettingValue in _Map {
        TotalSettings += 1
        NumericalSetting += 1
        CurrentTab := Ceil(TotalSettings / 15)
        TSTabs.UseTab(CurrentTab)

        if NumericalSetting >= 16 {
            NumericalSetting := 1

            ;- WE LOVE COPY AND PASTING CODE
            if not _MapOBJ.Type = "Position" {
                SettingsUI.AddText("w200 h20 Section", _MapOBJ.Type " Settings").SetFont("s12 w700")
            } else {
                SettingsUI.SetFont("s15 q5 w800", "Constantia")
                SettingsUI.Add("Text", "Section", "Positioning")
                SettingsUI.Add("Text"," ys+5 x270 c0x000000","X")
                SettingsUI.Add("Text"," ys+5 x340 c0x000000","Y")
                SettingsUI.SetFont("s9 q5 w500", "Arial")
            }
        }

        switch _MapOBJ.Type {
            case "Toggle":
                SettingsUI.AddText("w150 h20 xs y" (NumericalSetting * 25 + (40)), Setting ":").SetFont("s10")
                VariablisticMap[_MapOBJ.SaveName][Setting] := SettingsUI.AddCheckbox("w20 h20 v" Setting " yp xp+190 Checked" SettingValue)
                VariablisticMap[_MapOBJ.SaveName][Setting].SetFont("s9")
            case "Number":
                SettingsUI.AddText("w150 h20 xs y" (NumericalSetting * 25 + (40)), Setting ":").SetFont("s10")
                VariablisticMap[_MapOBJ.SaveName][Setting] := SettingsUI.AddEdit("w120 h20 yp xp+190")
                SettingsUI.AddUpDown("v" Setting " range1-10000000" Setting, SettingValue)
            case "Text":
                SettingsUI.AddText("w150 h20 xs y" (NumericalSetting * 25 + (40)), Setting ":").SetFont("s10")
                VariablisticMap[_MapOBJ.SaveName][Setting] := SettingsUI.AddEdit("w120 h20 yp xp+190 v" Setting, SettingValue)
            case "Position":
                VariablisticMap[_MapOBJ.SaveName][Setting] := CreatePosHelper(SettingsUI, Setting, SettingValue, NumericalSetting)
        }
    }

    SubmitFunction(*) {
        SettingsUI.Hide()
        ReturnedValues := ObjToMap(SettingsUI.Submit())

        switch _MapOBJ.Type {
            case "Position":
                for Key, Value in _Map {
                    _Map[Key] := [ReturnedValues[Key "XPos"], ReturnedValues[Key "YPos"]]
                }
            default:
                for Key, Value in ReturnedValues {
                    _Map[Key] := Value
                }
        }
    }

    ShowFunction(*) {
        BaseUI.GetPos(&u, &u2, &u3, &u4)
        SettingsUI.GetPos(&a, &a2, &a3, &a4)
        SettingsUI.Show("X" (u - a3) " Y" u2 "")
        
        SettingsUI.GetPos(&a, &a2, &a3, &a4)
        SettingsUI.Show("X" (u - a3) " Y" u2 "")
    }

    TSTabs.UseTab(1)
    FinalizeButton := ""

    if TotalSettings >= 15 {
        FinalizeButton := SettingsUI.AddButton("w95 h30 xs y" (15 * 25 + (70)), "Set Values")
    } else {
        FinalizeButton := SettingsUI.AddButton("w95 h30 xs y" (TotalSettings * 25 + (70)), "Set Values")
    }
    
    FinalizeButton.OnEvent("Click", SubmitFunction)
    FinalizeButton.SetFont("s10")

    return {UI:SettingsUI,ShowFunction:ShowFunction}
}

;-- Used In SelectionUI_CreateUIS
SelectionUI_CreateUIS(MapToEvilize, TypeOfButton, Name) {
    AdditiveUI := Gui()
    DestructiveUI := Gui()

    DestroyArray := []
    for Key,_ in MapToEvilize {
        DestroyArray.InsertAt(DestroyArray.Length + 1, Key)
    }

    AdditiveUI.Opt("+AlwaysOnTop")
    DestructiveUI.Opt("+AlwaysOnTop")

    AdditiveUI.AddText("w300 h20 Section", "Add To Selection | " Name).SetFont("s12 w700")
    DestructiveUI.AddText("w300 h20 Section", "Remove From Selection | " Name).SetFont("s12 w700")

    AdditiveUI.AddEdit("w150 h20 vNewInstance", "New Selection Here").SetFont("s10")
    if TypeOfButton = "toggle" {
        AdditiveUI.AddDropDownList("w80 h20 vBaseValue Choose1 r2 yp xp+160", ["true", "false"]).SetFont("s9")
    }

    DestructiveUI.AddDropDownList("w150 h20 vDestroyValue Choose1 r6", DestroyArray).SetFont("s9")
    DestroyButton := DestructiveUI.AddButton("w120 h30 xs", "Destroy Selection")
    DestroyButton.SetFont("s10")
    AddButton := AdditiveUI.AddButton("w120 h30 xs", "Add Selection")
    AddButton.SetFont("s10")

    return {
        Additive:{
            AddButton:AddButton,
            PhysicalUI:AdditiveUI
        },
        Destructive:{
            DestroyButton:DestroyButton,
            PhsyicalUI:DestructiveUI
        }
    }
}

;-- Create Selection Type UI
;-- Mainly used for allowing users to add / remove values from Maps
CreateSelectionUI(_MapOBJ, BaseUI, PreviousObject := {}, ShowUI := true) {
    TrueObject := PreviousObject

    _Map := _MapOBJ.Map
    SelectionUI := Gui()
    SelectionUI.AddText("w200 h20 Section", _MapOBJ.Name " Selection").SetFont("s12 w700")
    SpacelessTable := Map()

    for Setting, SettingValue in _Map {
        NewerString := ""
        for _,Text in StrSplit(Setting, " ") {
            NewerString := NewerString Text
        }

        if SpacelessTable.Has(NewerString) {
            continue
        }

        SpacelessTable[NewerString] := Setting

        SelectionUI.AddText("w150 h20 xs", Setting ":").SetFont("s10")
        SelectionUI.AddCheckbox("w20 h20 v" NewerString " yp xp+210 Checked" SettingValue).SetFont("s9")
    }

    UIObjectTable := SelectionUI_CreateUIS(_Map, "toggle", _MapOBJ.Name)
    AdditiveUI := UIObjectTable.Additive.PhysicalUI
    AdditiveButton := UIObjectTable.Additive.AddButton
    DestructiveUI := UIObjectTable.Destructive.PhsyicalUI
    DestructiveButton := UIObjectTable.Destructive.DestroyButton

    AddSelectionButton := SelectionUI.AddButton("w95 h30 xs", "Add Selection")
    RemoveSelectionButton := SelectionUI.AddButton("w125 h30 xs+100 yp", "Remove Selection")
    FinalizeButton := SelectionUI.AddButton("w95 h30 xs", "Set Values")

    ShowAddSelection(*) {
        AdditiveUI.Show()
    }
    
    ShowRemoveSelection(*) {
        DestructiveUI.Show()
    }

    RefreshUI() {
        AdditiveUI.Destroy()
        DestructiveUI.Destroy()
        SelectionUI.Destroy()

        NewUIObject := CreateSelectionUI(_MapOBJ, BaseUI, TrueObject)
        NewUIObject.UI.Show()
        TrueObject.Button.OnEvent("Click", ShowFunction, false)
    }

    LoadRefreshUI(*) {
        AdditiveUI.Destroy()
        DestructiveUI.Destroy()
        SelectionUI.Destroy()

        NewUIObject := CreateSelectionUI(_MapOBJ, BaseUI, TrueObject, false)
        TrueObject.Button.OnEvent("Click", ShowFunction, false)
    }

    SelectionAdded(*) {
        Values := AdditiveUI.Submit()
        HitValue := true 
        if Values.BaseValue = "false" {
            HitValue := false
        }

        _Map[Values.NewInstance] := HitValue

        RefreshUI()
    }

    SelectionRemoved(*) {
        Values := DestructiveUI.Submit()
        _Map.Delete(Values.DestroyValue)

        RefreshUI()
    }

    SaveSettings(*) {
        AdditiveUI.Hide()
        DestructiveUI.Hide()
        ReturnedValues := ObjToMap(SelectionUI.Submit())

        for Key, Value in ReturnedValues {
            _Map[Key] := Value
        }
    }

    ShowFunction(*) {
        BaseUI.GetPos(&u, &u2, &u3, &u4)
        SelectionUI.GetPos(&a, &a2, &a3, &a4)
        SelectionUI.Show("X" (u - a3) " Y" u2 "")
        
        SelectionUI.GetPos(&a, &a2, &a3, &a4)
        SelectionUI.Show("X" (u - a3) " Y" u2 "")
    }

    AddSelectionButton.OnEvent("Click", ShowAddSelection)
    RemoveSelectionButton.OnEvent("Click", ShowRemoveSelection)
    AdditiveButton.OnEvent("Click", SelectionAdded)
    DestructiveButton.OnEvent("Click", SelectionRemoved)
    FinalizeButton.OnEvent("Click", SaveSettings)

    TrueObject.ShowFunction := ShowFunction
    TrueObject.UI := SelectionUI
    TrueObject.Button.OnEvent("Click", ShowFunction, true)
    TrueObject.RefreshFunc := LoadRefreshUI
    return TrueObject
}

;-- yeah this is only here bcause of how i setup thm :(
CreateObjectUI(_MapOBJ, BaseUI) {
    _Map := _MapOBJ.Map
    ObjectSettingsUI := Gui()

    NextOffset := 60
    Pg1Offset := 0
    TabsArray := []
    NumericalSetting := 0

    TotalSettings := 0

    if not VariablisticMap.Has(_MapOBJ.SaveName) {
        VariablisticMap[_MapOBJ.SaveName] := Map()
    }

    loop (Ceil(_Map.Count / _MapOBJ.ObjectsPerPage)) {
        TabsArray.InsertAt(TabsArray.Length + 1, "Settings[" A_Index "]")
    }


    OTabs := ObjectSettingsUI.AddTab3("", TabsArray)

    for _, Name in _MapOBJ.ObjectOrder {
        TotalSettings += 1
        NumericalSetting += 1 
        CurrentTab := Ceil(TotalSettings / _MapOBJ.ObjectsPerPage)
        OTabs.UseTab(CurrentTab)

        Objective := _Map[Name]

        if NumericalSetting > _MapOBJ.ObjectsPerPage or NumericalSetting = 1 {
            if NumericalSetting != 1 and Pg1Offset = 0 {
                Pg1Offset := NextOffset
            }

            NumericalSetting := 1
            NextOffset := 60
            ObjectSettingsUI.AddText("w200 h30 Section", _MapOBJ.Name).SetFont("s14 w700")
        }

        
        ObjectSettingsUI.AddText("w200 h20 xs y" NextOffset, Name).SetFont("s11 w700 underline")
        NextOffset += 30

        ; Arrange values to be in order from Array (Position) -> String (Text) -> Integer (Number) -> Boolean (Toggle)
        ObjectiveOrderArray := []
        SimplifiedObject := {A:[],B:[],C:[],D:[]}

        for I, V in Objective.OwnProps() {
            switch Type(V) {
                case "String":
                    SimplifiedObject.B.InsertAt(SimplifiedObject.B.Length + 1, I)
                case "Integer":
                    if _MapOBJ.Booleans.Has(I) {
                        SimplifiedObject.D.InsertAt(SimplifiedObject.D.Length + 1, I)
                    } else {
                        SimplifiedObject.C.InsertAt(SimplifiedObject.C.Length + 1, I)
                    }
                case "Array":
                    SimplifiedObject.A.InsertAt(SimplifiedObject.A.Length + 1, I)
            }
        }

        for _, ArrayD in SimplifiedObject.OwnProps() {
            for _, IValue in ArrayD {
                ObjectiveOrderArray.InsertAt(ObjectiveOrderArray.Length + 1, IValue)
            }
        }

        for _, IValue in ObjectiveOrderArray {
            I := IValue
            V := Objective.%IValue%

            if _MapOBJ.ObjectIgnore.Has(I) {
                continue
            }

            switch Type(V) {
                case "String":
                    ObjectSettingsUI.AddText("w150 h20 xs y" NextOffset, I ":").SetFont("s10")
                    VariablisticMap[_MapOBJ.SaveName][Name I] := ObjectSettingsUI.AddEdit("w120 h20 yp xp+190 v" I Name, V)
                    
                case "Integer":
                    if _MapOBJ.Booleans.Has(I) {
                        ObjectSettingsUI.AddText("w150 h20 xs y" NextOffset, I ":").SetFont("s10")
                        VariablisticMap[_MapOBJ.SaveName][Name I] := ObjectSettingsUI.AddCheckbox("w20 h20 v" I Name " yp xp+190 Checked" V)
                        VariablisticMap[_MapOBJ.SaveName][Name I].SetFont("s9")
                    } else {
                        ObjectSettingsUI.AddText("w150 h20 xs y" NextOffset, I ":").SetFont("s10")
                        VariablisticMap[_MapOBJ.SaveName][Name I] := ObjectSettingsUI.AddEdit("w120 h20 yp xp+190")
                        ObjectSettingsUI.AddUpDown("v" I Name " range1-2147483647", V)
                    }
                case "Array":
                    ObjectSettingsUI.SetFont("s10")
                    VariablisticMap[_MapOBJ.SaveName][Name I] := CreatePosHelper(ObjectSettingsUI, I, V, NextOffset, Name, true)
            }

            NextOffset += 30
        }

        if Pg1Offset = 0 and _ = _MapOBJ.ObjectOrder.Length {
            Pg1Offset := NextOffset
        }
    }

    OTabs.UseTab(1)
    FinalizeButton := ObjectSettingsUI.AddButton("w95 h30 xs y" Pg1Offset, "Set Values")

    ShowFunction(*) {
        BaseUI.GetPos(&u, &u2, &u3, &u4)
        ObjectSettingsUI.GetPos(&a, &a2, &a3, &a4)
        ObjectSettingsUI.Show("X" (u-a3) " Y" u2)

        ObjectSettingsUI.GetPos(&a, &a2, &a3, &a4)
        ObjectSettingsUI.Show("X" (u-a3) " Y" u2)
    }

    SubmitFunction(*) {
        ObjectSettingsUI.Hide()
        ReturnedValues := ObjToMap(ObjectSettingsUI.Submit())

        for Name, Objective in _Map {
            for I, V in Objective.OwnProps() {
                if _MapOBJ.ObjectIgnore.Has(I) {
                    continue
                }

                switch Type(V) {
                    case "Array":
                        Objective.%I% := [ReturnedValues[I Name "XPos"], ReturnedValues[I Name "YPos"]]
                        OutputDebug("`n Set Pos Value")
                    default:
                        Objective.%I% := ReturnedValues[I Name]
                        OutputDebug("`nSet Value")
                }
            }
        }
    }

    FinalizeButton.OnEvent("Click", SubmitFunction)
    FinalizeButton.SetFont("s10")

    return {UI:ObjectSettingsUI,ShowFunction:ShowFunction}
}

;-- Not mine, lowkey forgot where i got this from but know that i didnt make this (Did edit it a little tho)
ObjToMap(Obj, Depth:=5, IndentLevel:="")
{
	if Type(Obj) = "Object"
		Obj := Obj.OwnProps()
    if Type(Obj) = "String" {
      Obj := [Obj]
    }
	for k,v in Obj
	{
		List.= IndentLevel k
		if (IsObject(v) && Depth>1)
			List.="`n" ObjToMap(v, Depth-1, IndentLevel . "    ")
		Else
			List.=":" v
		List.="/\"
	}
	
  NewMap := Map()
  SplitArray := StrSplit(List, "/\")
  for __ArrayNum, SplitText in SplitArray {
    ValueSplit := StrSplit(SplitText, ":")
    
    if InStr(SplitText, ":") {
      NewMap[ValueSplit[1]] := ValueSplit[2]
      ; OutputDebug('`n' ValueSplit[1] " : " ValueSplit[2])
    }
  }

  return NewMap
}

TSMAP := Map()
NSMAP := Map()
TXMAP := Map() ; i forgot what TXMAP was for
SlMap := Map()
PSMAP := Map()


TSMAP["cj"] := false
TSMAP["def"] := false
TSMAP["ghi"] := true
TSMAP["jkl"] := false

NSMAP["stuff"] := 500
NSMAP["stuff2"] := 1000
NSMAP["stuff3"] := 1500
NSMAP["stuff4"] := 2000

TXMAP["gtw"] := "HIEA"

SlMap["stuff"] := true ; idk why it always shows 4 but i dont really care

PSMAP["teststuff"] := [100, 200]
PSMAP["teststuff2"] := [300, 400]
PSMAP["teststuff3"] := [500, 600]
PSMAP["teststuff4"] := [700, 800]

/*
global ColorsAndStuffMap := Map(
    "Basic", {
        Color:0xDBDAE6, RarityValue:1, CappedValue:100, ToCapValue:true, evil:[235,235]
    },
    "Rare", {
        Color:0xBFFFA8, RarityValue:2, CappedValue:500, ToCapValue:true, CappedValueD:100,
    },
    "Epic", {
        Color:0x9EEFFF, RarityValue:3, CappedValue:3000, ToCapValue:true, CappedValueD:100,
    },
    "Legendary", {
        Color:0xFFDAA6, RarityValue:4, CappedValue:65000, ToCapValue:true, CappedValueD:100,
    },
    "Mythical", {
        Color:0xFFB1BC, RarityValue:5, CappedValue:50000, ToCapValue:false, CappedValueD:100,
    },
    "Exotic", {
        Color:0xFFBAFE, RarityValue:6, CappedValue:100000, ToCapValue:false
    },
    "Divine", {
        Color:0xFFF8B9, RarityValue:7, CappedValue:65005, ToCapValue:false
    },
    "Superior", {
        Color:0xEEFFFF, RarityValue:8, CappedValue:(10**6), ToCapValue:false
    },
    "Celestial", {
        Color:0xF6E3FE, RarityValue:9, CappedValue:(25*(10**7)), ToCapValue:false
    },
    "Exclusive", {
        Color:0xD8BFFF, RarityValue:10, CappedValue:(2*(10**9)), ToCapValue:false
    },
    "Unknown", {
        Color:0x000000, RarityValue:3, CappedValue:(125000), ToCapValue:false
    }
)

ObjectOrder := ["Basic", "Rare", "Epic", "Legendary", "Mythical", "Exotic", "Divine", "Superior", "Celestial", "Exclusive", "Unknown"]
*/
CreateBaseUI(Map(
    "Main", {Title:"Basic", Video:"nothing here", Description:"F7 to exit`nF8 to reload`nF9 to pause", MacroName:"Basic", Version:"1.0.1", DescY:250, IncludeFonts:false, noCaptions:true},
    "Settings", [
        {
            Map:TSMAP,
            Name:"Toggle Settings",
            Type:"Toggle",
            SaveName:"ToggleSettings",
            IsAdvanced:false
        },
        {
            Map:NSMAP,
            Name:"Number Settings",
            Type:"Number",
            SaveName:"NumberSettings",
            IsAdvanced:false
        },
        {
            Map:TXMAP,
            Name:"Text Settings",
            Type:"Text",SaveName:"TextSettings",
            IsAdvanced:false
        },
        {
            Map:SlMap,
            Name:"Selection Values",
            Type:"Selection",
            SaveName:"SelectionSettings",
            IsAdvanced:false
        },
        {
            Map:PSMAP,
            Name:"Positioning",
            Type:"Position",
            SaveName:"PositioningSettings",
            IsAdvanced:false
        },
        /*
        {
            Map:ColorsAndStuffMap,
            Name:"Rarity Settings",
            Type:"Object",
            SaveName:"RSettings",
            IsAdvanced:false,
            Booleans:Map("ToCapValue", true),
            ObjectIgnore:Map("Color", true, "RarityValue", true),
            ObjectOrder:ObjectOrder,
            ObjectsPerPage:5
        },
        */

    ],
    "SettingsFolder", {Folder:A_MyDocuments "\PetCatchers_Macros\SavedSettings\", FolderName:"Testing"}
)).BaseUI.Show()

F3::{

}

^LButton::{
    try {
        OutputDebug(Type(CurrentPostionLabel))
        if Type(CurrentPostionLabel) = "Array" {
            if Type(CurrentPostionLabel[2]) = "String" {
                if CurrentPostionLabel[2] = "X" {
                    MouseGetPos(&u,&u2)
                    CurrentPostionLabel[1].Text := u
                    global CurrentPostionLabel := ""
                } else {
                    MouseGetPos(&u,&u2)
                    CurrentPostionLabel[1].Text := u2
                    global CurrentPostionLabel := ""
                }
            } else {
                MouseGetPos(&u,&u2)
                CurrentPostionLabel[1].Text := u
                CurrentPostionLabel[2].Text := u2
                global CurrentPostionLabel := ""
            } 
        }
    }
}

;actual macro part

hi := "F:hello()"
hello() {
    ToolTip("hello")
}

RouteUser(RouteText) {
    RouteArray := StrSplit(RouteText, "|")

    for _, RText in RouteArray {
        if InStr(RText, "wt(") {
            Time := SubStr(RText, InStr(RText, "(") + 1, InStr(RText, ")") - InStr(RText, "(") - 1)
            Sleep(Time)
        } else if InStr(RText, "mc(") or InStr(RText, "mrc(") {
            Button := InStr(RText, "mc(") ? "left" : "right"
            CoordTextStart := InStr(RText, "(") + 1
            CoordTextEnd := InStr(RText, ")") - CoordTextStart
            CoordText := SubStr(RText, CoordTextStart, CoordTextEnd)
            Coord := StrSplit(CoordText, ",")
            Action := SubStr(RText, InStr(RText, "mc(") ? 3 : 4, 1)
            if (Action = "d") {
                Send "{Click " Button ", " Coord[1] ", " Coord[2] ", , Down}"
            } else if (Action = "u") {
                Send "{Click " Button ", " Coord[1] ", " Coord[2] ", , Up}"
            } else {
                Send "{Click " Button ", " Coord[1] ", " Coord[2] "}"
            }
        } else if InStr(RText, "mm(") {
            CoordTextStart := InStr(RText, "(") + 1
            CoordTextEnd := InStr(RText, ")") - InStr(RText, "(") - 1
            CoordText := SubStr(RText, CoordTextStart, CoordTextEnd)
            Coord := StrSplit(CoordText, ",")
            Send "{MouseMove " Coord[1] ", " Coord[2] "}"
        } else if InStr(RText, "F:") {
                FunctionCall := SubStr(RText, 3)
                FunctionName := SubStr(FunctionCall, 1, InStr(FunctionCall, "(") - 1)
                Parameters := SubStr(FunctionCall, InStr(FunctionCall, "(") + 1, InStr(FunctionCall, ")") - InStr(FunctionCall, "(") - 1)
                if (Parameters = "") {
                    %FunctionName%()
                } else {
                    ParameterValue := %Parameters%
                    %FunctionName%(ParameterValue)
                }
        } else {
            Key := SubStr(RText, 1, 1)
            SecondChar := SubStr(RText, 2, 1)
            if (SecondChar = "d" or SecondChar = "u") {
                Action := SecondChar
                if (Action = "d") {
                    Send "{" Key " Down}"
                } else if (Action = "u") {
                    Send "{" Key " Up}"
                }
            } else {
                if InStr(RText, "(") and InStr(RText, ")") { 
                    Time := SubStr(RText, InStr(RText, "(") + 1, InStr(RText, ")") - InStr(RText, "(") - 1)
                    Send "{" Key " Down}"
                    Sleep(Time)
                    Send "{" Key " Up}"
                }
            }
        }
    }
}

global macroEnabled := false

EnableMacro(*) {
    global macroEnabled
    if (macroEnabled) {
        return
    } else {
        macroEnabled := true
        main()
    }
}

main() {
    if (macroEnabled) {
        loop {
            RouteUser(hi)
        }
    } else {
        return
    }
}

f7::ExitApp
f8::Reload
f9::Pause