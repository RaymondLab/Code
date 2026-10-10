I'm using Rig D241a to test the integrator experiment protocol (since the motor for this rig is set to velocity command).

There are a lot of uncommitted changes on this computer, and I don't want to confuse the version control
So the files in this folder should NOT be committed

The only change I have made outside of this folder is in Parameters_D019.s2s
I changed the sequencer file that it uses
Originally it should be:
var SequencerFile$ := "C:\\Users\\Public\\RaymondLabCode\\Experiment Protocols\\Sequencer_D019";