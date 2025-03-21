; PlayStatic
; ----------
; Shows how to use OpenAL to load audio data into an AL buffer and
; play it using an OpenAL source.

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
IncludeFile "..\..\include\oalf.pb"    ; Common OpenAL Framework (OALF) code
IncludeFile "..\..\include\wave.pb"    ; WAV file format related code

; Initialize Console library
OpenConsole()
PrintN("PlayStatic Test Application")

; See if we have any available OpenAL devices
If ListSize(OALF_devices()) = 0
	PrintN("-ERR: Could not initialize OpenAL")
Else
	; Get the default device name
	defaultDeviceName$ = OALF_GetDefaultDeviceName()

	; Print a menu with the available devices and highlight the default one
	PrintN("")
	PrintN("Select OpenAL device:")
	index = 0
	While NextElement(OALF_devices())
		index + 1
		menu_option$ = Str(index) + ". " + OALF_devices()
		If OALF_devices() = defaultDeviceName$ : menu_option$ + " (DEFAULT)" : EndIf
		PrintN(menu_option$)
	Wend

	; Wait for user input
	key_pressed_code = OALF_wait4numkeyevent()
	If key_pressed_code = 0 Or key_pressed_code > index : CloseConsole() : End : EndIf

	; Open the selected device
	SelectElement(OALF_devices(), key_pressed_code - 1)
	OAL_device = OALF_alcOpenDevice(OALF_devices())
	If OAL_device = 0
		PrintN("-ERR: Could not open the specified device")
	Else
		; Create a context and make it the current context
		OAL_context = alcCreateContext(OAL_device, 0)
		If OAL_context = 0
			PrintN("-ERR: Could not create a context")
		Else
			alcMakeContextCurrent(OAL_context)
			PrintN("")
			PrintN("Opened " + OALF_devices() + " Device")

			; Generate an AL buffer
			alGenBuffers(1, @OAL_buffer)

			; Load wave file
			If alWAVEOpen("..\..\Media\Footsteps.wav") = 0
				PrintN("-ERR: Failed to load the WAV")
			Else
				; Load data into the AL buffer and close the file
				alWAVERead(OAL_buffer, 0)
				alWAVEClose()
				alGenSources(1, @OAL_source)                  ; Generate a source to playback the buffer
				alSourcei(OAL_source, #AL_BUFFER, OAL_buffer) ; Attach source to buffer
				alSourcePlay(OAL_source)                      ; Play source
				Print("Playing Source ")

				; Print a "progress line" while playing the wave
				Repeat
					Delay(100)
					Print(".")
					alGetSourcei(OAL_source, #AL_SOURCE_STATE, @OAL_state)
				Until OAL_state <> #AL_PLAYING
				PrintN("")

				; Clean up by deleting source and buffer
				alDeleteSources(1, @OAL_source)
				alDeleteBuffers(1, @OAL_buffer)
			EndIf
			alcMakeContextCurrent(0) ; Always deselect the current context before destroying it!
			alcDestroyContext(OAL_context)
		EndIf
		alcCloseDevice(OAL_device)
	EndIf
EndIf

PrintN("")
Print("Press any key to exit")
OALF_wait4numkeyevent()
CloseConsole()
End
