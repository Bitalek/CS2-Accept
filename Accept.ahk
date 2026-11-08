#Requires AutoHotkey v2.0
#SingleInstance Force
CoordMode "Pixel", "Screen"
CoordMode "Mouse", "Screen"
CoordMode "ToolTip", "Screen"

X1 := 800, Y1 := 400, X2 := 1100, Y2 := 700   ; область поиска
TargetColor := 0x36B752                        ; цвет кнопки
Variation := 15                                ; разброс цвета
CheckInterval := 500                           ; интервал проверки (мс)

; Режим F3 (AFK)
AFKInterval := 10000      ; интервал клика (мс) = 10 секунд
AFKClickX := 960          ; X координата клика
AFKClickY := 540          ; Y координата клика

; Индикатор
IndicatorX := 20
IndicatorY := 20

; Звуки
SndOn    := "C:\Windows\Media\Speech On.wav"
SndOff   := "C:\Windows\Media\Speech Off.wav"
SndAFK   := "C:\Windows\Media\Speech Sleep.wav"
SndClick := "C:\Windows\Media\Windows Unlock.wav" 

global running := false
global afkMode := false

ShowIndicator()

F1:: {
    global running, afkMode
    if (afkMode) {
        afkMode := false
        SetTimer(AFKClick, 0)
    }
    running := !running
    if running {
        SetTimer(CheckAndClick, CheckInterval)
        PlaySound(SndOn)
    } else {
        SetTimer(CheckAndClick, 0)
        PlaySound(SndOff)
    }
    ShowIndicator()
}

F3:: {
    global running, afkMode
    if (running) {
        running := false
        SetTimer(CheckAndClick, 0)
    }
    afkMode := !afkMode
    if afkMode {
        AFKClick()
        SetTimer(AFKClick, AFKInterval)
        PlaySound(SndAFK)
    } else {
        SetTimer(AFKClick, 0)
        PlaySound(SndOff)
    }
    ShowIndicator()
}

F2:: {
    PlaySound(SndOff)
    Sleep(200)
    ExitApp()
}

; F1: по цвету
CheckAndClick() {
    global X1, Y1, X2, Y2, TargetColor, Variation, running, IndicatorX, IndicatorY, SndClick
    if (!running)
        return
    step := 8
    y := Y1
    while (y <= Y2) {
        x := X1
        while (x <= X2) {
            try {
                if (ColorSimilar(PixelGetColor(x, y), TargetColor, Variation)) {
                    MouseMove(x, y, 0)
                    Click
                    PlaySound(SndClick)
                    ToolTip("Кнопка нажата", IndicatorX, IndicatorY + 45)
                    SetTimer(() => ShowIndicator(), -2000)
                    return
                }
            }
            x += step
        }
        y += step
    }
}

; F3: авто клик
AFKClick() {
    global afkMode, AFKClickX, AFKClickY, IndicatorX, IndicatorY, SndClick
    if (!afkMode)
        return
    MouseMove(AFKClickX, AFKClickY, 0)
    Click
    PlaySound(SndClick)
    ToolTip("Auto-клик: " AFKClickX ", " AFKClickY, IndicatorX, IndicatorY + 45)
    SetTimer(() => ShowIndicator(), -2000)
}

; Разброс цвета
ColorSimilar(c1, c2, tol) {
    r1 := (c1 >> 16) & 0xFF, g1 := (c1 >> 8) & 0xFF, b1 := c1 & 0xFF
    r2 := (c2 >> 16) & 0xFF, g2 := (c2 >> 8) & 0xFF, b2 := c2 & 0xFF
    return (Abs(r1 - r2) <= tol && Abs(g1 - g2) <= tol && Abs(b1 - b2) <= tol)
}

; Звук
PlaySound(file) {
    try {
        if FileExist(file)
            SoundPlay(file)
    }
}

; Меню
ShowIndicator() {
    global running, afkMode, IndicatorX, IndicatorY, AFKClickX, AFKClickY
    if (afkMode)
        state := "AFK: клик каждые " (AFKInterval/1000) "с по (" AFKClickX ", " AFKClickY ")"
    else if (running)
        state := "АВТОПРИНЯТИЕ (поиск по цвету): ВКЛ"
    else
        state := "Bitalek"
    text := state "`nF1 — по цвету   F3 — Auto клик   F2 — exit"
    ToolTip(text, IndicatorX, IndicatorY)
}