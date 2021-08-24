/*
    opcodes.cpp
    Copyright (C) 2021 Richard Knight


    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 3 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program; if not, write to the Free Software Foundation,
    Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 
 */
#include <float.h>
#include <plugin.h>
#include "handling.h"
#include "adlmidi.h"
/* sources referenced for bit shift/convert operations etc
 * https://github.com/jpcima/ADLplug/blob/master/sources/opl3/parameter_block.cc
 * https://github.com/jpcima/ADLplug/blob/master/sources/opl3/adl/instrument.h
 * https://github.com/jpcima/ADLplug/blob/master/sources/utility/field_bitops.h
 */


static const char* badHandle = "opl handle is not valid";

/*
 * core struct for passing between opcodes as a handle
 */
struct ADLSession {
    ADL_MIDIPlayer* device = NULL;
    bool changed;
};

/*
 *  operator struct for passing between oplinstrument and oploperator opcodes
 */
struct ADLSessionOperator {
    ADLSession* session;
    ADL_Operator* op;
};

/*
 *  bit conversion for decimal to OPL chipset values
 */
static int bitconvert(int shiftb, int size, int current, MYFLT value) {
    int mask = (1 << size) - 1;
    return (current & ~(mask << shiftb)) | (( ((int)value) & mask) << shiftb);
}

/*
 *  bit conversion for decimal to OPL chipset values, inverse
 */
static int bitconvert_inv(int shiftb, int size, ADL_UInt8 current, MYFLT value) {
    int max = ((1 << size) - 1);
    return bitconvert(shiftb, size, current, max - value);
}

/* 
 * opcode: opl
 * handle the libADLMIDI instance and output audio
 */
struct opl : csnd::Plugin<3, 2> {
    static constexpr char const *otypes = "iaa";
    static constexpr char const *itypes = "oo";
    
    ADLSession* session;
    short* out;
    
    int init() {
        csound->plugin_deinit(this);
        outargs[0] = createHandle<ADLSession>(csound, &session);

        session->device = adl_init(csound->sr());
        if (session->device == NULL) {
            return csound->init_error(adl_errorString());
        }
        int status = 0;
        if (inargs[0] == FL(0)) {
            status = adl_switchEmulator(session->device, ADLMIDI_EMU_DOSBOX);
        } else if (inargs[0] == FL(1)) {
            status = adl_switchEmulator(session->device, ADLMIDI_EMU_NUKED);
        } else if (inargs[0] == FL(2)) {
            status = adl_switchEmulator(session->device, ADLMIDI_EMU_NUKED_174);
        } else if (inargs[0] == FL(3)) {
            status = adl_switchEmulator(session->device, ADLMIDI_EMU_OPAL);
        } else if (inargs[0] == FL(4)) {
            status = adl_switchEmulator(session->device, ADLMIDI_EMU_JAVA);
        }
        
        if (status != 0) return csound->init_error(adl_errorInfo(session->device));

        status = adl_setRunAtPcmRate(session->device, (int) inargs[1]);
        if (status != 0) return csound->init_error(adl_errorInfo(session->device));
        
        out = (short*) csound->calloc(sizeof(short) * ksmps() * 2);
        return OK;
    }
    
    int deinit() {
        //if (session->device != NULL) adl_close(session->device); // causes segfault..?
        if (out != NULL) csound->free(out);
        return OK;
        
    }
    
    int aperf() {
        int read_pos = 0;
        int sample_count = adl_generate(session->device, nsmps*2, out);
        for (int i = 0; i < nsmps; i++) { // interleaved buffer from ADL
            outargs(1)[i] = ((MYFLT) out[read_pos++])/SHRT_MAX;
            outargs(2)[i] = ((MYFLT) out[read_pos++])/SHRT_MAX;
        }
        
        return OK;
    }
};

/* 
 * opcode: oplsetbank
 * set the current bank by index (preset internal libADLMIDI banks, specified at
 * compile time)
 */
struct oplsetbank : csnd::InPlug<2> {
    static constexpr char const *otypes = "";
    static constexpr char const *itypes = "ii";
    
    int init() {
        ADLSession* session = getHandle<ADLSession>(csound, args[0]);
        if (session == NULL) return csound->init_error(badHandle);
        int status = adl_setBank(session->device, (int) args[1]);
        if (status != 0) return csound->init_error(adl_errorInfo(session->device));
        adl_reset(session->device);
        return OK;
    }
};

/* 
 * opcode: oplpanic
 * turn off all notes, reset the instance
 */
