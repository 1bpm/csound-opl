<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
/*
    csound-opl example 1
    Multiple channel chord sequence

    Richard Knight 2021 : examples are licensed as public domain equivalent : http://unlicense.org/
*/

sr = 44100
kr = 4410
nchnls = 2
0dbfs = 1

giopl init 0



/*
    Play notes with certain parameters:
        kinstr : the instrument number to play
        kduration : play duration
        kbase : base MIDI note number
        kintervals : intervals to form a chord with from kbase
        ktimeinc : how much time to step with each interval
        kreadmode : read intervals 0=forward, 1=reverse
*/
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


; audio output, voice setting and sequencer invocation
instr main
    ; the synthesiser
    giopl, aL, aR opl
    outs aL, aR

    ; set the voices for four channels
    oplpatchchange giopl, 0, 89
    oplpatchchange giopl, 1, 12
    oplpatchchange giopl, 2, 72
    oplpatchchange giopl, 3, 96
    oplpatchchange giopl, 4, 39 

    ; start the sequencer
    event_i "i", "sequencer", 0, p3
endin


; basic chord triggering pseudo-sequencer
instr sequencer
    itempo = 120
    ibeatduration = 60/itempo

    ; intervals for chords, and notes for progression
    kintervalsall[][] init 4, 4
    kintervalsall fillarray 0, 4, 5, 9,  4, 5, 7, 9,  0, 5, 7, 14,  0, 5, 7, 8
    knotes[] fillarray 50, 54, 56, 54

    knotedx init 0
    kbeat metro itempo/60
    kbar0 init 0
    if (kbeat == 1) then
	kintervals[] getrow kintervalsall, knotedx
        if (kbar0 == 0) then
            playchord 3, ibeatduration*4, knotes[knotedx], kintervals, 0, 0
        elseif (kbar0 == 1) then
            playchord 2, ibeatduration, knotes[knotedx], kintervals, ibeatduration/4, 0
        elseif (kbar0 == 2) then
            playchord 1, ibeatduration, knotes[knotedx]+12, kintervals, 0, 0
        elseif (kbar0 == 3) then
            playchord 4, ibeatduration, knotes[knotedx]+12, kintervals, ibeatduration/4, 1
        endif

	kbassnote = knotes[knotedx]
	event "i", 5, 0, ibeatduration*0.2, kbassnote-24
	event "i", 5, ibeatduration*0.5, ibeatduration*0.16, kbassnote-12
	

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


; play note on channel 0
instr 1
    oplnote giopl, 0, p4, 120
endin


; play note on channel 1
instr 2
    oplnote giopl, 1, p4, 100
endin


; play note on channel 2
instr 3
    oplnote giopl, 2, p4, 100
endin


; play note on channel 3
instr 4
    oplnote giopl, 3, p4, 100
endin

; play note on channel 4
instr 5
    oplnote giopl, 4, p4, 80
endin

</CsInstruments>
<CsScore>
i"main" 0 3600

</CsScore>
</CsoundSynthesizer>

