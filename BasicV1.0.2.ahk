; /[V1.0.2]\

#Include "%A_MyDocuments%\PS99_Macros\Modules\Router2.ahk"
#Include "%A_MyDocuments%\PS99_Macros\Modules\EasyUI.ahk"

#Requires AutoHotkey v2.0 
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"
SendMode "Event"

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
global FredokaOneFont := "%A_MyDocuments%\PS99_Macros\Storage\Fonts\F_One.ttf"
global TimesNewRomanFont := "%A_MyDocuments%\PS99_Macros\Storage\Fonts\T_NR.ttf"
global CB := ""

global VariablisticMap := Map()

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
    "SettingsFolder", {Folder:A_MyDocuments "\PS99_Macros\SavedSettings\", FolderName:"Basic"}
)).BaseUI.Show()

F3::{

}

;actual macro part

hi := "F:hello()"
hello() {
    ToolTip("hello")
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