struct oplpanic : csnd::InPlug<1> {
    static constexpr char const *otypes = "";
    static constexpr char const *itypes = "i";
    
    int init() {
        ADLSession* session = getHandle<ADLSession>(csound, args[0]);
        if (session == NULL) return csound->init_error(badHandle);
        adl_panic(session->device);
        adl_reset(session->device);
        return OK;
    }
};

/* 
 * opcode: oplpatchchange
 * change the midi patch (ie 0-127) for a specified channel
 */
struct oplpatchchange : csnd::InPlug<3> {
    static constexpr char const *otypes = "";
    static constexpr char const *itypes = "ikk";
    
    ADLSession* session;
    int channel;
    int patch;
    
    int init() {
        session = getHandle<ADLSession>(csound, args[0]);
        if (session == NULL) return csound->init_error(badHandle);
        channel = (int) args[1];
        patch = (int) args[2];
        adl_rt_patchChange(session->device, channel, patch);
        return OK;
    }
    
    int kperf() {
        int channel = (int) args[1];
        int patch = (int) args[2]; 
        if (channel != this->channel || patch != this->patch) {
            this->channel = channel;
            this->patch = patch;
            adl_rt_patchChange(session->device, channel, patch);
        }
        return OK;
    }
};


/* 
 * opcode: oplaftertouch
 * apply aftertouch for channel
 */
struct oplaftertouch : csnd::InPlug<3> {
    static constexpr char const *otypes = "";
    static constexpr char const *itypes = "ikk";
    
    ADLSession* session;
    int channel;    
    ADL_UInt8 value;
    
    int init() {
        session = getHandle<ADLSession>(csound, args[0]);
        if (session == NULL) return csound->init_error(badHandle);
        channel = (int) args[1];
        value = (ADL_UInt8) args[2];
        adl_rt_channelAfterTouch(session->device, channel, value);
        return OK;
    }
    
    int kperf() {
        channel = (int) args[1];
        value = (ADL_UInt8) args[2];
        if (channel != this->channel || value != this->value) {
            this->channel = channel;
            this->value = value;
            adl_rt_channelAfterTouch(session->device, channel, value);
        }
        return OK;
    }
};

/* 
 * opcode: oplcontrolchange
 * apply control change for channel
 */
struct oplcontrolchange : csnd::InPlug<4> {
    static constexpr char const *otypes = "";
    static constexpr char const *itypes = "ikkk";
    
    ADLSession* session;
    int channel;    
    ADL_UInt8 type;
    ADL_UInt8 value;
    
    int init() {
        session = getHandle<ADLSession>(csound, args[0]);
        if (session == NULL) return csound->init_error(badHandle);
        channel = (int) args[1];
        type = (ADL_UInt8) args[2];
        value = (ADL_UInt8) args[3];
        adl_rt_controllerChange(session->device, channel, type, value);
        return OK;
    }
    
    int kperf() {
        channel = (int) args[1];
        type = (ADL_UInt8) args[2];
        value = (ADL_UInt8) args[3];
        if (channel != this->channel || type != this->type || value != this->value) {
            this->channel = channel;
            this->type = type;
            this->value = value;
            adl_rt_controllerChange(session->device, channel, type, value);
        }
        return OK;
    }
};

/* 
 * opcode: oplpitchbend
 * apply channel specific pitch bend; pitch bend is 24bit
 */
struct oplpitchbend : csnd::InPlug<3> {
    static constexpr char const *otypes = "";
    static constexpr char const *itypes = "ikk";
    
    ADLSession* session;
    int channel;
    ADL_UInt16 bend;
    
    int init() {
        session = getHandle<ADLSession>(csound, args[0]);
        if (session == NULL) return csound->init_error(badHandle);
        channel = (int) args[1];
        bend = (ADL_UInt16) ((args[2]*4096)+8192); 
        adl_rt_pitchBend(session->device, channel, bend);
        return OK;
    }
    
    int kperf() {
        int channel = (int) args[1];
        ADL_UInt16 bend = (ADL_UInt16) ((args[2]*4096)+8192);
        if (channel != this->channel || bend != this->bend) {
            this->channel = channel;
            this->bend = bend;
            adl_rt_pitchBend(session->device, channel, bend);
        }
        return OK;
    }
};

/* 
 * opcode: oplnote
 * play a note on the specified opl instance
 */
struct oplnote : csnd::InPlug<4> {
    static constexpr char const *otypes = "";
    static constexpr char const *itypes = "iiii";
    
    int channel;
    int note;
    ADLSession* session;
    
