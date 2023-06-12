# unsupervAIsed

Pure Data patch for timbre based unsupervised audio classification using k-means with 2, 4 or 8 clusters.

![unsupervAIsed.png](./unsupervAIsed.png)

## Quick start guide

* Install [Pure Data](https://puredata.info/).
* Install [timbreID](https://github.com/wbrent/timbreIDLib), [ml.lib](https://github.com/irllabs/ml-lib) and [zexy](https://git.iem.at/pd/zexy) externals.
* Set your audio device in the Preferences -> Audio menu.
* Edit and select your local path for read/write data and models at the upper-right corner of the patch (optional).
* Activate the "Audio on/off" toggle.
* Activate the "Rec data" toggle and start playing. Please, include all the desired timbres during the performance
* Select the "#clusters# (2,4,8) and push the "Cluster: Bang and Wait" bang.
* Wait for a while until Puredata responds again (please, be patient!)
  * You can save this model by pressing the "Write" button at the upper-right corner of the patch (optional).
  * You can load a previous model by pressing the "Read" button at the upper-right corner of the patch (optional).
* Press the "Play" toggle to start classifying new data
  * Output probabilities (soft scaled between [0..1]) will be automatically mapped in a range [0..127].
  * Numeric values are shown in the green numeric boxes at the mid-right corner of the patch (assigned cluster and proximity).
  * Clusters are visualized in the colorful buttons at the mid-right corner of the patch.

## Sending MIDI
* Set your MIDI device in the Preferences -> MIDI menu.
* Press the "MIDI Out" toggle to start sending data.
  * clusters are sent as midi controls [1..8].
  * proximity are sent as midi data [0..127].
 
 ## Connecting to external apps
 
 ![vcv_example.png](./vcv_example.png)

* Open an external app with possibility to be controlled by external signals (i.e. MIDI or OSC).
* In this example, we propose a simple control of the starting point of the multi file player in VCV.
  * Add the "MIDI MAP" module in your VCV patch.
  * Configure the MIDI listener in the module.
  * Click on the "Unmpapped" icon in the module.
  * Repeat N times (N=number of clusters):
    * in Puredata, set the (red)  "Controller 4 MIDI mapping" selector to the i-th position.
    * in Puredata, move the (red) "value 4 MIDI mapping" value.
    * in VCV, move the knob you want to be remotely controlled.
 
## Dependencies

* [timbreID](https://github.com/wbrent/timbreIDLib): An audio analysis library for Pure Data.
* [ml.lib](https://github.com/irllabs/ml-lib): A library of machine learning externals for Max and Pure Data.
* [zexy](https://git.iem.at/pd/zexy): The swiss army knife for Pure Data.

## TODO List 

* Think good MIDI mapping strategies