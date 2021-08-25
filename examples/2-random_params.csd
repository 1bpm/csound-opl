<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
/*
    csound-opl example 2
    Parametric instrument modification with randomisation

    Richard Knight 2021 : examples are licensed as public domain equivalent : http://unlicense.org/

*/

sr = 44100
kr = 4410
nchnls = 2
0dbfs = 1
seed 0 


instr main	
    ; synthesiser
    giopl, aL, aR opl
    outs aL, aR

    ; play a note each second
    kmetro metro 1
    schedkwhen kmetro, 0, 0, 2, 0, 1

    ; randomise instrument parameters, but always set as four operator
    iop1, iop2, iop3, iop4 oplinstrument giopl, int:k(random:k(0, 2)), int:k(random:k(0, 2)), random:k(0, 7), random:k(0, 7), 1, 1, int:k(random:k(0, 2)), int:k(random:k(0, 2))

    ; randomise all of the operators
    oploperator iop1, random:k(60, 63), random:k(0, 3), random:k(0, 15), random:k(0, 15), random:k(0, 15), random:k(0, 1), random:k(0, 7), 0, random:k(0, 2), random:k(0, 2), random:k(0, 2), random:k(0, 2)
    oploperator iop2, random:k(60, 63), random:k(0, 3), random:k(0, 15), random:k(0, 15), random:k(0, 15), random:k(0, 1), random:k(0, 7), 0, random:k(0, 2), random:k(0, 2), random:k(0, 2), random:k(0, 2)
    oploperator iop3, random:k(60, 63), random:k(0, 3), random:k(0, 15), random:k(0, 15), random:k(0, 15), random:k(0, 1), random:k(0, 7), 0, random:k(0, 2), random:k(0, 2), random:k(0, 2), random:k(0, 2)
    oploperator iop4, random:k(60, 63), random:k(0, 3), random:k(0, 15), random:k(0, 15), random:k(0, 15), random:k(0, 1), random:k(0, 7), 0, random:k(0, 2), random:k(0, 2), random:k(0, 2), random:k(0, 2)
endin


; play a random note from the array
instr 2
    inotes[] fillarray 48, 52, 53, 57
    inote = inotes[int(random(0, lenarray(inotes)-1))]+24
    oplnote giopl, 0, inote, 120
endin


</CsInstruments>
<CsScore>
i"main" 0 3600
</CsScore>
</CsoundSynthesizer>