    int init() {
        csound->plugin_deinit(this);
        session = getHandle<ADLSession>(csound, args[0]);
        if (session == NULL) return csound->init_error(badHandle);
        channel = (int) args[1];
        note = (int) args[2];
        int velocity = (int) args[3];
        adl_rt_noteOn(session->device, channel, note, velocity);
        return OK;
    }
    
    int deinit() {
        adl_rt_noteOff(session->device, channel, note);
    }
};

struct oplbanknames : csnd::Plugin<1, 1> { // InPlug
    static constexpr char const *otypes = "S[]";
    static constexpr char const *itypes = "i";
    
    int init() {
        ADLSession* session = getHandle<ADLSession>(csound, inargs[0]);
        if (session == NULL) return csound->init_error(badHandle);
        int banks_number = adl_getBanksCount();
        
        ARRAYDAT* array = (ARRAYDAT*) outargs(0);
        array->sizes = (int32_t*) csound->calloc(sizeof(int32_t));
        array->sizes[0] = banks_number;
        array->dimensions = 1;
        CS_VARIABLE* var = array->arrayType->createVariable(csound, NULL);
        array->arrayMemberSize = var->memBlockSize;
        array->data = (MYFLT*) csound->calloc(var->memBlockSize * banks_number);
        STRINGDAT* data = (STRINGDAT*) array->data;
        
        const char* const* banks = adl_getBankNames();
        for (int i = 0 ; i < banks_number; i++) {
            data[i].size = strlen(banks[i]);
            data[i].data = csound->strdup((char*) banks[i]);
        }
        return OK;
    }
    
};



/* 
 * opcode: oploperator
 * control specific parameters of an operator (oscillator)
 */
struct oploperator : csnd::InPlug<13> {
    static constexpr char const *otypes = "";
    static constexpr char const *itypes = "ikkkkkkkkkkkk";
    
    ADLSessionOperator* so;
    ADL_Operator* o;
    MYFLT* lastval;
    int argnum;
    
    int init() {
        argnum = 13;
        so = getHandle<ADLSessionOperator>(csound, args[0]);
        if (so == NULL) return csound->init_error("opl instrument handle is not valid");
        o = so->op;
        lastval = (MYFLT*) csound->malloc(sizeof(MYFLT) * argnum);
        setvalues();
        return OK;
    }
    
    
    
    bool haschanged() { // TODO really saves any overhead??
        bool changed = false;
        for (int i = 1; i < argnum ; i++) {
            if (args[i] != lastval[i]) {
                lastval[i] = args[i];
                changed = true;
            }
        }
        return changed;
    }
    
    void setvalues() {
        // level, 0 to 63
        o->ksl_l_40 = bitconvert_inv(0, 6, o->ksl_l_40, args[1]);
        //printf("%d-x\n", o->ksl_l_40);
        
        // key scale level, 0 to 3
        o->ksl_l_40 = bitconvert_inv(6, 2, o->ksl_l_40, args[2]);
        
        // attack, 0 to 15
        o->atdec_60 = bitconvert_inv(4, 4, o->atdec_60, args[3]);
        
        // decay, 0 to 15
        o->atdec_60 = bitconvert_inv(0, 4, o->atdec_60, args[4]);
        
        // sustain, 0 to 15 
        o->susrel_80 = bitconvert_inv(4, 4, o->susrel_80, args[5]);
        
        // release, 0 to 15
        o->susrel_80 = bitconvert_inv(0, 4, o->susrel_80, args[6]);
        
        // waveform, 0 to 8
        o->waveform_E0 = bitconvert(0, 3, o->waveform_E0, args[7]);
        
        // freq mult, 0 to 15
        o->avekf_20 = bitconvert(0, 4, o->avekf_20, args[8]);
        
        // tremolo, 0 to 1
        o->avekf_20 = bitconvert(7, 1, o->avekf_20, args[9]);
        
        // vibrato, 0 to 1
        o->avekf_20 = bitconvert(6, 1, o->avekf_20, args[10]);
        
        // sustaining, 0 to 1
        o->avekf_20 = bitconvert(5, 1, o->avekf_20, args[11]);
        
        // env/key scaling, 0 to 1
        o->avekf_20 = bitconvert(4, 1, o->avekf_20, args[12]);
    }
    
    int kperf() {
        //o->avekf_20 = (ADL_UInt8) shift(args[1];
        
        if (haschanged()) {
            setvalues();
            so->session->changed = true;
        }
        return OK;
    }
};


/* 
 * opcode: oplinstrument
 * switch to instrument control mode (rather than bank), specify parameters
 * and get operator handles
 */
