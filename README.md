[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14248943.svg)](https://doi.org/10.5281/zenodo.14248943)
[![SWH](https://archive.softwareheritage.org/badge/swh:1:dir:359a9a5d5297e96d1c47966341d3987628528472/)](https://archive.softwareheritage.org/swh:1:dir:359a9a5d5297e96d1c47966341d3987628528472;origin=https://doi.org/10.5281/zenodo.14248943;visit=swh:1:snp:81b1b9aaef6272680ca41ef01df14b5420f712bb;anchor=swh:1:rel:ef1a05e09dc2576ae9995c38c0863d221b764010;path=/)

# OpenAL SDK for PureBasic, 32 and 64-bit (Windows)

<img src='https://implib.sourceforge.io/OpenAL.png' align='left' hspace='8' vspace='3' alt="OpenAL"> **OpenAL** (for "Open Audio Library") is a cross-platform audio API complementary to OpenGL. It was specifically designed to render multichannel output of 3D arrangements of sound sources around the listener.  

The SDK is compatible with the original OpenAL v1.0 and v1.1 and [OpenAL Soft](https://openal-soft.org/). The SDK includes the header files, API documentation and usage examples. The `openal32.dll` is not included, but it can be downloaded for free from the official OpenAL or OpenAL Soft websites.  

**Note:** When using this SDK with PureBasic **v6.10 LTS** or earlier, it's necessary to set to `0` the following configuration option in `src\openal32.def` and `src\openal64.def` before compiling the OpenAL library:  

`RENAME_AR_MEMBERS equ 1`

This is necessary for compatibility with the linker used in the previous PureBasic releases. Since PureBasic **v6.11** the linker is *lld-link*, while earlier versions used *polink*.  

Make sure you have OpenAL installed before running the included examples. The redistributable OpenAL installer is available at the official [OpenAL website](https://www.openal.org/downloads/).
[Mirror](http://web.archive.org/web/20080523200706/developer.creative.com/landing.asp?cat=1&sbcat=31&top=38). The SDK is also compatible with **OpenAL Soft**, an LGPL-licensed implementation of the  OpenAL 3D API. The OpenAL Soft can be downloaded from its official [website](https://openal-soft.org/).  

Current release contains a complete  OpenAL API reference, which you can copy to your PureBasic Help directory to enable inline access from the IDE.  

Feel free to use this SDK for any purpose you like. There is no copyright notice because this SDK is in the public domain. It is available for free without any conditions or restrictions. However, the ```openal32.dll``` does have a license. Please, check the license if you need to redistribute the DLL.
