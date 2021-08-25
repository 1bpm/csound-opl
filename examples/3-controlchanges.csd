<CsoundSynthesizer>
<CsOptions>
-odac -m0
</CsOptions>
<CsInstruments>
/*
    csound-opl example 3
    Control change, pitch bend, bank change and patch change with randomly selected patches

    Richard Knight 2021 : examples are licensed as public domain equivalent : http://unlicense.org/
*/

sr = 44100
kr = 4410
nchnls	= 2
0dbfs = 1
seed 0 

; do bank changes: causes device reset which will stop current notes/possibly cause clicks but demonstrates nonetheless
gichangebank = 0
gistartbank = 0


; loop through each bank and play a note or two for each
instr main	
    giopl, aL, aR opl
    outs aL, aR
    gSbanks[] oplbanknames giopl
    
    itime = 0
    inote = 0
    inotes[] fillarray 50, 52, 64, 56, 53, 59, 62 
    while (gistartbank < lenarray(gSbanks)) do
        event_i "i", "play", itime, 2, gistartbank, inotes[inote], 0
        if (inote < lenarray(inotes)-1) then
            inote += 1
        else
            inote = 0
        endif
        if (random(0, 1) > 0.5) then
            event_i "i", "play", itime+0.5, 0.5, gistartbank, inotes[inote], 1
        endif
        itime += 1
        gistartbank += 1
    od
    p3 = itime
endin


; set the patch, play the note, optionally set the bank and call the control change instrument
instr play
    ibank = p4
    inote = p5
    ichannel = p6
    ipatch random 0, 127
    if (ichannel == 0 && gichangebank = 1) then
	prints sprintf("%d-%d (%s)\n", ibank, ipatch, gSbanks[ibank])    
        oplsetbank giopl, ibank
    endif
    oplpatchchange giopl, ichannel, ipatch
    oplnote giopl, ichannel, inote, 100
    event_i "i", "cc", p3*0.5, p3*0.5, ichannel
endin


; conditionally add a pitch bend and control change
instr cc
    ichannel = p4
    if (random(0, 1) > 0.6) then
        ibend = (random(0, 1) > 0.5) ? 1 : -1
        kbend linseg 0, p3*0.7, 0, p3*0.29, ibend, p3*0.01, 0
        oplpitchbend giopl, ichannel, kbend
    endif

    ; control change for type 1 (modulation)
    if (random(0, 1) > 0.4) then
        kmod linseg 0, p3*0.7, 255, p3*0.3, 0
        oplcontrolchange giopl, ichannel, 1, kmod
    endif
endin


</CsInstruments>
<CsScore>
i"main" 0 3600
</CsScore>
</CsoundSynthesizer>

