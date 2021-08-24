<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>

sr = 44100
kr = 4410
nchnls = 2
0dbfs = 1

giopl init 0

instr main	
    giopl, aL, aR opl
    outs aL, aR

    oplpatchchange giopl, 0, 89
    oplpatchchange giopl, 1, 12
    oplpatchchange giopl, 2, 72
    oplpatchchange giopl, 3, 96

    event_i "i", "sequencer", 0, p3
endin


opcode playchord, 0, kkkk[]kk
    kinstr, kduration, kbase, kintervals[], ktimeinc, kreadmode xin
    ktime = 0

    if (kreadmode == 0) then
        kdx = 0
        while (kdx < lenarray(kintervals)) do
            event "i", kinstr, ktime, kduration, kbase+kintervals[kdx]
            ktime += ktimeinc
            kdx += 1
        od
    else 
        kdx = lenarray(kintervals) - 1
        while (kdx > -1) do
            event "i", kinstr, ktime, kduration, kbase+kintervals[kdx]
            ktime += ktimeinc
            kdx -= 1
        od
    endif
endop

instr sequencer
    itempo = 120
    ibeatduration = 60/itempo
    kintervals[] fillarray 0, 4, 5, 9
    knotes[] fillarray 50, 54, 56, 48
    knotedx init 0
    kbeat metro itempo/60
    kbar0 init 0
    if (kbeat == 1) then
        if (kbar0 == 0) then
            playchord 3, ibeatduration*4, knotes[knotedx], kintervals, 0, 0
        elseif (kbar0 == 1) then
            playchord 2, ibeatduration, knotes[knotedx], kintervals, ibeatduration/4, 0
        elseif (kbar0 == 2) then
            playchord 1, ibeatduration, knotes[knotedx]+12, kintervals, 0, 0
        elseif (kbar0 == 3) then
            playchord 4, ibeatduration, knotes[knotedx]+12, kintervals, ibeatduration/4, 1
        endif

        if (kbar0 < 3) then
            kbar0 += 1
        else
            if (knotedx < 3) then
                knotedx += 1
            else 
                knotedx = 0
            endif
            kbar0 = 0
        endif
    endif
endin


instr 1
    oplnote giopl, 0, p4, 120
endin

instr 2
    oplnote giopl, 1, p4, 100
endin

instr 3
    oplnote giopl, 2, p4, 100
endin

instr 4
    oplnote giopl, 3, p4, 100
endin

</CsInstruments>
; ==============================================
<CsScore>
i"main" 0 3600

</CsScore>
</CsoundSynthesizer>