struct oplinstrument : csnd::Plugin<4, 9> {
    static constexpr char const *otypes = "iiii";
    static constexpr char const *itypes = "ikkkkkkkk";
    
    ADLSession* session;
    ADL_Instrument* instrument;
    ADL_Bank* bank;
    ADLSessionOperator* sessionOperators[4];
    MYFLT* lastval;
    int argnum;
    
    int init() {
        argnum = 9;
        session = getHandle<ADLSession>(csound, inargs[0]);
        if (session == NULL) return csound->init_error(badHandle);
        int status;
        instrument = (ADL_Instrument*) csound->malloc(sizeof(ADL_Instrument));
        bank = (ADL_Bank*) csound->malloc(sizeof(ADL_Bank));
                
        ADL_BankId bnk;
        bnk.percussive = 0;
        bnk.msb = 0;
        bnk.lsb = 0;
        
        status = adl_getBank(session->device, &bnk, 1, bank); // 1 is create
        if (status != 0) return csound->init_error(adl_errorInfo(session->device));
        
        status = adl_getInstrument(session->device, bank, 0, instrument);
        if (status != 0) return csound->init_error(adl_errorInfo(session->device));
        
        for (int i = 0; i < 4; i++) {
            outargs[i] = createHandle<ADLSessionOperator>(csound, &sessionOperators[i]);
            sessionOperators[i]->op = &(instrument->operators[i]);
            sessionOperators[i]->session = session;
        }
        
        lastval = (MYFLT*) csound->malloc(sizeof(MYFLT) * argnum);
        setvalues();
        
        return OK;
    }
    
    void setvalues() {
        
        // mode 1-2, 0 to 1 (FM, AM)
        instrument->fb_conn1_C0 = bitconvert(0, 1, instrument->fb_conn1_C0, inargs[1]);
        
        // mode 3-4, 0 to 1 (FM, AM)
        instrument->fb_conn2_C0 = bitconvert(0, 1, instrument->fb_conn2_C0, inargs[2]);
        
        // feedback 1-2, 0 to 7
        instrument->fb_conn1_C0 = bitconvert(1, 3, instrument->fb_conn1_C0, inargs[3]);
        
        // feedback 3-4, 0 to 7
        instrument->fb_conn2_C0 = bitconvert(1, 3, instrument->fb_conn2_C0, inargs[4]);
        
        // 4op, 0 to 1
        instrument->inst_flags = bitconvert(0, 1, instrument->inst_flags, inargs[5]);
        
        // pseudo 4op, 0 to 1
        instrument->inst_flags = bitconvert(1, 1, instrument->inst_flags, inargs[6]);
        
        // deep vibrato, 0 to 1
        adl_setHVibrato(session->device, inargs[7]);
        
        // deep tremolo, 0 to 1
        adl_setHTremolo(session->device, inargs[8]);
    }
    
    bool haschanged() { // TODO really saves any overhead??
        bool changed = false;
        for (int i = 1; i < argnum ; i++) {
            if (inargs[i] != lastval[i]) {
                lastval[i] = inargs[i];
                changed = true;
            }
        }
        return changed;
    }
    
    int kperf() {
        bool changed = session->changed;
        if (haschanged()) {
            setvalues();
            changed = true;
        }
        if (changed) { 
            adl_setInstrument(session->device, bank, 0, instrument);
            session->changed = false;
        }
        return OK;
    }
};


#include <modload.h>
void csnd::on_load(csnd::Csound *csound) {
    csnd::plugin<opl>(csound, "opl", csnd::thread::ia);
    csnd::plugin<oplsetbank>(csound, "oplsetbank", csnd::thread::i);
    csnd::plugin<oplpatchchange>(csound, "oplpatchchange", csnd::thread::ik);
    csnd::plugin<oplpitchbend>(csound, "oplpitchbend", csnd::thread::ik);
    csnd::plugin<oplinstrument>(csound, "oplinstrument", csnd::thread::ik);
    csnd::plugin<oploperator>(csound, "oploperator", csnd::thread::ik);
    csnd::plugin<oplaftertouch>(csound, "oplaftertouch", csnd::thread::ik);
    csnd::plugin<oplcontrolchange>(csound, "oplcontrolchange", csnd::thread::ik);
    csnd::plugin<oplnote>(csound, "oplnote", csnd::thread::i);
    csnd::plugin<oplpanic>(csound, "oplpanic", csnd::thread::i);
    csnd::plugin<oplbanknames>(csound, "oplbanknames", csnd::thread::i);
}


