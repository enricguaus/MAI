(
// -----------------------
// ---- SERVER CONFIG ----
// -----------------------
s.meter;
s.options.memSize=1024*32;
//s.options.inDevice = "BlackHole 16ch";
//s.options.inDevice = "Built-in Microph";
//s.options.inDevice = "EDIROL UA-25";
//s.options.inDevice = "USB Audio CODEC";
//s.options.outDevice = "EDIROL UA-25";
//s.options.outDevice = "Built-in Output";
//s.options.outDevice = "USB Audio CODEC";
//s.options.outDevice = "Dispositiu multisortida";
//s.options.outDevice = "Blackhole+Edirol";
)

(
// -------------------
// ---- VARIABLES ----
// -------------------
~vcvRcvPort    = NetAddr("127.0.0.1", 8881); // <---- Put your IP address and port here to send OSC messages.
~guiRcvPort    = NetAddr("127.0.0.1", 57110);
~n_dims        = 30;// Chroma added + all onsets. It was 5;
~kme_k         = 4;

// -------------------
// ---- SYNTHDEFs ----
// -------------------
s.waitForBoot({
	// ---- Buffers ----
	~kme_buf = Buffer.alloc(s, ~kme_k, ~n_dims+1);

	// ---- Synthdefs ----
	SynthDef(\mic_stereo, {arg in=0, out=0, amp=1;
		var snd = SoundIn.ar([in,in+1],amp).tanh;
		Out.ar(out, snd);
		Out.ar(0, snd);
	}).add;

	SynthDef(\analysis, {arg bufIn=0, bufOut=0, smooth=200;
		var cnt_skip = 0;
		// ---- Input and FFT ----
		var snd = Mix.new(In.ar(bufIn));
		var fft = FFT(LocalBuf(1024), snd);
		var trg = fft > -0.001;
		// ---- Amplitude, RMS and Loudness ----
		var amp   = Amplitude.kr(snd);
		var d_amp = Slope.kr(amp);
		var rms   = RMS.kr(snd);
		var d_rms = Slope.kr(rms);
		var lou   = Loudness.kr(fft);
		var d_lou = Slope.kr(lou);
		// ---- Pitch ----
		var frq   = Tartini.kr(snd);
		var d_frq = Slope.kr(frq);
		//var d_frq = RunningMax.kr(frq,Impulse.kr(rrate))-RunningMin.kr(frq,Impulse.kr(rrate));
		// ---- Rhythm ----
		var ons   = OnsetStatistics.kr(Onsets.kr(fft,0.25),2.0);
		var bst   = BeatStatistics.kr(fft);
		// ---- Chroma ----
		var key   = KeyTrack.kr(fft, keydecay: 2.0, chromaleak: 0.25);
		var chr   = Chromagram.kr(fft);
		// ---- Timbre ----*/
		var cen   = SpecCentroid.kr(fft);
		var fla   = SpecFlatness.kr(fft);
		var sdi   = SensoryDissonance.kr(fft);
		var mfc   = MFCC.kr(fft);
		// ---- Send data ----
		var des   = [
			        amp,d_amp,rms,d_rms,lou,d_lou,
			        frq,d_frq,
			        ons[0],ons[1],ons[2],
			        bst[0],bst[1],bst[2],bst[3],
			        // key,
			        chr[0],chr[1],chr[2],chr[3],chr[4],chr[5],chr[6],chr[7],chr[8],chr[9],chr[10],chr[11],
			        cen,fla,sdi
			        // mfc[0],mfc[1],mfc[2],mfc[3],mfc[4],mfc[5],mfc[6],mfc[7],mfc[8],mfc[9],mfc[10],mfc[11],mfc[12]
		            ];
		var mva   = MovingAverage.kr(des,smooth);
		Out.kr(bufOut,mva);
	}).add;

	SynthDef(\norm_features,{arg in=0, out=0, smooth=200, rst=0;
		var mva = In.kr(in,~n_dims);
		var nor   = MovingAverage.kr((mva - RunningMin.kr(mva,rst>0)) / (RunningMax.kr(mva,rst>0) - RunningMin.kr(mva,rst>0)).max(1e-9),smooth);
		Out.kr(out,nor);
	}).add;

	SynthDef(\k_means_cla,{arg in=0, out_cla=0, kbuf=0, k=0, rst=0;
		var fea = In.kr(in,~n_dims);
		var cla = MedianTriggered.kr(KMeansRT.kr(kbuf, fea, k, reset:rst>0),trig:1, length:1);
		Out.kr(out_cla, cla);
	}).add;

	SynthDef(\k_means_dis,{arg in=0, out_cen=0, kbuf=0, ndims=0; // TODO: ~n_dims as parameter not working!
        var cen = KMeansRT.getCentroid(kbuf, in, ~n_dims);//.at(0);
		Out.kr(out_cen, cen);
	}).add;
});
)

