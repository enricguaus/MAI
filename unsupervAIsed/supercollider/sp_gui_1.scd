// Title: sp_gui_1.scd
// Author: Enric Guaus
// Created: 17/01/2023
// Description: Bla, bla, bla...
// Use: Bla, bla, bla...

(
// ---- Create Window ----
~mainWdw = Window("SP GUI", Rect(128, 64, 500, 700))
    .onClose_({
	    ~runDes.stop;
	});

~desGra =  MultiSliderView(~mainWdw,Rect(10,10,480,140));
    ~desGra.elasticMode=true;
    ~desGra.drawRects=true;
    ~desGra.isFilled=true;
    ~desGra.editable=true;
    ~desGra.value=Array.fill(~n_dims,{arg i; 0});

~errGra =  MultiSliderView(~mainWdw,Rect(10,150,480,140));
    ~errGra.elasticMode=true;
    ~errGra.drawRects=true;
    ~errGra.isFilled=true;
    ~errGra.editable=true;
    ~errGra.value=Array.fill(~kme_k,{arg i; 0});

~cluBox = NumberBox(~mainWdw, Rect(150, 300, 100, 20));
    ~cluBox.value = 0;

~mainWdw.front;
)

(
// ---- Run graphics ----
~runDes=Routine({
 	inf.do({
		var tmp, tmp2;
		// Print descriptors
		~nor_bus.get({arg i;tmp=i;});
		0.05.wait;
		~desGra.value=Array.fill(~n_dims,{arg j; tmp[j]});
		// Print errors
		~err_bus.get({arg i;tmp=i.abs.log10;});
		0.05.wait;
		~errGra.value=Array.fill(~kme_k,{arg j; tmp[j]});
		// Pint Cluster
		~cla_bus.get({arg i;tmp2=i;});
		0.05.wait;
		~cluBox.value=tmp2;
 	});
}).play(AppClock);
)

(
// ---- Stop graphics ----
~runDes.stop;
~mainWdw.close;
)