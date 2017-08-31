#print Compilation of SpaceAttack! is now complete.
#include "fbgfx.bi"
#include "file.bi"
#ifndef __FB_WIN32__
Print "Incorrect OS (Operating System)!"
Sleep 5000, 1
End
#endif
Const background = "bin\background.ogg"
#include "bass.bi"
#ifndef TRUE
#define FALSE 0
#define TRUE 1
#endif
Const SpaceAttackVersion As String = "4.2.2"
Using FB
Type boolean As Byte
Type shot
    shot2 As boolean
    shot3 As boolean
    shot4 As boolean
    shot5 As boolean
End Type
Type timeview
    m As Integer
    s As Integer
    max As Integer
    set As Integer
    full As String
End Type
Type Star
    x As Integer
    y As Integer
    size As Integer
End Type
Declare Sub youwin
Declare Sub youlose
Declare Sub pause
Declare Sub define
Declare Function chk As Integer
Declare Sub speedset
Declare Sub timesetter
Declare Sub scsetter
Declare Sub eon
Declare Sub startmenu
Declare Sub main
Declare Sub options
Declare Sub load
Declare Sub SetReset
Declare Sub saver
Declare Sub errorscreen(a As Integer)
Declare Sub PutStars
Declare Function Menu(DispText() As String) As Integer
Declare Sub HighScores(Byval cheat As boolean)
Declare Sub clearbuffer
Mkdir "logs"
Mkdir "saves"
If (Mkdir("Screenshots")) = 0 Then Print #1, "Screenshots folder created"
Dim i As Integer
If Fileexists("latest.log") <> 0 Then
    Do
        i += 1
        If Fileexists("logs\" & Date & "_Number_" & i & ".log") = 0 Then
            Filecopy("latest.log", "logs\" & Date & "_Number_" & i & ".log")
            Exit Do
        End If
    Loop
    Kill("latest.log")
    Print #1, "Latest log moved"
End If
Open "latest.log" For Output As #1
Print #1, "Setting ""bin"" to default folder"
Print #1, "Settings file name saved"
Const set As String = "settings.config"
Print #1, "Joystick ID set"
Const JoyID As Integer = 0
Print #1, "Declaring saved variables"
Dim Shared As Integer musicState, spe, spes, timem, sc, easy, timems, NumOfStars
Dim As Integer filenum
Dim Shared As String scname
If Fileexists(set) = 0 Then
    filenum = Freefile
    Open set For Output As #filenum
    Write #filenum, 50, 25, 5, "sc", 1, 1, 1500, 0
    Close #filenum
End If
filenum = Freefile
Open set For Input As #filenum
Input #filenum, spe, spes, timems, scname, sc, easy, NumOfStars, musicState
Close #filenum
Print #1, "Saved settings loaded"
Windowtitle "SpaceAttack!"
Cls
Dim Shared StarSize(1 To 2) As Any Ptr
Dim Shared ship As Any Ptr
Dim Shared bomb As Any Ptr
Dim Shared eship As Any Ptr
Dim Shared As Integer JoyInit, spaces, vspaces, SoundInit, elives, lor, speed, filenumber, x, y, click, scroll, scrollsave, errors, JoyButtons, spaces_save, JoyButons_true, spot
Dim Shared As Single JoyX, JoyX_save
Dim Shared As shot c
Dim Shared As timeview timed
Dim Shared stars(1 To NumOfStars) As Star
Dim Shared musicHandle As HSTREAM
Screen 17
'640x400
Print #1, "Sound file loading..."
If (BASS_Init(-1, 44100, 0, 0, 0) <> TRUE) Then
    Print #1, "Could not initialize audio! BASS returned error " & BASS_ErrorGetCode()
    Close
    End
Else
    musicHandle = BASS_StreamCreateFile(0, Strptr(background), 0, 0, BASS_Sample_Loop)
    BASS_ChannelPlay(musicHandle, 0)
    If musicState = 1 Then BASS_ChannelPause(musicHandle)
End If
Print #1, """Music"" initialized..."
For i As Integer = 1 To NumOfStars
    stars(i).x = Cint(Rnd * 640)
    stars(i).y = Cint(Rnd * 400)
    stars(i).size = Cint(Rnd * 2000) / 1000
Next i
If Getjoystick(JoyID, JoyButtons) = 0 Then JoyInit = TRUE Else JoyInit = FALSE
define
startmenu
Sub define
    spaces = 15
    vspaces = 15
    elives = 10
    StarSize(1) = Imagecreate(1, 1)
    Bload("bin\Star1.spr", StarSize(1)) '[(<->)]
    StarSize(2) = Imagecreate(3, 3)
    Bload("bin\Star2.spr", StarSize(2)) '[(<->)]
    ship = Imagecreate(16, 16)
    Print #1, "Player sprite allocated..."
    bomb = Imagecreate(16, 16)
    Print #1, "Bomb sprite allocated..."
    eship = Imagecreate(16, 16)
    Print #1, "Enemy sprite allocated..."
    Bload("bin\eship.spr", eship)
    Print #1, "Enemy sprite loaded..."
    Bload("bin\ship.spr", ship)
    Print #1, "Player sprite loaded..."
    Bload("bin\bomb.spr", bomb)
    Print #1, "Bomb sprite loaded..."
    spot = 79 - Len(SpaceAttackVersion)
    If easy = 0 Then
        timed.max = 10
    Elseif easy = 1 Then
        timed.max = 5
    Else
        errorscreen(34)
    End If
    timed.m = timems
End Sub
Sub cleanup Destructor
    Print #1, "Destroying sprite buffers"
    Imagedestroy(bomb)
    Imagedestroy(ship)
    Imagedestroy(eship)
    Print #1, "Destroying music buffer and unloading from memory."
    BASS_Free()
    Print #1, "Closing all files (including this one)...GOODBYE!"
    Close
End Sub
Sub pause
    Sleep 200, 1
    Cls
    Print "Press S or Select to save game"
    Locate 13, 34: Print "Game is Paused"
    Do
        Cls
        PutStars
        Print "Press S or Select to save game"
        Locate 13, 34: Print "Game is Paused"
        If JoyInit = TRUE Then
            Getjoystick(JoyID, JoyButtons)
            For i As Integer = 0 To 26
                If (JoyButtons And 1 Shl i) And i = 9  Or Multikey(SC_ESCAPE) Then
                    Sleep 200, 1
                    Exit Do
                End If
            Next
        Else
            If Multikey(SC_ESCAPE) Then
                Sleep 200, 1
                Exit Do
            End If
        End If
        If Multikey(SC_S) Then saver
        If Multikey(SC_M) Then
            musicState = musicState xor 1
            If musicState = 0 Then
                BASS_ChannelPlay(musicHandle, 0)
            Else
                BASS_ChannelPause(musicHandle)
            End If
            SetReset
            Sleep 100, 1
        End If
        If Multikey(SC_B) Then
            Bsave "Screenshots\" & scname & sc & ".bmp", 0
            sc = sc + 1
            SetReset
        End If
        If Multikey(SC_Q) Then
            Close
            End
        End If
        Sleep 50, 1
    Loop
End Sub
Function chk As Integer
    If spaces > 39 Or spaces < 0 Then
        Return 18
    Elseif vspaces > 39 Or vspaces < 0 Then
        Return 19
    Elseif elives < 0 Or elives > 50 Then
        Return 20
    Elseif timed.set < 0 Or timed.set > 20 Then
        Return 21
    Elseif c.shot2 < 0 Or c.shot2 > 1 Then
        Return 22
    Elseif c.shot3 < 0 Or c.shot3 > 1 Then
        Return 23
    Elseif c.shot4 < 0 Or c.shot4 > 1 Then
        Return 24
    Elseif c.shot5 < 0 Or c.shot5 > 1 Then
        Return 25
    Elseif timed.m > timed.max Or timed.m < 0 Then
        Return 26
    Elseif timed.s > 59 Or timed.s < -1 Then
        Return 27
    Elseif speed < spes Or speed > spe Then
        Return 28
    Elseif speed > spes And speed < spe Then
        Return 29
    Elseif sc < 1 Then
        Return 30
    Elseif easy > 1 Or easy < 0 Then
        Return 31
    Elseif spe < 0 Or spes < 0 Then
        Return 32
    Elseif scname = "nul" Then
        Return 33
    Else
        Return 0
    End If
End Function
Sub speedset
    Dim As Integer save, save2, ff
    Cls
    ClearBuffer
    save = spe
    save2 = spes
    Input "Normal speed:" , spe
    Input "Fast speed:" , spes
    If spe < 1 Then
        spe = save
        Cls
        Print "Incorrect value"
        Sleep 3000, 1
    Elseif spes < 1 Then
        spes = save2
        Cls
        Print "Incorrect value"
        Sleep 3000, 1
    End If
    If spe < spes Then Swap spe, spes
    SetReset
    Cls
End Sub
Sub timesetter
    Cls
    Sleep 500, 1
    ClearBuffer
    Dim As Integer timesave, ff
    Input "Time in minutes:" , timesave
    If timesave > timed.m Then
        Print "No cheating!"
        Sleep
        Cls
    Elseif timesave < 0 Then
        Print "Incorrect value"
        Sleep 3000, 1
    Elseif timesave < timed.m Then
        timems = timesave
    End If
    SetReset
    timed.m = timems
End Sub
Sub scsetter
    Cls
    Sleep 500, 1
    ClearBuffer
    Dim save As String
    Dim yon As Integer
    save = scname
    Input "Enter default screenshot name:" , scname
    If scname = save Then
        yon = 0
    Else
        yon = 1
    End If
    If yon = 1 Then sc = 1
    SetReset
End Sub
Sub eon
    Dim As String Mode(1 To 2) => {"Set game to easy mode", "Set game to hard mode"}
    Dim As Integer Result
    Result = Menu(Mode())
    If Result = 1 Then
        easy = 1
    Elseif Result = 2 Then
        easy = 0
        timems = 10
    End If
    SetReset
End Sub
Sub main
    color 255
    ClearBuffer
    Do
        Cls
        PutStars
        filenumber = Freefile
        Print #1, "File loader re-loaded..."
        If Multikey(SC_S) Or JoyButtons = 128 Then
            speed = spes
            Print #1, "Speed fast"
        Elseif Not Multikey(SC_S) Or JoyButtons = 128 Then
            speed = spe
            Print #1, "Speed normal"
        End If
        Locate 1, 1
        Print #1, "Cursor reset"
        Print #1, "Checking for player loss"
        If timed.m = 0 And timed.s = 0 Then
            youlose
            End
        End If
        errors = chk
        Print #1, "Variables checked"
        If errors <> 0 Then
            errorscreen(errors)
        End If
        scrollsave = scroll
        Print #1, "Previous scroll location saved"
        If JoyInit = TRUE Then
            JoyX_save = JoyX
            Print #1, "Previous joystick location saved"
        End If
        If Not Getmouse(-1, -1, -1, -1) = 0 Then Getmouse(x, y, scroll, click)
        Print #1, "Mouse read"
        If JoyInit = TRUE Then
            Getjoystick(JoyID, JoyButtons, JoyX)
            Print #1, "Joystick read"
        End If
        Print "Remaining Enemy Lives: " & elives
        timed.set = timed.set + 1
        Print #1, "Timer updated"
        If timed.set = 20 Then
            timed.s = timed.s - 1
            timed.set = 0
        End If
        If timed.s = -1 Then
            timed.m = timed.m - 1
            timed.s = 59
        End If
        If timed.s > 9 Then
            timed.full = timed.m & ":" & timed.s
        Elseif timed.s < 10 Then
            timed.full = timed.m & ":0" & timed.s
        Else
            Close
            End
        End If
        Print "Time Left    " & timed.full
        If elives = 0 Then
            youwin
            HighScores(FALSE)
            End
        End If
        If c.shot5 = TRUE And spaces = vspaces And vspaces < 39 And vspaces > 0 Then
            Print #1, "Left or right..."
            lor = Int(Rnd * 50) + 0
            If lor > 25 Then vspaces = vspaces + 1
            If lor < 25 Then vspaces = vspaces - 1
        Elseif c.shot5 = TRUE And spaces = vspaces And vspaces = 39 Then
            vspaces = vspaces - 1
        Elseif c.shot5 = TRUE And spaces = vspaces And vspaces = 0 Then
            vspaces = vspaces + 1
        End If
        If easy = 1 Then
            If spaces_save = spaces + 1 And vspaces < spaces And vspaces <> (spaces - 1) Then
                vspaces = vspaces + 1
                Put ((vspaces * 16), 32), eship
            Elseif spaces_save = spaces - 1 And vspaces > spaces And vspaces <> (spaces + 1) Then
                vspaces = vspaces - 1
                Put ((vspaces * 16), 32), eship, trans
            Else
                Put ((vspaces * 16), 32), eship, trans
            End If
        Elseif easy = 0 Then
            If spaces_save = spaces + 1 And vspaces < spaces And vspaces <> (spaces - 2) And vspaces <> (spaces - 1) Then
                vspaces = vspaces + 1
                Put ((vspaces * 16), 32), eship
            Elseif spaces_save = spaces - 1 And vspaces > spaces And vspaces <> (spaces + 2) And vspaces <> (spaces + 1) Then
                vspaces = vspaces - 1
                Put ((vspaces * 16), 32), eship, trans
            Else
                Put ((vspaces * 16), 32), eship, trans
            End If
        Else
            errorscreen(31)
        End If
        If c.shot5 = TRUE Then
            Put ((spaces * 16), 46), bomb, trans
            If vspaces = spaces Then
                elives = elives - 1
            End If
            c.shot5 = FALSE
        End If
        If c.shot4 = TRUE Then
            Put ((spaces * 16), 62), bomb, trans
            c.shot4 = FALSE
            c.shot5 = TRUE
        End If
        If c.shot3 = true Then
            Put ((spaces * 16), 78), bomb, trans
            c.shot3 = FALSE
            c.shot4 = TRUE
        End If
        If c.shot2 = true Then
            Put ((spaces * 16), 94), bomb, trans
            c.shot2 = FALSE
            c.shot3 = TRUE
        End If
        If Multikey(SC_Q) Then End
        spaces_save = spaces
        If Multikey(SC_RIGHT) And spaces < 39 Then spaces += 1
        If Multikey(SC_LEFT) And spaces > 0 Then spaces -= 1
        If scroll = scrollsave - 1 And spaces < 39 Then spaces += 1
        If scroll = scrollsave + 1 And spaces > 0 Then spaces -= 1
        If JoyInit = TRUE Then
            If JoyX_save <= JoyX + .2 And spaces < 39 Then
                spaces += 1
                JoyX_save = 0
            End If
            If JoyX_save >= JoyX - .2 And spaces > 0 Then
                spaces -= 1
                JoyX_save = 0
                JoyX = 0
            End If
        End If
        Print #1, "Pause?"
        If Multikey(SC_ESCAPE) Or JoyButtons = 512 Then
            Print #1, "Pause!"
            If JoyInit = TRUE Then
                JoyButtons = 0
                pause
                JoyButtons = 0
            Else
                pause
            End If
        End If
        Print #1, "Check for shooting"
        If Multikey(SC_SPACE) Then
            Put ((spaces* 16), 110), bomb, trans
            c.shot2 = TRUE
        Elseif click = 1 Then
            Put ((spaces * 16), 110), bomb, trans
            c.shot2 = TRUE
        Elseif JoyButtons = 2 Then
            Put ((spaces * 16), 110), bomb, trans
            c.shot2 = TRUE
        End If
        Print #1, "Drawing player"
        Put ((spaces * 16), 128), ship, trans
        Print #1, "Check for Screenshot"
        If Multikey(SC_B) Then
            Bsave "Screenshots\" & scname & sc & ".bmp", 0
            sc = sc + 1
            SetReset
        End If
        If Multikey(SC_W) And Multikey(SC_I) And Multikey(SC_N) Then
            youwin
            HighScores(TRUE)
            Close
            End
        End If
        Print #1, "Printing Version"
        Locate 24, spot: Print SpaceAttackVersion
        Sleep speed, 1
    Loop
End Sub
Sub youwin
    Print #1, "New screen"
    Screenres 320, 200, 32
    ClearBuffer
    '' set up the screen and fill the background with a color
    
    '' set up an image and draw something in it
    Print #1, "Drawing a smiley face onto image"
    Dim img As Any Ptr = Imagecreate( 32, 32, Rgb(255, 0, 255) )
    Circle img, (16, 16), 15, Rgb(255, 255, 0),     ,     , 1, f
    Circle img, (10, 10), 3,  Rgb(  0,   0, 0),     ,     , 2, f
    Circle img, (23, 10), 3,  Rgb(  0,   0, 0),     ,     , 2, f
    Circle img, (16, 18), 10, Rgb(  0,   0, 0), 3.14, 6.28
    
    '' PUT the image in the center of the screen
    Print #1, "Putting image onto screen"
    Put (160 - 16, 100 - 16), img, Trans
    
    '' free the image memory
    Print #1, "Destroying image with smiley face"
    Imagedestroy img
    Print #1, "Outputting ""You Win!!!"""
    Print "You Win!!!"
    Print #1, "Waiting 3 seconds"
    Sleep 3000, 1
    Sleep
End Sub
Sub youlose
    Print #1, "New Screen"
    Screenres 320, 200, 32
    ClearBuffer
    Print #1, "Creating sad face image buffer"
    Dim img As Any Ptr = Imagecreate( 32, 32, Rgb(255, 0, 255) )
    Print #1, "Drawing sad face to buffer"
    Circle img, (16, 16), 15, Rgb(255, 255, 0),     ,     , 1, f
    Circle img, (10, 10), 3,  Rgb(  0,   0, 0),     ,     , 2, f
    Circle img, (23, 10), 3,  Rgb(  0,   0, 0),     ,     , 2, f
    Circle img, (16, 28), 10, Rgb(  0,   0, 0), 6.28, 3.14
    Print #1, "Putting image in buffer onto screen"
    Put (160 - 16, 100 - 16), img, Trans
    Print #1, "Destroying image buffer"
    Imagedestroy img
    Print "You Lose..."
    Sleep 3000, 1
    Sleep
End Sub
Sub startmenu
    Dim As String Text(1 To 4) => {"Start New Game", "Load Game", "Options", "Exit Game"}
    Dim Result As Integer
    Do
        Result = Menu(Text())
        If Result = 1 Then
            Sleep 500, 1
            main
        Elseif Result = 2 Then
            Sleep 500, 1
            load
        Elseif Result = 3 Then
            Sleep 500, 1
            options
        Elseif Result = 4 Then
            End
        End If
    Loop
End Sub
Sub options
    Dim ops(1 To 5) As String => {"Change Time", "Change Mode", "Change Speed", "Change Default Screenshot Name", "Back to Main Menu"}
    Dim Result As Integer
    Result = Menu(ops())
    If Result = 1 Then
        Sleep 500, 1
        timesetter
    Elseif Result = 2 Then
        Sleep 500, 1
        eon
    Elseif Result = 3 Then
        Sleep 500, 1
        speedset
    Elseif Result = 4 Then
        Sleep 500, 1
        scsetter
    Elseif Result = 5 Then
        Exit Sub
    End If
End Sub
Sub load
    ClearBuffer
    Dim file As Integer = Freefile
    Dim SaveFile As String
    Dim As String Slots(1 To 4) => {"Slot 1", "Slot 2", "Slot 3", "Slot 4"}
    Dim As Integer Result
    Result = Menu(Slots())
    SaveFile = "saves\slot" & Result & ".sav"
    If Fileexists(SaveFile) <> 0 Then
        Open SaveFile For Input As #file
        Input #file, spaces, vspaces, elives, lor, timed.set, timed.s, timed.m, speed, filenumber, timed.max, click, scroll, scrollsave, c.shot2, c.shot3, c.shot4, c.shot5
        Close #file
    Else
        Cls
        Print "Slot " & Result & " doesn't exist!"
        Sleep 500, 1
        End
    End If
End Sub
Sub saver
    ClearBuffer
    Dim file As Integer = Freefile
    Dim SaveFile As String
    Dim OverWrite As String
    Dim As String Slots(1 To 4) => {"Slot 1", "Slot 2", "Slot 3", "Slot 4"}
    Dim As Integer Result
    Print #1, "Creating variables"
    Result = Menu(Slots())
    SaveFile = "saves\slot" & Result & ".sav"
    If Fileexists(SaveFile) <> 0 Then
        Do
            Cls
            Print "Are you sure? Slot " & Mid(SaveFile, 11, 1) & " will be overwritten![Y|N]"
            Input OverWrite
        Loop Until Ucase(OverWrite) = "Y" Or Ucase(OverWrite) = "N"
        If Ucase(OverWrite) = "Y" Then
            Open SaveFile For Output As #file
            Write #file, spaces, vspaces, elives, lor, timed.set, timed.s, timed.m, speed, filenumber, timed.max, click, scroll, scrollsave, c.shot2, c.shot3, c.shot4, c.shot5
            Close #file
            Print #1, SaveFile & " overwritten."
            Print #1, "Game saved on slot " & Mid(SaveFile, 11, 1) & "."
        Else
            Print #1, SaveFile & " not overwritten."
            Print #1, "Game not saved."
        End If
    Else
        Open SaveFile For Output As #file
        Write #file, spaces, vspaces, elives, lor, timed.set, timed.s, timed.m, speed, filenumber, timed.max, click, scroll, scrollsave, c.shot2, c.shot3, c.shot4, c.shot5
        Close #file
        Print #1, "Game saved on slot " & Mid(SaveFile, 11, 1)
    End If
End Sub
Sub errorscreen(a As Integer)
    Print "Error! Error! (" & a & ")"
    Print #1, "Aborting due to error" & a & "!"
    Sleep 5000, 1
    Close
    End
End Sub
Sub PutStars
    For i As Integer = 1 To NumOfStars
        Put (stars(i).x, stars(i).y), StarSize(stars(i).size), trans
        stars(i).y += 1
        If stars(i).y = 401 Then stars(i).y = 0
    Next i
End Sub
Function Menu(DispText() As String) As Integer
    color 255
    ClearBuffer
    Dim As Integer size = (Ubound(DispText) - Lbound(DispText)) + 1
    Dim As Integer SpotX(1 To size), SpotY(1 To size)
    Dim As boolean AlreadyUsed
    Print #1, "Creating variables"
    Dim As String cat(1 To size)
    Dim As String cart(1 To size)
    Dim As String carte(1 To size)
    Dim As String cate(1 To size)
    Dim As Integer waitfor, JoyYN, Selected = 1
    Dim As Single JoyY, JoyY_save
    'carte, cate, words, cat, cart
    Print #1, "Assigning Default Variable Value"
    carte(1) = ">"
    cart(1) = "<"
    cat(1) = " "
    cate(1) = " "
    For i As Integer = 2 To size
        carte(i) = " "
        cart(i) = " "
        cat(i) = " "
        cate(i) = " "
    Next
    SpotY(1) = 14 - size/2
    For i As Integer = 2 To size Step 1
        SpotY(i) = SpotY(i - 1) + 1
    Next
    For i As Integer = Lbound(DispText) To size Step 1
        '40, 41?
        '26
        SpotX(i) = 40 - Int(Len(DispText(i))  / 2)
    Next
    Do
        Print #1, "Clearing Screen"
        Cls
        PutStars
        For i As Integer = Lbound(DispText) To size Step 1
            If carte(i) = ">" Or cate(i) = ">" Then Selected = i
        Next i
        waitfor = waitfor + 1
        If JoyInit = TRUE And JoyYN = 0 Then
            JoyY_save = JoyY
            Getjoystick(JoyID, JoyButtons, , JoyY)
        Elseif JoyInit = TRUE Then
            JoyYN -= 1
        End If
        If waitfor = 6 Then waitfor = 1
        For i As Integer = 1 To size Step 1
            If waitfor = 1 And carte(i) = ">" Or cate(i) = ">" And waitfor = 5 Then
                Swap carte(i), cate(i)
                Swap cat(i), cart(i)
            End If
        Next
        'bigger is down + .2
        'lower is up - .2
        AlreadyUsed = FALSE
        If JoyInit = TRUE Then
            For i As Integer = 1 To size
                If i < size And i > 1 Then
                    If Multikey(SC_DOWN) And selected = i And AlreadyUsed = FALSE Then
                        Swap carte(i), carte(i + 1)
                        Swap cate(i), cate(i + 1)
                        Swap cat(i), cat(i + 1)
                        Swap cart(i), cart(i + 1)
                        JoyY = 0
                        JoyY_save = 0
                        JoyYN = 1
                        Selected = i + 1
                        AlreadyUsed = TRUE
                    Elseif Multikey(SC_UP) And Selected = i Then
                        Swap carte(i), carte(i - 1)
                        Swap cate(i), cate(i - 1)
                        Swap cat(i), cat(i - 1)
                        Swap cart(i), cart(i - 1)
                        JoyY = 0
                        JoyY_save = 0
                        JoyYN = 1
                        Selected = i - 1
                    End If
                Elseif i = size Then
                    If Multikey(SC_UP) And Selected = i Then
                        Swap carte(i), carte(i - 1)
                        Swap cate(i), cate(i - 1)
                        Swap cat(i), cat(i - 1)
                        Swap cart(i), cart(i - 1)
                        JoyY = 0
                        JoyY_save = 0
                        JoyYN = 1
                        Selected = i - 1
                    End If
                Elseif i = 1 Then
                    If Multikey(SC_DOWN) And selected = i And AlreadyUsed = FALSE Then
                        Swap carte(i), carte(i + 1)
                        Swap cate(i), cate(i + 1)
                        Swap cat(i), cat(i + 1)
                        Swap cart(i), cart(i + 1)
                        JoyY = 0
                        JoyY_save = 0
                        JoyYN = 1
                        Selected = i + 1
                        AlreadyUsed = TRUE
                    End If
                End If
            Next
        Else
            For i As Integer = 1 To size
                If i < size And i > 1 Then
                    If Multikey(SC_DOWN) And selected = i And AlreadyUsed = FALSE Then
                        Swap carte(i), carte(i + 1)
                        Swap cate(i), cate(i + 1)
                        Swap cat(i), cat(i + 1)
                        Swap cart(i), cart(i + 1)
                        Selected = i + 1
                        AlreadyUsed = TRUE
                    Elseif Multikey(SC_UP) And Selected = i Then
                        Swap carte(i), carte(i - 1)
                        Swap cate(i), cate(i - 1)
                        Swap cat(i), cat(i - 1)
                        Swap cart(i), cart(i - 1)
                        Selected = i - 1
                    End If
                Elseif i = size Then
                    If Multikey(SC_UP) And Selected = i Then
                        Swap carte(i), carte(i - 1)
                        Swap cate(i), cate(i - 1)
                        Swap cat(i), cat(i - 1)
                        Swap cart(i), cart(i - 1)
                        Selected = i - 1
                    End If
                Elseif i = 1 Then
                    If Multikey(SC_DOWN) And selected = i And AlreadyUsed = FALSE Then
                        Swap carte(i), carte(i + 1)
                        Swap cate(i), cate(i + 1)
                        Swap cat(i), cat(i + 1)
                        Swap cart(i), cart(i + 1)
                        Selected = i + 1
                        AlreadyUsed = TRUE
                    End If
                End If
            Next
        End If
        For i As Integer = Lbound(DispText) To size Step 1
            If Selected = i Then
                Locate SpotY(i), SpotX(i): Color waitfor: Print carte(i) & cate(i) & DispText(i) & cat(i) & cart(i)
            Else
                Color 255
                Locate SpotY(i), SpotX(i): Print carte(i) & cate(i) & DispText(i) & cat(i) & cart(i)
            End If
        Next
        For i As Integer = 1 To size
            If (JoyButtons = 2 Or Multikey(SC_SPACE)) And Selected = i Then
                Cls
                Return i
            End If
        Next
        Color 15: Locate 24, spot: Print SpaceAttackVersion
        If Multikey(SC_B) Then
            Bsave "Screenshots\" & scname & sc & ".bmp", 0
            sc = sc + 1
            SetReset
        End If
        Sleep 100, 1
    Loop
End Function
Sub SetReset
    Dim As Integer ff = Freefile
    Open set For Output As #ff
    Write #ff, spe, spes, timems, scname, sc, easy, NumOfStars, musicState
    Close #ff
End Sub
Sub HighScores(cheat As boolean = FALSE)
    Screen 17
    ClearBuffer
    Dim filenum As Integer = Freefile
    Dim player As String
    Input "Enter your name: " , player
    If Fileexists("highscores.txt") <> 0 Then
        Open "highscores.txt" For Append As #filenum
    Else
        Open "highscores.txt" For Output As #filenum
    End If
    Print #1, "HighScores file loaded."
    If cheat = TRUE Then
        Print #filenum, player & "          " & timed.full & " (CHEATED)"
    Else
        Print #filenum, player & "          " & timed.full
    End If
    Close
End Sub
Sub ClearBuffer
    Do
    Loop Until Inkey = ""
End Sub
