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
Declare function load() as integer
Declare Sub saver
Declare Sub errorscreen(a As Integer)
Declare Sub PutStars
Declare Sub PlaySound(param As Any Ptr)
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
Const set = "settings.config"
Print #1, "Joystick ID set"
Const JoyID = 0
Print #1, "Declaring saved variables"
Dim Shared As Integer musicState, spe, spes, timem, sc, easy, timems, NumOfStars
Dim As Integer filenum
Dim Shared As String scname
If Fileexists(set) = 0 Then
    filenum = Freefile
    Open set For Output As #filenum
    Write #filenum, 50, 25, 5, "sc", 1, 1, 75
    Close #filenum
End If
filenum = Freefile
Open set For Input As #filenum
Input #filenum, spe, spes, timems, scname, sc, easy, NumOfStars
Close #filenum
Print #1, "Saved settings loaded"
Windowtitle "SpaceAttack!"
Cls
Type shot
    shot2 As Integer
    shot3 As Integer
    shot4 As Integer
    shot5 As Integer
End Type
Type timeview
    m As Integer
    s As Integer
    max As Integer
    set As Integer
End Type
Type Coordinates
    x As Integer
    y As Integer
End Type
Dim Shared As Integer terminate = 0, JoyInit, spaces, vspaces, SoundInit, elives, lor, speed, filenumber, x, y, click, scroll, scrollsave, errors, JoyButtons, spaces_save, JoyButons_true, spot
Dim Shared As Single JoyX, JoyX_save
Dim Shared As shot c
Dim Shared As timeview timed
Dim Shared stars(1 To NumOfStars) As Coordinates
Screen 17
Print #1, "Sound file loading..."
If (BASS_Init(-1, 44100, 0, 0, 0) <> TRUE) Then
    Print #1, "Could not initialize audio! BASS returned error " & BASS_ErrorGetCode()
    Close
    End
End If
Dim Shared musicHandle As HSTREAM
musicHandle = BASS_StreamCreateFile(0, Strptr(background), 0, 0, BASS_Sample_Loop)
'Dim thread As Any Ptr = Threadcreate(@PlaySound, 0)
'dim shared as HSTREAM musicHandle = BASS_StreamCreateFile(FALSE, strptr("background.ogg"), 0, 0, 0)
'Dim shared As HMUSIC musicHandle = BASS_MusicLoad(0, Strptr(background), 0, 0, BASS_SAMPLE_LOOP, 0)
'                                                    FALSE, "afile.mp3", 0, 0, 0
'Dim Shared As HSTREAM musicHandle = BASS_StreamCreateFile(0, Strptr(background), 0, 0, 0)
'BASS_ChannelPlay(musicHandle, 0)
Print #1, """Music"" initialized..."
For i As Integer = 1 To NumOfStars
    stars(i).x = Cint(Rnd * 640)
    stars(i).y = Cint(Rnd * 400)
Next i
If Getjoystick(JoyID, JoyButtons) = 0 Then JoyInit = TRUE Else JoyInit = FALSE
startmenu
Sub define
    spaces = 15
    vspaces = 15
    elives = 10
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
Sub pause
    Sleep 200, 1
    Cls
    Print "Press S or Select to save game"
    Locate 13, 34: Print "Game is Paused"
    Do
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
            If(musicState) Then
                BASS_ChannelPlay(musicHandle, 0)
            Else
                BASS_ChannelPause(musicHandle)
            End If
            Sleep 100, 1
        End If
        If Multikey(SC_B) Then
            Bsave "Screenshots\" & scname & sc & ".bmp", 0
            sc = sc + 1
            Open set For Output As #filenumber
            Write #filenumber, spe, spes, timems, scname, sc
            Close #filenumber
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
    ff=Freefile
    Open set For Output As #ff
    Write #ff, spe, spes, timems, scname, sc, easy
    Close ff
    Cls
End Sub
Sub timesetter
    Cls
    Sleep 500, 1
    Getkey
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
    ff = Freefile
    Open set For Output As #ff
    Write #ff, spe, spes, timems, scname, sc, easy
    Close #ff
    timed.m = timems
End Sub
Sub scsetter
    Cls
    Sleep 500, 1
    Inkey
    Dim As Integer ff
    Dim save As String
    Dim yon As Integer
    ff = Freefile
    save = scname
    Input "Enter default screenshot name:" , scname
    If scname = save Then
        yon = 0
    Else
        yon = 1
    End If
    Open set For Output As #ff
    If yon = 1 Then sc = 1
    Write #ff, spe, spes, timems, scname, sc, easy
    Close #ff
