## OpenAL Example Source Code

The example code is split into a number of simple applications, each designed to show a key feature of OpenAL.
The Samples directory includes the following: -

**\Media** Wave files used in the examples
**\bin**   Compiled binaries (this directory is created when running `build.bat`)

***

#### Enumerate

Shows how to use the OpenAL device enumeration extension to locate all of the OpenAL devices on the user's system. The code also shows
how to determine the capabilities of each device, including what version of OpenAL each device supports.  

#### PlayStatic

Shows how to use OpenAL to load audio data into an AL buffer and play it using an OpenAL source.  

#### PlayStream

Shows how to use OpenAL's buffer queuing mechanism to stream audio to an OpenAL source.  

#### EFXEnumerate

Shows how to detect support for the effect extension and to find out the effect capabilities of the AL device.  

#### EFXFilter

Shows how to use the EFX extension to create and use a low-pass filter object.  

#### SineWave

Outputs a simple sinusoidal wave in a loop using a PCM buffer.
