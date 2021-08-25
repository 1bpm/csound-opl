<CsoundSynthesizer>
<CsOptions>
-odac
-+rtmidi=virtual -M0
-m0
</CsOptions>
<CsInstruments>
/*
    csound-opl example 0
    FLTK gui for instrument editing

    Richard Knight 2021 : examples are licensed as public domain equivalent : http://unlicense.org/

*/

sr = 44100
kr = 4410
nchnls = 2
0dbfs = 1
seed 0 

; operator parameters and handles
gkop[][] init 4, 12
giop[][] init 4, 12

; global instrument parameters and handles
gkinstr[] init 8
giinstr[] init 8

; GUI spacing variables
giopwidth = 200
gidiv = 60


; FLTK GUI objects for an operator
opcode operator, 0, i
    iop xin
    ix = giopwidth * iop
    iy = 0
    ihl FLbox sprintf("OP%d", iop+1), 1, 2, 14, giopwidth, 30, ix, iy
    gkop[iop][0], giop[iop][0] FLslider "Level", 0, 63, 0, 1, -1, giopwidth, 30, ix, iy+(gidiv*1)
    gkop[iop][1], giop[iop][1] FLslider "Key scale", 0, 3, 0, 1, -1, giopwidth, 30, ix, iy+(gidiv*2)
    gkop[iop][2], giop[iop][2] FLslider "Attack", 0, 15, 0, 1, -1, giopwidth, 30, ix, iy+(gidiv*3)
    gkop[iop][3], giop[iop][3] FLslider "Decay", 0, 15, 0, 1, -1, giopwidth, 30, ix, iy+(gidiv*4)
    gkop[iop][4], giop[iop][4] FLslider "Sustain", 0, 15, 0, 1, -1, giopwidth, 30, ix, iy+(gidiv*5)
    gkop[iop][5], giop[iop][5] FLslider "Release", 0, 15, 0, 1, -1, giopwidth, 30, ix, iy+(gidiv*6)
    gkop[iop][6], giop[iop][6] FLslider "Waveform", 0, 7, 0, 1, -1, giopwidth, 30, ix, iy+(gidiv*7)      ;; TODO have as scrollbox/text
    gkop[iop][7], giop[iop][7] FLslider "Frequency multiplier", 0, 15, 0, 1, -1, giopwidth, 30, ix, iy+(gidiv*8)
    gkop[iop][8], giop[iop][8] FLbutton "Tremolo", 1, 0, 3, giopwidth/2, 30, ix, iy+(gidiv*9), -1
    gkop[iop][9], giop[iop][9] FLbutton "Vibrato", 1, 0, 3, giopwidth/2, 30, ix+(giopwidth/2), iy+(gidiv*9), -1
    gkop[iop][10], giop[iop][10] FLbutton "Sustaining", 1, 0, 3, giopwidth/2, 30, ix, iy+(gidiv*9.5), -1
    gkop[iop][11], giop[iop][11] FLbutton "Key env", 1, 0, 3, giopwidth/2, 30, ix+(giopwidth/2), iy+(gidiv*9.5), -1

endop


; run the GUI
instr gui
    FLpanel "OPL3", 1000, 768

        ; operator columns
        operator 0
        operator 1
        operator 2
        operator 3

        ; global column
        ix = 800
        iy = 0
        ihl FLbox "Globals", 1, 2, 14, giopwidth, 30, ix, iy
        gkinstr[0], giinstr[0] FLbutton "Mode 1/2 AM", 1, 0, 3, giopwidth/2, 30, ix, iy+(gidiv), -1
        gkinstr[1], giinstr[1] FLbutton "Mode 3/4 AM", 1, 0, 3, giopwidth/2, 30, ix+(giopwidth/2), iy+(gidiv), -1
        gkinstr[2], giinstr[2] FLslider "Feedback 1/2", 0, 7, 0, 1, -1, giopwidth, 30, ix, iy+(gidiv*2)
        gkinstr[3], giinstr[3] FLslider "Feedback 3/4", 0, 7, 0, 1, -1, giopwidth, 30, ix, iy+(gidiv*3)
        gkinstr[4], giinstr[4] FLbutton "4OP", 1, 0, 3, giopwidth/2, 30, ix, iy+(gidiv*4), 0, nstrnum("fouroptrig"), 0, 1
        gkinstr[5], giinstr[5] FLbutton "Pseudo 4OP", 1, 0, 3, giopwidth/2, 30, ix+(giopwidth/2), iy+(gidiv*4), 0, nstrnum("fouroptrig"), 0, 1
        gkinstr[6], giinstr[6] FLbutton "Deep vib", 1, 0, 3, giopwidth/2, 30, ix, iy+(gidiv*4.5), -1
        gkinstr[7], giinstr[7] FLbutton "Deep trem", 1, 0, 3, giopwidth/2, 30, ix+(giopwidth/2), iy+(gidiv*4.5), -1
        knull0, inull0 FLbutton "Randomise", 1, 0, 1, giopwidth, 30, ix, iy+(gidiv*5), 0, nstrnum("randomiser"), 0, 1
        knull1, inull1 FLbutton "Panic", 1, 0, 1, giopwidth, 30, ix, iy+(gidiv*6), 0, nstrnum("panic"), 0, 1
    FLpanelEnd
    FLrun

    ; initially, hide the last two operators (ie non four-operator mode)
    event_i "i", "fouropset", 0, 1, 0
