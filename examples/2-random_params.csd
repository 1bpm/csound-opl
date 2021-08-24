<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
; ==============================================
<CsInstruments>

sr	=	44100
kr = 4410
nchnls	=	2
0dbfs	=	1
seed 0 


instr main	
    giopl, aL, aR opl 0
    outs aL, aR

    kmetro metro 1
    schedkwhen kmetro, 0, 0, 2, 0, 1

    iop1, iop2, iop3, iop4 oplinstrument giopl, int:k(random:k(0, 2)), int:k(random:k(0, 2)), random:k(0, 7), random:k(0, 7), 1, 1, int:k(random:k(0, 2)), int:k(random:k(0, 2))


    ; level, keyscale, attack, decay
    kattack init 2
    kdecay init 13
;0 -15 freq mult
    oploperator iop1, random:k(60, 63), random:k(0, 3), random:k(0, 15), random:k(0, 15), random:k(0, 15), random:k(0, 1), random:k(0, 7), 0, random:k(0, 2), random:k(0, 2), random:k(0, 2), random:k(0, 2)
    oploperator iop2, random:k(60, 63), random:k(0, 3), random:k(0, 15), random:k(0, 15), random:k(0, 15), random:k(0, 1), random:k(0, 7), 0, random:k(0, 2), random:k(0, 2), random:k(0, 2), random:k(0, 2)
    oploperator iop3, random:k(60, 63), random:k(0, 3), random:k(0, 15), random:k(0, 15), random:k(0, 15), random:k(0, 1), random:k(0, 7), 0, random:k(0, 2), random:k(0, 2), random:k(0, 2), random:k(0, 2)
    oploperator iop4, random:k(60, 63), random:k(0, 3), random:k(0, 15), random:k(0, 15), random:k(0, 15), random:k(0, 1), random:k(0, 7), 0, random:k(0, 2), random:k(0, 2), random:k(0, 2), random:k(0, 2)
endin


instr 2
    inotes[] fillarray 48, 52, 53, 57
    inote = inotes[int(random(0, lenarray(inotes)-1))]+24
    oplnote giopl, 0, inote, 120
endin

instr 3
    inote = 48+24
    oplnote giopl, 1, inote, 120
    oplnote giopl, 1, inote+4, 120
    oplnote giopl, 1, inote+5, 120
    oplnote giopl, 1, inote+9, 120
endin



</CsInstruments>
; ==============================================
<CsScore>
i"main" 0 3600
</CsScore>
</CsoundSynthesizer>

