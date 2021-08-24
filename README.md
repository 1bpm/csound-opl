# csound-opl3 : OPL3 emulation for Csound

## Overview
Description here

## Requirements
* Cmake >= 2.8.12
* Csound with development headers
* libADLMIDI (https://github.com/Wohlstand/libADLMIDI)



## Installation
Create a build directory at the top of the source tree, execute *cmake ..*, *make* and optionally *make install* as root. If the latter is not used/possible then the resulting library can be used with the *--opcode-lib* flag in Csound.
eg:

	mkdir build && cd build
	cmake ..
	make && sudo make install

Cmake should find Csound and any other required libraries using the modules in the cmake/Modules directory and installation should be as simple as above.


## Notes
Multiple types of OPL3 emulation are provided as in libADLMIDI. These are:
* DOSBox : fast and quite accurate
* Nuked : Very accurate, very CPU intensive

All parameter ranges are representative of the original OPL3 chip which used 8-bit registers, hence ranges such as 0 - 15 and 0 - 3. 
The parameters are all integers, so for example with attack, there are actually only 16 possible attack times. Any floating point numbers passed will just
be converted accordingly.


## Examples
Some examples are provided in the examples directory.


## Opcode reference

### ioplhandle, aleft, aright opl [iemulation=0, irunatpcmrate=0]
Create an instance of the emulated OPL3 synthesiser.

* ioplhandle : handle to be used in other opcodes to control synthesis
* aleft, aright : stereo audio outputs

* iemulation : OPL3 chip emulation type (0 = DOSBox, 1 = Nuked_1.8, 2=Nuked_1.74, 3=Opal, 4=Java)
* irunatpcmrate : run emulation at PCM rate; setting to 1 may reduce CPU usage but lessen emulation accuracy


### oplnote ioplhandle, ichannel, inote, ivelocity
Play a note using the synthesiser specified by ioplhandle.

* ioplhandle : handle created by the opl opcode
* ichannel : channel for playback (0 - 15)
* inote : midi note number to play
* ivelocity : midi note velocity (0 - 127)


### iop1, iop2, iop3, iop4 oplinstrument ioplhandle, kfeedback ETC
Modify the current instrument parameters and obtain handles to all four operators (oscillators) for further manipulation with the oploperator opcode.

* iop1, iop2, iop3, iop4 : handles for the individual operators to be used by the oploperator opcode.


### oploperator iop, klevel, kscale, kattack, kdecay, ksustain, krelease, kwave, kfreqmul, ktrem, kvib, ksus, kenv
Alter individual operator parameters. Out of range parameters will wrap around.

* iop : handle for the specific operator as provided by the oplinstrument opcode

* klevel : gain level (0 - 63)
* kscale : key scale (0 - 3)
* kattack : attack time (0 - 15)
* kdecay : decay time (0 - 15)
* ksustain : sustain time (0 - 15)
* krelease : release time (0 - 15)
* kwave : waveform (0 - 7)
* kfreqmul : frequency multiplier (0 - 15)
* ktrem : tremolo switch (0 - 1)
* kvib : vibrato switch (0 - 1)
* ksus : sustaining switch (0 - 1)
* kenv : key envelope switch (0 - 1)



### oplpanic ioplhandle
Terminate all current notes for the given opl instance.

* ioplhandle : handle created by the opl opcode