End Sub
Sub eon
    Dim As String cat, cart
    Dim ff As Integer
    cat = "<"
    Do
        Cls
        If Multikey(SC_DOWN) Then
            Swap cat, cart
            Sleep 50, 1
        Elseif Multikey(SC_UP) Then
            Swap cat, cart
            Sleep 50, 1
        Elseif Multikey(SC_LEFT) Then
            Swap cat, cart
            Sleep 50, 1
        Elseif Multikey(SC_RIGHT) Then
            Swap cat, cart
            Sleep 50, 1
        End If
        Print "Set game to easy mode " & cat
        Print "Set game to hard mode " & cart
        Sleep 75, 1
    Loop Until Multikey(SC_SPACE)
    If cat = "<" Then
        easy = 1
    Elseif cart = "<" Then
        easy = 0
        timems = 10
    Else
        Close
        End
    End If
    ff = Freefile
    Open set For Output As #ff
    Write #ff, spe, spes, timems, scname, sc, easy
    Close #ff
End Sub
Sub main
    Color Rgb(255, 255, 255)
    Dim ship As Any Ptr = Imagecreate(16, 16)
    Print #1, "Player sprite allocated..."
    Dim bomb As Any Ptr = Imagecreate(16, 16)
    Print #1, "Bomb sprite allocated..."
    Dim eship As Any Ptr = Imagecreate(16, 16)
    Print #1, "Enemy sprite allocated..."
    Bload("bin\eship.spr", eship)
    Print #1, "Enemy sprite loaded..."
    Bload("bin\ship.spr", ship)
    Print #1, "Player sprite loaded..."
    Bload("bin\bomb.spr", bomb)
    Print #1, "Bomb sprite loaded..."
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
            System
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
        Print "Remaining Enemy Lives:" & elives
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
            Print "Time Left    " & timed.m & ":" & timed.s
        Elseif timed.s < 10 Then
            Print "Time Left    " & timed.m & ":0" & timed.s
        Else
            System
        End If
        If elives = 0 Then
            youwin
            System
        End If
        If c.shot5 = 1 And spaces = vspaces And vspaces < 39 And vspaces > 0 Then
            Print #1, "Left or right..."
            lor = Int(Rnd * 50) + 0
            If lor > 25 Then vspaces = vspaces + 1
            If lor < 25 Then vspaces = vspaces - 1
        Elseif c.shot5 = 1 And spaces = vspaces And vspaces = 39 Then
            vspaces = vspaces - 1
        Elseif c.shot5 = 1 And spaces = vspaces And vspaces = 0 Then
            vspaces = vspaces + 1
        End If
        If easy = 1 Then
            If spaces_save = spaces + 1 And vspaces < spaces And vspaces <> (spaces - 1) Then
                vspaces = vspaces + 1
                Put ((vspaces * 16), 32), eship
            Elseif spaces_save = spaces - 1 And vspaces > spaces And vspaces <> (spaces + 1) Then
                vspaces = vspaces - 1
                Put ((vspaces * 16), 32), eship
            Else
                Put ((vspaces * 16), 32), eship
            End If
        Elseif easy = 0 Then
            If spaces_save = spaces + 1 And vspaces < spaces And vspaces <> (spaces - 2) And vspaces <> (spaces - 1) Then
                vspaces = vspaces + 1
                Put ((vspaces * 16), 32), eship
            Elseif spaces_save = spaces - 1 And vspaces > spaces And vspaces <> (spaces + 2) And vspaces <> (spaces + 1) Then
                vspaces = vspaces - 1
                Put ((vspaces * 16), 32), eship
            Else
                Put ((vspaces * 16), 32), eship
            End If
        Else
            errorscreen(31)
        End If
        If c.shot5 = true Then
            Put ((spaces * 16), 46), bomb
            If vspaces = spaces Then
                elives = elives - 1
            End If
            c.shot5 = false
        End If
        If c.shot4 = true Then
            Put ((spaces * 16), 62), bomb
            c.shot4 = false
            c.shot5 = true
        End If
        If c.shot3 = true Then
            Put ((spaces * 16), 78), bomb
            c.shot3 = false
            c.shot4 = true
        End If
        If c.shot2 = true Then
            Put ((spaces * 16), 94), bomb
            c.shot2 = false
            c.shot3 = true
        End If
        If Multikey(SC_Q) Then
            Print #1, "Destroying sprite buffers"
            Imagedestroy(bomb)
            Imagedestroy(ship)
            Imagedestroy(eship)
            Print #1, "Destroying music buffer and unloading from memory."
            BASS_Free()
            Print #1, "Closing all files (including this one)...GOODBYE!"
            Close
            End
        End If
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
            Put ((spaces* 16), 110), bomb
            c.shot2 = true
        Elseif click = 1 Then
            Put ((spaces * 16), 110), bomb
            c.shot2 = true
        Elseif JoyButtons = 2 Then
            Put ((spaces * 16), 110), bomb
            c.shot2 = true
        End If
        Print #1, "Drawing player"
        Put ((spaces * 16), 128), ship
        Print #1, "Check for Screenshot"
        If Multikey(SC_B) Then
            Bsave "Screenshots\" & scname & sc & ".bmp", 0
            sc = sc + 1
            Open set For Output As #filenumber
            Write #filenumber, spe, spes, timems, scname, sc
            Close #filenumber
        End If
        Print #1, "Printing Version"
        Locate 24, spot: Print SpaceAttackVersion
        Sleep speed, 1
    Loop