(
// -----------------
// ---- PROCESS ----
// -----------------
~mic_bus = Bus.audio(s,2);
~fea_bus = Bus.control(s,~n_dims);
~nor_bus = Bus.control(s,~n_dims);
~cla_bus = Bus.control(s,1);
~cen_bus = Array.fill(~kme_k,{Bus.control(s,~n_dims)});
~err_bus = Bus.control(s,~kme_k);
v=Synth(\mic_stereo,[\in, 0, \out, ~mic_bus]);
w=Synth.tail(nil,\analysis,[\in, ~mic_bus, \out, ~fea_bus, \ma_smooth, 250]);
x=Synth.tail(nil,\norm_features,[\in, ~fea_bus, \out, ~nor_bus]);


r=Task({
	var bpm, beats;
	2.wait;
	x.set(\rst,1);
	1.wait;
	x.set(\rst,0);
	1.wait;
	y=Synth.tail(nil,\k_means_cla,[\in, ~nor_bus, \out_cla, ~cla_bus, \kbuf, ~kme_buf, \k, ~kme_k, \rst, 0]);
	0.01.wait;
	z = Array.fill(~kme_k,{arg i;
		Synth.tail(nil,\k_means_dis,[\in, i, \out_cen, ~cen_bus[i], \kbuf, ~kme_buf, \ndims, ~n_dims]);
	});
	inf.do({arg i;
		var nor = Array.new(~n_dims);
		var cen = Array.new(~n_dims);
		var dis = Array.new(~n_dims);
		var err = Array.newClear(~kme_k);

		~cla_bus.get({arg j; j.postln;});
		~nor_bus.get({arg j; nor=Array.with(j).at(0);});
		~kme_k.do({arg k;
			~cen_bus[k].get({arg j;//j.postln;
				cen=Array.with(j).at(0);
			});
			0.1.wait;
			"cen: ".post; cen.postln;
		    dis=nor-cen;
			err.put(k,dis.sum);
		});

		~err_bus.setn(err);
		~err_bus.get({arg j; "err: ".post; j.postln;});
		0.01.wait;
		"nor: ".post; nor.postln;

		//~vcvRcvPort.sendMsg("/fader",1,bpm);
		//~vcvRcvPort.sendMsg("/fader",2,beats);
		//~guiRcvPort.sendMsg("/gui",~fea_bus[0]);
		0.1.wait;
	});
}).start;
)

(
// ---------------
// ---- CLOSE ----
// ---------------
//~aud_fil.size.do({arg i;~syn_arr[i].free;});
~kme_k.do({arg i; z[i].free;});
z.free;
y.free;
r.stop;
x.free;
w.free;
v.free;

~mic_bus.free;
~fea_bus.free;
~nor_bus.free;
~cla_bus.free;
~dsm_bus.free;
~kme_k.do({arg i; ~cen_bus[i].free;});

~kme_buf.free;
~vcvRcvPort.disconnect;
Server.killAll;
)


// -------------------------------
// ---- SERVER HELP FUNCTIONS ----
// -------------------------------
s.boot
s.meter
Server.killAll

x.set(\smooth,250);


// Falta:
Puc passar els buffers com a paràmetre?
Automatitzae n_dims i k al synthdef
automatitzar reset, gate, learn

// Modular tamany de buffer per evitar (o no) ritmicitats
// Controlar el rate de lectura dels fitxers

y.set(\rst,1);
y.set(\rst,0);

z.set(\rst,1);
z.set(\rst,0);

z.set(\learn ,1);
z.set(\learn ,0);









































~kbuf = Buffer.alloc(s, 3, 2+1);
k=3;
(
x = {
    var in, fft, trg, fea, kbuf, cla, cen, resynth;

    //sig = AudioIn.ar;
	//sig = Mix.new(SoundIn.ar);
    //sig = PlayBuf.ar(1, b, loop: 1);


	in = Mix.new(SoundIn.ar);//(buf_in));// .tanh;      <-------- Per normalitzar l'entrada?
	//in = PlayBuf.ar(1, b, loop: 1);

	fft   = FFT(LocalBuf(1024), in);
	trg = fft > -0.001;
	//fea = BeatStatistics.kr(fft);
	fea= [MovingAverage.kr(SpecCentroid.kr(fft),100),
		MovingAverage.kr(SpecFlatness.kr(fft),100)];

    //cla = KMeansRT.kr(~kbuf, fea, k, trg);
	cla = MedianTriggered.kr(KMeansRT.kr(~kbuf, fea, k, trg),trig:trg, length:200);

    cla.poll(trg);

	//Out.kr(~cbus, cla);


    // Now we read the centroid position back out of the buffer and sonify
    cen = KMeansRT.getCentroid(~kbuf, cla, 2);//.at(0);
	//cen.poll(trg);


	resynth = SinOsc.ar(cen.at(0), 0, 0.1);
    [in, resynth]
}.play;
)

