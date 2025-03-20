; SineWave
; --------
; Outputs a simple sinusoidal wave in a loop using a PCM buffer.

; Make sure you have OpenAL properly installed before running the program.
; You can download the redistributable OpenAL installer from the official
; OpenAL website:
;   https://www.openal.org/downloads/

; This example is also compatible with OpenAL Soft, an LGPL-licensed
; implementation of the OpenAL 3D API. The OpenAL Soft can be downloaded
; from the official website:
;   https://openal-soft.org/
; Note: When using OpenAL Soft, rename soft_oal.dll to either
;       openal32.dll (x86) or openal64.dll (x64).

IncludeFile "..\..\include\openal.pbi" ; OpenAL constants

; Initialize Console library
OpenConsole()
PrintN("SineWave Test Application")

; Open the default device
OAL_device = alcOpenDevice(0)
If OAL_device = 0
	PrintN("-ERR: Failed to open the default device")
Else
	; Create a context and make it the current context
	OAL_context = alcCreateContext(OAL_device, 0)
	If OAL_context = 0
		PrintN("-ERR: Failed to create the context")
	Else
		If Not alcMakeContextCurrent(OAL_context)
			PrintN("-ERR: Failed to make context current")
		Else
			; Generate a 16-bit sive wave (PCM format)
			Dim wav.w(1000)
			SR.l = 22000
			L.l = ArraySize(wav())
			F.d = (2 * 3.14159265358979 * 440) / SR
			For T = 0 To L
				wav(T) = 32700 * Sin(F * T)
			Next T

			; Generate an AL buffer
			alGenBuffers(1, @OAL_buffer)
			If alGetError() <> #AL_NO_ERROR
				PrintN("-ERR: Failed to create the buffer")
			Else
				alBufferData(OAL_buffer, #AL_FORMAT_MONO16, wav(), L, SR) ; Load the sine wave into the buffer

				; Generate a source to playback the buffer
				alGenSources(1, @OAL_source)
				If alGetError() <> #AL_NO_ERROR
					PrintN("-ERR: Failed to generate the source")
				Else
					alSourcei(OAL_source, #AL_LOOPING, #AL_TRUE)  ; Enable looping
					alSourcei(OAL_source, #AL_BUFFER, OAL_buffer) ; Bind the source with its buffer
					alSourcePlay(OAL_source)                      ; Start playing
					Print("Playing Source, press any key to exit")
					Repeat
						If Inkey() <> "" : Break : EndIf
						Delay(50)
					ForEver
					alDeleteSources(1, @OAL_source)
				EndIf
				alDeleteBuffers(1, @OAL_buffer)
			EndIf
		EndIf
		alcMakeContextCurrent(0) ; Always deselect the current context before destroying it!
		alcDestroyContext(OAL_context)
	EndIf
	alcCloseDevice(OAL_device)
EndIf

CloseConsole()
End