End Sub
Sub youwin
    Print #1, "New screen"
    Screenres 320, 200, 32
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
    Close
End Sub
Sub youlose
    Print #1, "New Screen"
    Screenres 320, 200, 32
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
    Print #1, "Creating variables"
    Dim As String cat, cart, carte, cate
    Dim As String cat2, cart2, carte2, cate2
    Dim As String cat3, cart3, carte3, cate3
    Dim As String cat4, cart4, carte4, cate4
    Dim As Integer waitfor, JoyYN
    Dim As Single JoyY, JoyY_save
    'carte, cate, words, cat, cart
    Print #1, "Assigning Default Variable Value"
    carte = ">"
    cart = "<"
    cat = " "
    cate = " "
    carte2 = " "
    cart2 = " "
    cat2 = " "
    cate2 = " "
    carte3 = " "
    cart3 = " "
    cat3 = " "
    cate3 = " "
    carte4 = " "
    cart4 = " "
    cat4 = " "
    cate4 = " "
    Do
        Print #1, "Clearing Screen"
        Cls
        waitfor = waitfor + 1
        If JoyInit = TRUE And JoyYN = 0 Then
            JoyY_save = JoyY
            Getjoystick(JoyID, JoyButtons, , JoyY)
        Else
            JoyYN -= 1
        End If
        If waitfor = 6 Then waitfor = 1
        If waitfor = 5 And carte = ">" Or cate = ">" And waitfor = 5 Then
            Swap carte, cate
            Swap cat, cart
        Elseif waitfor = 5 And cate2 = ">" Or carte2 = ">" And waitfor = 5 Then
            Swap carte2, cate2
            Swap cat2, cart2
        Elseif waitfor = 5 And cate3 = ">" Or carte3 = ">" And waitfor = 5 Then
            Swap carte3, cate3
            Swap cart3, cat3
        Elseif waitfor = 5 And cate4 = ">" Or carte4 = ">" And waitfor = 5 Then
            Swap carte4, cate4
            Swap cart4, cat4
        End If
        'bigger is down + .2
        'lower is up - .2
        If (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And carte2 = ">" Or (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And cate2 = ">" Then
            Swap carte, carte2
            Swap cate, cate2
            Swap cat, cat2
            Swap cart, cart2
            JoyY = 0
            JoyY_save = 0
            JoyYN = 1
        Elseif (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And carte = ">" Or (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And cate = ">" Then
            Swap carte, carte2
            Swap cate, cate2
            Swap cat, cat2
            Swap cart, cart2
            JoyY = 0
            JoyY_save = 0
            JoyYN = 1
        Elseif (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And carte2 = ">" Or (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And cate2 = ">" Then
            Swap carte2, carte3
            Swap cate2, cate3
            Swap cat2, cat3
            Swap cart2, cart3
            JoyY = 0
            JoyY_save = 0
            JoyYN = 1
        Elseif (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And carte3 = ">" Or (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And cate3 = ">" Then
            Swap carte2, carte3
            Swap cate2, cate3
            Swap cat2, cat3
            Swap cart2, cart3
            JoyY = 0
            JoyY_save = 0
            JoyYN = 1
        Elseif (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And carte3 = ">" Or (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And cate3 = ">" Then
            Swap carte3, carte4
            Swap cate3, cate4
            Swap cat3, cat4
            Swap cart3, cart4
            JoyY = 0
            JoyY_save = 0
            JoyYN = 1
        Elseif (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And carte4 = ">" Or (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And cate4 = ">" Then
            Swap carte3, carte4
            Swap cate3, cate4
            Swap cat3, cat4
            Swap cart3, cart4
            JoyY = 0
            JoyY_save = 0
            JoyYN = 1
        End If
        If (JoyButtons = 2 Or Multikey(SC_SPACE)) And carte = ">" Or cate = ">" And (Multikey(SC_SPACE) Or JoyButtons = 2) Then
            define
            main
        Elseif (JoyButtons = 2 Or Multikey(SC_SPACE)) And carte2 = ">" Or cate2 = ">" And (Multikey(SC_SPACE) Or JoyButtons = 2) Then
            If load() = 0 Then
                main
            End If
        Elseif (JoyButtons = 2 Or Multikey(SC_SPACE)) And carte3 = ">" Or cate3 = ">" And (Multikey(SC_SPACE) Or JoyButtons = 2) Then
            options
        Elseif (JoyButtons = 2 Or Multikey(SC_SPACE)) And carte4 = ">" Or cate4 = ">" And (Multikey(SC_SPACE) Or JoyButtons = 2) Then
            Close
            BASS_free()
            End
        End If
        If carte = ">" Or cate = ">" Then
            Locate 12, 33: Color waitfor: Print carte & cate & "Start new game" & cat & cart
        Else
            Color 15
            Locate 12, 33: Print carte & cate & "Start new game" & cat & cart
        End If
        If carte2 = ">" Or cate2 = ">" Then
            Locate 13, 35: Color waitfor: Print carte2 & cate2 & "Load Game" & cat2 & cart2
        Else
            Color 15
            Locate 13, 35: Print carte2 & cate2 & "Load Game" & cat2 & cart2
        End If
        If carte3 = ">" Or cate3 = ">" Then
            Locate 14, 36: Color waitfor: Print carte3 & cate3 & "Options" & cat3 & cart3
        Else
            Color 15
            Locate 14, 36: Print carte3 & cate3 & "Options" & cat3 & cart3
        End If
        If carte4 = ">" Or cate4 = ">" Then
            Locate 15, 35: Color waitfor: Print carte4 & cate4 & "Exit Game" & cat4 & cart4
        Else
            Color 15
            Locate 15, 35: Print carte4 & cate4 & "Exit Game" & cat4 & cart4
        End If
        Color 15: Locate 24, spot: Print SpaceAttackVersion
        If Multikey(SC_B) Then
            Bsave "Screenshots\" & scname & sc & ".bmp", 0
            sc = sc + 1
            Open set For Output As #filenumber
            Write #filenumber, spe, spes, timems, scname, sc
            Close #filenumber
        End If
        Sleep 100, 1
    Loop
End Sub
Sub options
    Dim As String cat, cart, carte, cate
    Dim As String cat2, cart2, carte2, cate2
    Dim As String cat3, cart3, carte3, cate3
    Dim As String cat4, cart4, carte4, cate4
    Dim As String cat5, cart5, carte5, cate5
    Dim As Integer waitfor, JoyYN
    Dim As Single JoyY, JoyY_save
    'carte, cate, words, cat, cart
    carte = ">"
    cart = "<"
    cat = " "
    cate = " "
    carte2 = " "
    cart2 = " "
    cat2 = " "
    cate2 = " "
    carte3 = " "
    cart3 = " "
    cat3 = " "
    cate3 = " "
    carte4 = " "
    cart4 = " "
    cat4 = " "
    cate4 = " "
    carte5 = " "
    cart5 = " "
    cat5 = " "
    cate5 = " "
    Sleep 500, 1
    Do
        Cls
        waitfor = waitfor + 1
        If JoyInit = TRUE And JoyYN = 0 Then
            JoyY_save = JoyY
            Getjoystick(JoyID, JoyButtons, , JoyY)
        Else
            JoyYN -= 1
        End If
        If waitfor = 6 Then waitfor = 1
        If waitfor = 5 And carte = ">" Or cate = ">" And waitfor = 5 Then
            Swap carte, cate
            Swap cat, cart
        Elseif waitfor = 5 And cate2 = ">" Or carte2 = ">" And waitfor = 5 Then
            Swap carte2, cate2
            Swap cat2, cart2
        Elseif waitfor = 5 And cate3 = ">" Or carte3 = ">" And waitfor = 5 Then
            Swap carte3, cate3
            Swap cart3, cat3
        Elseif waitfor = 5 And cate4 = ">" Or carte4 = ">" And waitfor = 5 Then
            Swap carte4, cate4
            Swap cart4, cat4
        Elseif waitfor = 5 And cate5 = ">" Or carte5 = ">" And waitfor = 5 Then
            Swap carte5, cate5
            Swap cart5, cat5
        End If
        If (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And carte2 = ">" Or (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And cate2 = ">" Then
            Swap carte, carte2
            Swap cate, cate2
            Swap cat, cat2
            Swap cart, cart2
            JoyY_save = 0
            JoyY = 0
            JoyYN = 1
        Elseif (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And carte = ">" Or (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And cate = ">" Then
            Swap carte, carte2
            Swap cate, cate2
            Swap cat, cat2
            Swap cart, cart2
            JoyY_save = 0
            JoyY = 0
            JoyYN = 1
        Elseif (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And carte2 = ">" Or (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And cate2 = ">" Then
            Swap carte2, carte3
            Swap cate2, cate3
            Swap cat2, cat3
            Swap cart2, cart3
            JoyY_save = 0
            JoyY = 0
            JoyYN = 1
        Elseif (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And carte3 = ">" Or (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And cate3 = ">" Then
            Swap carte2, carte3
            Swap cate2, cate3
            Swap cat2, cat3
            Swap cart2, cart3
            JoyY_save = 0
            JoyY = 0
            JoyYN = 1
        Elseif (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And carte3 = ">" Or (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And cate3 = ">" Then
            Swap carte3, carte4
            Swap cate3, cate4
            Swap cat3, cat4
            Swap cart3, cart4
            JoyY_save = 0
            JoyY = 0
            JoyYN = 1
        Elseif (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And carte4 = ">" Or (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And cate4 = ">" Then
            Swap carte3, carte4
            Swap cate3, cate4
            Swap cat3, cat4
            Swap cart3, cart4
            JoyY_save = 0
            JoyY = 0
            JoyYN = 1
        Elseif (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And carte4 = ">" Or (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And cate4 = ">" Then
            Swap carte4, carte5
            Swap cate4, cate5
            Swap cat4, cat5
            Swap cart4, cart5
            JoyY_save = 0
            JoyY = 0
            JoyYN = 1
        Elseif (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And carte5 = ">" Or (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And cate5 = ">" Then
            Swap carte4, carte5
            Swap cate4, cate5
            Swap cat4, cat5
            Swap cart4, cart5
            JoyY_save = 0
            JoyY = 0
            JoyYN = 1
        End If
        If Multikey(SC_ESCAPE) Or JoyButtons = 512 Then Exit Sub
        If (Multikey(SC_SPACE) Or JoyButtons = 2) And carte = ">" Or cate = ">" And (Multikey(SC_SPACE) Or JoyButtons = 2) Then timesetter
        If (Multikey(SC_SPACE) Or JoyButtons = 2) And carte2 = ">" Or cate2 = ">" And (Multikey(SC_SPACE) Or JoyButtons = 2) Then eon
        If (Multikey(SC_SPACE) Or JoyButtons = 2) And carte3 = ">" Or cate3 = ">" And (Multikey(SC_SPACE) Or JoyButtons = 2) Then speedset
        If (Multikey(SC_SPACE) Or JoyButtons = 2) And carte4 = ">" Or cate4 = ">" And (Multikey(SC_SPACE) Or JoyButtons = 2) Then scsetter
        If (Multikey(SC_SPACE) Or JoyButtons = 2) And carte5 = ">" Or cate5 = ">" And (Multikey(SC_SPACE) Or JoyButtons = 2) Then
            Sleep 200, 1
            Exit Sub
        End If
        If carte = ">" Or cate = ">" Then
            Locate 12, 35: Color waitfor: Print carte & cate & "Change Time" & cat & cart
        Else
            Color 15
            Locate 12, 35: Print carte & cate & "Change Time" & cat & cart
        End If
        If carte2 = ">" Or cate2 = ">" Then
            Locate 13, 35: Color waitfor: Print carte2 & cate2 & "Change Mode" & cat2 & cart2
        Else
            Color 15
            Locate 13, 35: Print carte2 & cate2 & "Change Mode" & cat2 & cart2
        End If
        If carte3 = ">" Or cate3 = ">" Then
            Locate 14, 34: Color waitfor: Print carte3 & cate3 & "Change Speed" & cat3 & cart3
        Else
            Color 15
            Locate 14, 34: Print carte3 & cate3 & "Change Speed" & cat3 & cart3
        End If
        If carte4 = ">" Or cate4 = ">" Then
            Locate 15, 27: Color waitfor: Print carte4 & cate4 & "Change Default Screenshot Name" & cat4 & cart4
        Else
            Color 15
            Locate 15, 27: Print carte4 & cate4 & "Change Default Screenshot Name" & cat4 & cart4
        End If
        If carte5 = ">" Or cate5 = ">" Then
            Locate 16, 32: Color waitfor: Print carte5 & cate5 & "Back to Main Menu" & cat5 & cart5
        Else
            Color 15
            Locate 16, 32: Print carte5 & cate5 & "Back to Main Menu" & cat5 & cart5
        End If
        If Multikey(SC_B) Then
            Bsave "Screenshots\" & scname & sc & ".bmp", 0
            sc = sc + 1
            Open set For Output As #filenumber
            Write #filenumber, spe, spes, timems, scname, sc
            Close #filenumber
        End If
        Sleep 100, 1
    Loop
End Sub
Function load() As Integer
    Dim file As Integer = Freefile
    Dim SaveFile As String
    Dim As String cat, cart, carte, cate
    Dim As String cat2, cart2, carte2, cate2
    Dim As String cat3, cart3, carte3, cate3
    Dim As String cat4, cart4, carte4, cate4
    Dim As Integer waitfor, JoyYN
    Dim As Single JoyY, JoyY_save
    'carte, cate, words, cat, cart
    Print #1, "Assigning Default Variable Value"
    carte = ">"
    cart = "<"
    cat = " "
    cate = " "
    carte2 = " "
    cart2 = " "
    cat2 = " "
    cate2 = " "
    carte3 = " "
    cart3 = " "
    cat3 = " "
    cate3 = " "
    carte4 = " "
    cart4 = " "
    cat4 = " "
    cate4 = " "
    Do
        Print #1, "Clearing Screen"
        Cls
        print "Pick slot to load."
        waitfor = waitfor + 1
        If JoyInit = TRUE And JoyYN = 0 Then
            JoyY_save = JoyY
            Getjoystick(JoyID, JoyButtons, , JoyY)
        Else
            JoyYN -= 1
        End If
        If waitfor = 6 Then waitfor = 1
        If waitfor = 5 And carte = ">" Or cate = ">" And waitfor = 5 Then
            Swap carte, cate
            Swap cat, cart
        Elseif waitfor = 5 And cate2 = ">" Or carte2 = ">" And waitfor = 5 Then
            Swap carte2, cate2
            Swap cat2, cart2
        Elseif waitfor = 5 And cate3 = ">" Or carte3 = ">" And waitfor = 5 Then
            Swap carte3, cate3
            Swap cart3, cat3
        Elseif waitfor = 5 And cate4 = ">" Or carte4 = ">" And waitfor = 5 Then
            Swap carte4, cate4
            Swap cart4, cat4
        End If
        'bigger is down + .2
        'lower is up - .2
        If (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And carte2 = ">" Or (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And cate2 = ">" Then
            Swap carte, carte2
            Swap cate, cate2
            Swap cat, cat2
            Swap cart, cart2
            JoyY = 0
            JoyY_save = 0
            JoyYN = 1
        Elseif (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And carte = ">" Or (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And cate = ">" Then
            Swap carte, carte2
            Swap cate, cate2
            Swap cat, cat2
            Swap cart, cart2
            JoyY = 0
            JoyY_save = 0
            JoyYN = 1
        Elseif (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And carte2 = ">" Or (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And cate2 = ">" Then
            Swap carte2, carte3
            Swap cate2, cate3
            Swap cat2, cat3
            Swap cart2, cart3
            JoyY = 0
            JoyY_save = 0
            JoyYN = 1
        Elseif (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And carte3 = ">" Or (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And cate3 = ">" Then
            Swap carte2, carte3
            Swap cate2, cate3
            Swap cat2, cat3
            Swap cart2, cart3
            JoyY = 0
            JoyY_save = 0
            JoyYN = 1
        Elseif (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And carte3 = ">" Or (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And cate3 = ">" Then
            Swap carte3, carte4
            Swap cate3, cate4
            Swap cat3, cat4
            Swap cart3, cart4
            JoyY = 0
            JoyY_save = 0
            JoyYN = 1
        Elseif (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And carte4 = ">" Or (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And cate4 = ">" Then
            Swap carte3, carte4
            Swap cate3, cate4
            Swap cat3, cat4
            Swap cart3, cart4
            JoyY = 0
            JoyY_save = 0
            JoyYN = 1
        End If
        If (JoyButtons = 2 Or Multikey(SC_SPACE)) And carte = ">" Or cate = ">" And (Multikey(SC_SPACE) Or JoyButtons = 2) Then
            SaveFile="saves\slot1.sav"
        Elseif (JoyButtons = 2 Or Multikey(SC_SPACE)) And carte2 = ">" Or cate2 = ">" And (Multikey(SC_SPACE) Or JoyButtons = 2) Then
            SaveFile="saves\slot2.sav"
        Elseif (JoyButtons = 2 Or Multikey(SC_SPACE)) And carte3 = ">" Or cate3 = ">" And (Multikey(SC_SPACE) Or JoyButtons = 2) Then
            SaveFile="saves\slot3.sav"
        Elseif (JoyButtons = 2 Or Multikey(SC_SPACE)) And carte4 = ">" Or cate4 = ">" And (Multikey(SC_SPACE) Or JoyButtons = 2) Then
            SaveFile="saves\slot4.sav"
        End If
        If carte = ">" Or cate = ">" Then
            Locate 12, 33: Color waitfor: Print carte & cate & "Slot 1" & cat & cart
        Else
            Color 15
            Locate 12, 33: Print carte & cate & "Slot 1" & cat & cart
        End If
        If carte2 = ">" Or cate2 = ">" Then
            Locate 13, 35: Color waitfor: Print carte2 & cate2 & "Slot 2" & cat2 & cart2
        Else
            Color 15
            Locate 13, 33: Print carte2 & cate2 & "Slot 2" & cat2 & cart2
        End If
        If carte3 = ">" Or cate3 = ">" Then
            Locate 14, 33: Color waitfor: Print carte3 & cate3 & "Slot 3" & cat3 & cart3
        Else
            Color 15
            Locate 14, 33: Print carte3 & cate3 & "Slot 3" & cat3 & cart3
        End If
        If carte4 = ">" Or cate4 = ">" Then
            Locate 15, 35: Color waitfor: Print carte4 & cate4 & "Slot 4" & cat4 & cart4
        Else
            Color 15
            Locate 15, 35: Print carte4 & cate4 & "Slot 4" & cat4 & cart4
        End If
        Color 15: Locate 24, spot: Print SpaceAttackVersion
        If Multikey(SC_B) Then
            Bsave "Screenshots\" & scname & sc & ".bmp", 0
            sc = sc + 1
            Open set For Output As #filenumber
            Write #filenumber, spe, spes, timems, scname, sc
            Close #filenumber
        End If
        Sleep 100, 1
    Loop
    If Fileexists(SaveFile) <> 0 Then
        Open SaveFile For Input As #file
        Input #file, spaces, vspaces, elives, lor, timed.set, timed.s, timed.m, speed, filenumber, timed.max, click, scroll, scrollsave, c.shot2, c.shot3, c.shot4, c.shot5
        return 0
    Else
        Print "Slot " & Mid(SaveFile, 11, 1) & " doesn't exist!"
        Sleep 500, 1
        Return 1
    End If
End Function
Sub saver
    Dim file As Integer = Freefile
    Dim SaveFile As String
    Dim OverWrite As String
    Print #1, "Creating variables"
    Dim As String cat, cart, carte, cate
    Dim As String cat2, cart2, carte2, cate2
    Dim As String cat3, cart3, carte3, cate3
    Dim As String cat4, cart4, carte4, cate4
    Dim As Integer waitfor, JoyYN
    Dim As Single JoyY, JoyY_save
    'carte, cate, words, cat, cart
    Print #1, "Assigning Default Variable Value"
    carte = ">"
    cart = "<"
    cat = " "
    cate = " "
    carte2 = " "
    cart2 = " "
    cat2 = " "
    cate2 = " "
    carte3 = " "
    cart3 = " "
    cat3 = " "
    cate3 = " "
    carte4 = " "
    cart4 = " "
    cat4 = " "
    cate4 = " "
    Do
        Print #1, "Clearing Screen"
        Cls
        locate 30, 1: print "Select slot to save in."
        waitfor = waitfor + 1
        If JoyInit = TRUE And JoyYN = 0 Then
            JoyY_save = JoyY
            Getjoystick(JoyID, JoyButtons, , JoyY)
        Else
            JoyYN -= 1
        End If
        If waitfor = 6 Then waitfor = 1
        If waitfor = 5 And carte = ">" Or cate = ">" And waitfor = 5 Then
            Swap carte, cate
            Swap cat, cart
        Elseif waitfor = 5 And cate2 = ">" Or carte2 = ">" And waitfor = 5 Then
            Swap carte2, cate2
            Swap cat2, cart2
        Elseif waitfor = 5 And cate3 = ">" Or carte3 = ">" And waitfor = 5 Then
            Swap carte3, cate3
            Swap cart3, cat3
        Elseif waitfor = 5 And cate4 = ">" Or carte4 = ">" And waitfor = 5 Then
            Swap carte4, cate4
            Swap cart4, cat4
        End If
        'bigger is down + .2
        'lower is up - .2
        If (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And carte2 = ">" Or (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And cate2 = ">" Then
            Swap carte, carte2
            Swap cate, cate2
            Swap cat, cat2
            Swap cart, cart2
            JoyY = 0
            JoyY_save = 0
            JoyYN = 1
        Elseif (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And carte = ">" Or (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And cate = ">" Then
            Swap carte, carte2
            Swap cate, cate2
            Swap cat, cat2
            Swap cart, cart2
            JoyY = 0
            JoyY_save = 0
            JoyYN = 1
        Elseif (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And carte2 = ">" Or (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And cate2 = ">" Then
            Swap carte2, carte3
            Swap cate2, cate3
            Swap cat2, cat3
            Swap cart2, cart3
            JoyY = 0
            JoyY_save = 0
            JoyYN = 1
        Elseif (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And carte3 = ">" Or (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And cate3 = ">" Then
            Swap carte2, carte3
            Swap cate2, cate3
            Swap cat2, cat3
            Swap cart2, cart3
            JoyY = 0
            JoyY_save = 0
            JoyYN = 1
        Elseif (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And carte3 = ">" Or (Multikey(SC_DOWN) Or JoyY_save <= JoyY - .2) And cate3 = ">" Then
            Swap carte3, carte4
            Swap cate3, cate4
            Swap cat3, cat4
            Swap cart3, cart4
            JoyY = 0
            JoyY_save = 0
            JoyYN = 1
        Elseif (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And carte4 = ">" Or (Multikey(SC_UP) Or JoyY_save >= JoyY + .2) And cate4 = ">" Then
            Swap carte3, carte4
            Swap cate3, cate4
            Swap cat3, cat4
            Swap cart3, cart4
            JoyY = 0
            JoyY_save = 0
            JoyYN = 1
        End If
        If (JoyButtons = 2 Or Multikey(SC_SPACE)) And carte = ">" Or cate = ">" And (Multikey(SC_SPACE) Or JoyButtons = 2) Then
            SaveFile="saves\slot1.sav"
            exit do
        Elseif (JoyButtons = 2 Or Multikey(SC_SPACE)) And carte2 = ">" Or cate2 = ">" And (Multikey(SC_SPACE) Or JoyButtons = 2) Then
            SaveFile="saves\slot2.sav"
            exit do
        Elseif (JoyButtons = 2 Or Multikey(SC_SPACE)) And carte3 = ">" Or cate3 = ">" And (Multikey(SC_SPACE) Or JoyButtons = 2) Then
            SaveFile="saves\slot3.sav"
            exit do
        Elseif (JoyButtons = 2 Or Multikey(SC_SPACE)) And carte4 = ">" Or cate4 = ">" And (Multikey(SC_SPACE) Or JoyButtons = 2) Then
            SaveFile="saves\slot4.sav"
        End If
        If carte = ">" Or cate = ">" Then
            Locate 12, 33: Color waitfor: Print carte & cate & "Slot 1" & cat & cart
        Else
            Color 31
            Locate 12, 33: Print carte & cate & "Slot 1" & cat & cart
        End If
        If carte2 = ">" Or cate2 = ">" Then
            Locate 13, 35: Color waitfor: Print carte2 & cate2 & "Slot 2" & cat2 & cart2
        Else
            Color 15
            Locate 13, 33: Print carte2 & cate2 & "Slot 2" & cat2 & cart2
        End If
        If carte3 = ">" Or cate3 = ">" Then
            Locate 14, 33: Color waitfor: Print carte3 & cate3 & "Slot 3" & cat3 & cart3
        Else
            Color 15
            Locate 14, 33: Print carte3 & cate3 & "Slot 3" & cat3 & cart3
        End If
        If carte4 = ">" Or cate4 = ">" Then
            Locate 15, 35: Color waitfor: Print carte4 & cate4 & "Slot 4" & cat4 & cart4
        Else
            Color 15
            Locate 15, 35: Print carte4 & cate4 & "Slot 4" & cat4 & cart4
        End If
        Color 15: Locate 24, spot: Print SpaceAttackVersion
        If Multikey(SC_B) Then
            Bsave "Screenshots\" & scname & sc & ".bmp", 0
            sc = sc + 1
            Open set For Output As #filenumber
            Write #filenumber, spe, spes, timems, scname, sc
            Close #filenumber
        End If
        Sleep 100, 1
    Loop
    If Fileexists(SaveFile) <> 0 Then
        Do
            Cls
            Print "Are you sure? Slot" & Mid(SaveFile, 11, 1) & " will be overwritten![Y|N]"
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
    Print "Error! Error! (" & errors & ")"
    Print #1, "Aborting due to error" & errors & "!"
    Sleep 5000, 1
    Close
    End
End Sub
Sub PutStars
    For i As Integer = 1 To NumOfStars
        Pset(stars(i).x, stars(i).y)
        stars(i).y += 1
        If stars(i).y = 401 Then stars(i).y = 0
    Next i
End Sub