(
x.stop;
x.free;
~kbuf.close;
~kbuf.free;
)

Server.killAll;







s.options.inDevice = "Built-in Microph";
s.options.inDevice = "EDIROL UA-25";
s.options.inDevice = "BlackHole 16ch";
//s.options.inDevice = "USB Audio CODEC";
s.options.outDevice = "EDIROL UA-25";
s.options.outDevice = "Built-in Output";
//s.options.outDevice = "USB Audio CODEC";

s.boot
s.meter
Server.killAll






b = Buffer.read(s, "/Users/eguaus/Box Sync/Creacio/santpe/audio/Classic Synth Pop/Beats/Synth pop beat 01a (115BPM).wav".standardizePath);

	SynthDef(\conc_play, {arg bufCtl=0, bufIn=0, bufOut=0, dry=0, lag=0.5, amp=1, freeze=0;



(
	SynthDef(\conc_play, {arg bufCtl=0, bufIn=0, bufOut=0, dry=0, lag=0.5, amp=1, freeze=0;
		var control = Mix.new(SoundIn.ar(bufCtl));
		var input= PlayBuf.ar(2,bufIn,BufRateScale.kr(bufIn), loop:1);
		var concat= Concat2.ar(control,input,5.0,5.0,5.0,0.25,freeze,0.2,0.2,0.2,0.2,0.5,0.001);
		var out = XFade2.ar(input,concat,Lag2.kr(dry,lag).linlin(0,1,1,-1),2*Lag2.kr(amp,lag));
		var rev=FreeVerb.ar(out,0.7,0.7,0.01,mul:2);
		Out.ar(bufOut,Pan2.ar(rev,pos: LFNoise2.kr(2)));
	}).add;
)

(
~aud_fld = PathName("/Users/eguaus/Box Sync/Creacio/santpe/audio/test/");
~aud_fil = ~aud_fld.files.collect({arg file; Buffer.read(s, file.fullPath);});
~syn_arr = Array.fill(~aud_fil.size,{arg i;Synth.tail(nil,\conc_play,[\bufIn, ~aud_fil[i]])});
)


// Free
~aud_fil.size.do({arg i;~syn_arr[i].free;});



u=Task({
	inf.do({arg i;

		~cla_bus.get({arg i; i.postln;});
		~cen_bus.get({arg i; i.postln;});
		0.1.wait;
	});
}).start;
)




// -------- GROUP 1: LineIn ------------
~aud_fld  = PathName("/Users/eguaus/Box Sync/Creacio/santpe/audio/train/");
~aud_fil = ~binaural_folder.files.collect({arg file; Buffer.read(s, file.fullPath);});
~binaural_bufnum  = 0;
~binaural_fader   = 0.0;
~binaural_synth   = nil;
~o_drone = OSCdef(\LPD8_knob1,{ arg msg, time, addr, recvPort;
	var value  = msg[1].asFloat.linlin(0,1,0,~binaural_buffers.size).asInteger;
	if(value>0,{
		~binaural_bufnum=value-1;
 		if(~binaural_synth.isPlaying(),{
			~binaural_synth.set(\gate,0);
			~binaural_synth=nil;
			~binaural_synth = Synth.new(\droneReadFile, [
				\amp,      ~binaural_fader,
				\bufnum,   ~binaural_buffers[~binaural_bufnum].bufnum,
				\gate,     1
			]).run.register;
		},{
			~binaural_synth = Synth.new(\droneReadFile, [
				\amp,      ~binaural_fader,
				\bufnum,   ~binaural_buffers[~binaural_bufnum].bufnum,
				\gate,     1
			]).run.register;
		});
	},{
		if(~binaural_synth.isPlaying(),{~binaural_synth.set(\gate,0); ~binaural_bufnum=0;});
	});
},'/LPD8/knob/1',~akaiFromPort);

~o_drone = OSCdef(\LPD8_padOn5,{ arg msg, time, addr, recvPort;
	~binaural_fader = msg[1].asFloat;
	if(~binaural_synth.isPlaying(),{
		~binaural_synth.set(\amp, ~binaural_fader);
	});
},'/LPD8/padOn/5',~akaiFromPort);
*/












// -------- GROUP 1: LineIn ------------
~aud_fld  = PathName("/Users/eguaus/Box Sync/Creacio/santpe/audio/train/");
~aud_fil = ~binaural_folder.files.collect({arg file; Buffer.read(s, file.fullPath);});
~binaural_bufnum  = 0;
~binaural_fader   = 0.0;
~binaural_synth   = nil;
~o_drone = OSCdef(\LPD8_knob1,{ arg msg, time, addr, recvPort;
	var value  = msg[1].asFloat.linlin(0,1,0,~binaural_buffers.size).asInteger;
	if(value>0,{
		~binaural_bufnum=value-1;
 		if(~binaural_synth.isPlaying(),{
			~binaural_synth.set(\gate,0);
			~binaural_synth=nil;
			~binaural_synth = Synth.new(\droneReadFile, [
				\amp,      ~binaural_fader,
				\bufnum,   ~binaural_buffers[~binaural_bufnum].bufnum,
				\gate,     1
			]).run.register;
		},{
			~binaural_synth = Synth.new(\droneReadFile, [
				\amp,      ~binaural_fader,
				\bufnum,   ~binaural_buffers[~binaural_bufnum].bufnum,
				\gate,     1
			]).run.register;
		});
	},{
		if(~binaural_synth.isPlaying(),{~binaural_synth.set(\gate,0); ~binaural_bufnum=0;});
	});
},'/LPD8/knob/1',~akaiFromPort);

~o_drone = OSCdef(\LPD8_padOn5,{ arg msg, time, addr, recvPort;
	~binaural_fader = msg[1].asFloat;
	if(~binaural_synth.isPlaying(),{
		~binaural_synth.set(\amp, ~binaural_fader);
	});
},'/LPD8/padOn/5',~akaiFromPort);
*/










Normalizer
Machine Listening
max

flatdbScaled = LinLin.kr(flatdb, -45, -1.6, 0, 1).max(-10); // Rescale db roughly to 0...1

-16.min(-10)

(
{
    var dt, module, m;
    dt = 0.001;
    module = Dneuromodule(2,
            theta: [MouseX.kr(-2, 2), MouseY.kr(-2, 2)],
            x: [0.1, 0.3],
            weights: [-3, 2, -2, 0]
    );
    m = Duty.ar(dt, 0, module).lag3(dt);
    SinOsc.ar(m * 400 + 600) * 0.1
}.play
)



Platform.userExtensionDir.openOS;





~data = 10000.collect{ if(0.5.coin){[-1, -0.5]}{[1, 0.5]}.collect{|v| v + 0.95.sum3rand} };
GNUPlot.new.scatter(~data)
~data.pc1




1e-9.postln
Array.fill(4, { arg i; i * 2 });


List[1, 2, 3, 4].collect({ arg item, i; item + 10 });










(
// drum pattern
var drums = Pseq([
  [0,1,1,1, 0,1,1,1, 0,1,1,1, 0,1,1,1],
  [1,0,0,0, 1,0,0,0, 1,0,0,0, 1,0,0,0]
], 1);

// bass pattern
var bass = Pseq([60, 62, 64, 67], 1/2);

// SynthDef for the drum machine
SynthDef(\drum, { arg out=0, amp=0.1;
    var sig, env;
    env = EnvGen.kr(Env.perc, 1, doneAction: 2);
    sig = Pulse.ar(drums.kr(8) * 80, 0.1, env);
    Out.ar(out, sig ! 2);
}).add;

// SynthDef for the bassline
SynthDef(\bass, { arg out=0, freq=440, amp=0.1;
    var sig, env;
    env = EnvGen.kr(Env.perc, 1, doneAction: 2);
    sig = Saw.ar(freq, 0, env);
    Out.ar(out, sig ! 2);
}).add;

// SynthDef for the ambient sound
SynthDef(\ambient, { arg out=0, freq=440, amp=0.1;
    var sig, env;
    env = EnvGen.kr(Env.perc, 1, doneAction: 2);
    sig = Dust2.ar(freq,amp) +  SinOsc.ar(freq*2,0,amp);
    sig = HPF.ar(sig, MouseX.kr(20, 20000));
    sig = LPF.ar(sig, MouseY.kr(20, 20000));
    Out.ar(out, sig ! 2);
}).add;

// main code
(
~drum.play(amp: 0.1);
~bass.play(amp: 0.1, freq: bass.asStream);
~ambient.play(amp: 0.1);
)

// schedule to stop after 3 minutes
r = Routine({
  3.minutes.wait;
  Synth.stopAll;
}).play;
)