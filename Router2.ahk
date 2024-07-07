#Requires AutoHotkey v2.0
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"
SendMode "Event"

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