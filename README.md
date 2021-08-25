# csound-opl3 : OPL3 (YMF262) FM synthesis emulation for Csound

## Overview
csound-opl3 is a Csound plugin which provides an interface to emulated OPL3 FM synthesis as popularised by Yamaha chips, utilised by various
computer sound cards from the late 1980s onwards. The YMF262 chip in particular was popularised by inclusion on the Sound Blaster 16 card, and 
Yamaha's specific FM implementation had a significant impact on home computer synthesis, in particular through usage in games.

The YMF262 chip applies an implementation of synthesis similar to some of Yamaha's other well known FM synthesisers such as the DX7 and TX81z although
provides a cut-down 4 oscillator approach.
Due to the popularity of the chip for computer games, it has been widely emulated in software and notably included in [DOSBox](https://www.dosbox.com/), 
which has in turn been used (along with other emulations) by [ADLMIDI](https://bisqwit.iki.fi/source/adlmidi.html), further extrapolated to 
[libADLMIDI](https://github.com/Wohlstand/libADLMIDI) and finally utilised to create this set of plugin opcodes for Csound.

Complete control over all four oscillators (operators, in Yamaha terminology) is provided, along with the ability to use preset banks (instrument sets)
which are compiled into ADLMIDI/libADLMIDI - many are custom banks extracted from various games and other software from the 1990s.


## Requirements
* Cmake >= 2.8.12
* Csound with development headers
* [libADLMIDI](https://github.com/Wohlstand/libADLMIDI)


Tested on Linux with Csound 6.17 and libADLMIDI 1.5.0.1 as of writing.

## Installation
Create a build directory at the top of the source tree, execute *cmake ..*, *make* and optionally *make install* as root. If the latter is not used/possible then the resulting library can be used with the *--opcode-lib* flag in Csound.
eg:

	mkdir build && cd build
	cmake ..
	make && sudo make install

Cmake should find Csound and any other required libraries using the modules in the cmake/Modules directory and installation should be as simple as above.


## Notes
Multiple types of OPL3 emulation are provided as in libADLMIDI. These are explained further on the [libADLMIDI](https://github.com/Wohlstand/libADLMIDI)
and [ADLMIDI](https://bisqwit.iki.fi/source/adlmidi.html) pages.


Instrument parameter ranges are representative of the original OPL3 chip which used 8-bit registers, hence ranges such as 0 - 15 and 0 - 3. 
The parameters are all unsigned integers, so for example with attack, there are actually only 16 possible attack times. Any floating point numbers passed will just
be converted accordingly. This is also the case for control change messages which are unsigned 8-bit integers.

The only exception to this is the pitch bend opcode, oplpitchbend, which takes a value corresponding to a midi note (ie 1 = 1 semitone) and can be negative.


There are two modes of selecting sounds to be used:

* Preset banks and patches (compiled into libADLMIDI) using the oplsetbank, oplpatchchange and oplbanknames opcodes.
* Parametric instrument editing of all parameters using the oplinstrument and oploperator opcodes.

Once the oplinstrument opcode is used for a particular opl instance, it will switch the channel from using preset banks to parametric editing.


## Examples
Four examples are provided in the examples directory, including a FLTK gui for editing instruments. 
There is also a [demonstration video](http://plugins.csound.1bpm.net/files/vid/opl-demo1.mp4) of the FLTK editor, and [another video](http://plugins.csound.1bpm.net/files/vid/opl-demo2.mp4) showing all four examples.


## Opcode reference

### opl
Create an instance of the emulated OPL3 synthesiser.

_ioplhandle, aleft, aright __opl__ [iemulation=0, irunatpcmrate=0]_

* ioplhandle : handle to be used in other opcodes to control synthesis
* aleft, aright : stereo audio outputs

* iemulation : OPL3 chip emulation type (0 = DOSBox, 1 = Nuked_1.8, 2=Nuked_1.74, 3=Opal, 4=Java)
* irunatpcmrate : run emulation at PCM rate; setting to 1 may reduce CPU usage but lessen emulation accuracy


### oplnote
Play a note using the synthesiser specified by ioplhandle.

___oplnote__ ioplhandle, ichannel, inote, ivelocity_

* ioplhandle : handle created by the opl opcode
* ichannel : channel for playback (0 - 15)
* inote : midi note number to play
* ivelocity : midi note velocity (0 - 127)


### oplinstrument
Modify the current instrument parameters and obtain handles to all four operators (oscillators) for further manipulation with the oploperator opcode.

_iop1, iop2, iop3, iop4 __oplinstrument__ ioplhandle, kmode12, kmode34, kfbk12, kfbk34, k4op, kpseudo4op, kdeepvib, kdeeptrem_

* iop1, iop2, iop3, iop4 : handles for the individual operators to be used by the oploperator opcode.

* ioplhandle : handle created by the opl opcode
* kmode12 : op 1 and 2 mode (0 = FM, 1 = AM)
* kmode34 : op 3 and 4 mode (0 = FM, 1 = AM)
* kfbk12 : op 1 and 2 feedback (0 - 7)
* kfbk34 : op 3 and 4 feedback (0 - 7)
* k4op : use all 4 operators (0 = no, 1 = yes)
* kpseudo4op : use all 4 operators with pseudo emulation (0 = no, 1 = yes)
* kdeepvib : global deep vibrato (0 = off, 1 = on)
* kdeeptrem : global deep tremolo (0 = off, 1 = on)


### oploperator
Alter individual operator parameters. Out of range parameters will wrap around.

___oploperator__ iop, klevel, kscale, kattack, kdecay, ksustain, krelease, kwave, kfreqmul, ktrem, kvib, ksus, kenv_

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



### oplpanic
Terminate all current notes and reset the opl instance.

___oplpanic__ ioplhandle_

* ioplhandle : handle created by the opl opcode


### oplbanknames
Obtain all of the bank names compiled into libADLMIDI. The indexes returned can be
used by the oplsetbank opcode accordingly.

_Sbanks[] __oplbanknames__ ioplhandle_

* Sbanks[] : array of bank names

* ioplhandle : handle created by the opl opcode


### oplsetbank
Set the current bank (sound set) for the given opl instance. Any playing notes will be 
stopped and the instance will be reset (may cause a click if audio is playing).

___oplsetbank__ ioplhandle, ibank_

* ioplhandle : handle created by the opl opcode
* ibank : the bank index (corresponds to the output of oplbanknames


### oplpatchchange
Set the patch for the specified channel.

___oplpatchchange__ ioplhandle, kchannel, kpatch_

* ioplhandle : handle created by the opl opcode
* kchannel : channel index (0 - 15)
* kpatch : patch index (0 - 127)


### oplpitchbend
Set the pitch bend value for the specified channel.

___oplpitchbend__ ioplhandle, kchannel, kbend_

* ioplhandle : handle created by the opl opcode
* kchannel : channel index (0 - 15)
* kbend : bend amount in semitones (may be positive or negative)


### oplaftertouch
Set the aftertouch value for the specified channel.

___oplaftertouch__ ioplhandle, kchannel, kaftertouch_

* ioplhandle : handle created by the opl opcode
* kchannel : channel index (0 - 15)
* kaftertouch : aftertouch amount (0 - 127)


### oplcontrolchange
Set a control change value for a specified channel.

___oplcontrolchange__ ioplhandle, kchannel, kcontrol, kvalue_

* ioplhandle : handle created by the opl opcode
* kchannel : channel index (0 - 15)
* kcontrol : MIDI CC number (0 - 127)
* kvalue : value (0 - 127)