endin


; audio processing
instr main	

    ; the synthesiser
    giopl, aL, aR opl
    outs aL, aR

    ; get operator handles and set the global instrument parameters from the FLTK widgets
    iop1, iop2, iop3, iop4 oplinstrument giopl, gkinstr[0], gkinstr[1], gkinstr[2], gkinstr[3], gkinstr[4], gkinstr[5], gkinstr[6], gkinstr[7]

    ; set the operator parameters from the FLTK widgets
    oploperator iop1, gkop[0][0], gkop[0][1], gkop[0][2], gkop[0][3], gkop[0][4], gkop[0][5], gkop[0][6], gkop[0][7], gkop[0][8], gkop[0][9], gkop[0][10], gkop[0][11]
    oploperator iop2, gkop[1][0], gkop[1][1], gkop[1][2], gkop[1][3], gkop[1][4], gkop[1][5], gkop[1][6], gkop[1][7], gkop[1][8], gkop[1][9], gkop[1][10], gkop[1][11]
    oploperator iop3, gkop[2][0], gkop[2][1], gkop[2][2], gkop[2][3], gkop[2][4], gkop[2][5], gkop[2][6], gkop[2][7], gkop[2][8], gkop[2][9], gkop[2][10], gkop[2][11]
    oploperator iop4, gkop[3][0], gkop[3][1], gkop[3][2], gkop[3][3], gkop[3][4], gkop[3][5], gkop[3][6], gkop[3][7], gkop[3][8], gkop[3][9], gkop[3][10], gkop[3][11]

endin


; respond to realtime MIDI input accordingly
instr 1
    inote notnum
    iveloc veloc
    oplnote giopl, 0, inote, iveloc
endin


; panic: reset the opl instance
instr panic
    oplpanic giopl
endin


; to be called when the '4OP' or 'Pseudo 4OP' buttons are pressed
instr fouroptrig
    ; elicit the state and call the set instrument
    kstate = 0
    if (gkinstr[4] == 1 || gkinstr[5] == 1) then
        kstate = 1
    endif
    event "i", "fouropset", 0, 1, kstate
    turnoff
endin


; show/hide the last two operators depending on the value of p4
instr fouropset
    istate = p4
    iop = 2
    while (iop <= 3) do
        idx = 0
        while (idx < 12) do
            ihandle = giop[iop][idx]
            if (istate == 0) then
                FLhide ihandle
            else
                FLshow ihandle
            endif
            idx += 1
        od
        iop += 1
    od
endin


; randomise slider values. NB does not actually work for the check boxes but they are still in here
instr randomiser
    iop = 0
    while (iop < 4) do
        FLsetVal_i random(30, 63), giop[iop][0]
        FLsetVal_i random(0, 3), giop[iop][1]
        FLsetVal_i random(0, 15), giop[iop][2]
        FLsetVal_i random(0, 15), giop[iop][3]
        FLsetVal_i random(0, 15), giop[iop][4]
        FLsetVal_i random(0, 15), giop[iop][5]
        FLsetVal_i random(0, 7), giop[iop][6]
        FLsetVal_i random(0, 15), giop[iop][7]
        FLsetVal_i random(0, 1), giop[iop][8]
        FLsetVal_i random(0, 1), giop[iop][9]
        FLsetVal_i random(0, 1), giop[iop][10]
        FLsetVal_i random(0, 1), giop[iop][11]
        iop += 1
    od
    FLsetVal_i random(0, 7), giinstr[2]
    FLsetVal_i random(0, 7), giinstr[3]
    turnoff
endin



</CsInstruments>
; ==============================================
<CsScore>
i"main" 0 3600
i"gui" 0 3600
</CsScore>
</CsoundSynthesizer>

