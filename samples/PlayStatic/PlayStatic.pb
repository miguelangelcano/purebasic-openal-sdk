; PlayStatic
; ----------
; Shows how to use OpenAL to load audio data into an AL buffer and
; play it using an OpenAL source.

; Copy the Pbopenal library to [PureBasic]\PureLibraries\UserLibraries
; before compiling this sample program for the first time.

; Make sure you have OpenAL properly installed before running this
; program. You can download the redistributable OpenAL installer from
; the official OpenAL website: https://www.openal.org/downloads/

; OpenAL constants:
IncludeFile "..\..\include\al.pbi"
IncludeFile "..\..\include\alc.pbi"

; Common OpenAL Framework (OALF) code:
; IncludeFile "..\Framework\framework_pb3.pb" ; PureBasic v3
IncludeFile "..\Framework\framework_pb4.pb" ; PureBasic v4 and newer

; Common WAV file format related code:
; IncludeFile "..\Framework\wave_pb3.pb" ; PureBasic v3
IncludeFile "..\Framework\wave_pb4.pb" ; PureBasic v4 and newer

wavfile$ = "Footsteps.wav"

; Initialize Console library.
OpenConsole()
PrintN("PlayStatic Test Application")

; See if we have any available OpenAL devices.
If ListSize(OALF_devices()) = 0
	PrintN("-ERR: Could not initialize OpenAL")
Else

	; Get the default device name.
	defaultDeviceName$ = OALF_GetDefaultDeviceName()

	; Print a menu with the available devices and highlight the default one.
	PrintN("")
	PrintN("Select OpenAL device:")
	index = 0
	While NextElement(OALF_devices())
		index + 1
		menu_option$ = Str(index) + ". " + OALF_devices()
		If OALF_devices() = defaultDeviceName$ : menu_option$ + " (DEFAULT)" : EndIf
		PrintN(menu_option$)
	Wend

	; Wait for user input.
	key_pressed_code = OALF_wait4numkeyevent()
	If key_pressed_code = 0 Or key_pressed_code > index : CloseConsole() : End : EndIf

	; Open the selected device.
	SelectElement(OALF_devices(), key_pressed_code - 1)
	OAL_device = OALF_alcOpenDevice(OALF_devices())
	If OAL_device = 0
		PrintN("-ERR: Could not open the specified device")
	Else

		; Create a context and make it the current context.
		OAL_context = alcCreateContext(OAL_device, 0)
		If OAL_context = 0
			PrintN("-ERR: Could not create a context")
		Else

			alcMakeContextCurrent(OAL_context)
			PrintN("")
			PrintN("Opened " + OALF_devices() + " Device")

			; Generate an AL buffer.
			alGenBuffers(1, @OAL_buffer)

			; Load wave file.
			If alWAVEOpen("..\Media\" + wavfile$) = 0
				PrintN("-ERR: Failed to load " + wavfile$)
			Else

				; Load data into the AL buffer and close the file.
				alWAVERead(OAL_buffer, 0)
				alWAVEClose()

				; Generate a source to playback the buffer.
				alGenSources(1, @OAL_source)

				; Attach source to buffer.
				alSourcei(OAL_source, #AL_BUFFER, OAL_buffer)

				; Play source.
				alSourcePlay(OAL_source)
				Print("Playing Source ")

				; Print a "progress line" while playing the wave.
				Repeat
					Delay(100)
					Print(".")
					alGetSourcei(OAL_source, #AL_SOURCE_STATE, @OAL_state)
				Until OAL_state <> #AL_PLAYING
				PrintN("")

				; Clean up by deleting source and buffer.
				alSourceStop(OAL_source)
				alDeleteSources(1, @OAL_source)
				alDeleteBuffers(1, @OAL_buffer)

			EndIf

			; Always deselect the current context before destroying it!
			alcMakeContextCurrent(0)
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
