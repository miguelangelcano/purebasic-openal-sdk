; EFXEnumerate
; ------------
; Shows how to detect support for the effect extension and to find out
; the effect capabilites of the AL device.

; Copy the Pbopenal library to [PureBasic]\PureLibraries\UserLibraries
; before compiling this sample program for the first time.

; Make sure you have OpenAL properly installed before running this
; program. You can download the redistributable OpenAL installer from
; the official OpenAL website: https://www.openal.org/downloads/

; OpenAL constants:
IncludeFile "..\..\include\al.pbi"
IncludeFile "..\..\include\alc.pbi"
IncludeFile "..\..\include\efx.pbi"
IncludeFile "..\..\include\efx-creative.pbi"

; Common OpenAL Framework (OALF) code:
; IncludeFile "..\Framework\framework_pb3.pb" ; PureBasic v3
IncludeFile "..\Framework\framework_pb4.pb" ; PureBasic v4 and newer

Global OAL_function, OAL_obj

; Test if the given Effect/Filter is supported or not.
Procedure TestSupport(s$, al_type, e.l)
	CallCFunctionFast(OAL_function, OAL_obj, al_type, e)
	If alGetError() = #AL_NO_ERROR : s$ + "YES" : Else : s$ + "NO" : EndIf
	PrintN(s$)
EndProcedure

; Initialize Console library.
OpenConsole()
PrintN("Enumerate EFX Application")

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

			; Load some extension functions.
			GenEffects              = OALF_alGetProcAddress("alGenEffects")
			DelEffects              = OALF_alGetProcAddress("alDeleteEffects")
			GenFilters              = OALF_alGetProcAddress("alGenFilters")
			DelFilters              = OALF_alGetProcAddress("alDeleteFilters")
			GenAuxiliaryEffectSlots = OALF_alGetProcAddress("alGenAuxiliaryEffectSlots")
			DelAuxiliaryEffectSlots = OALF_alGetProcAddress("alDeleteAuxiliaryEffectSlots")

			; Check for EFX support.
			If OALF_alcIsExtensionPresent(OAL_device, "ALC_EXT_EFX") And GenEffects And DelEffects And GenFilters And DelFilters And GenAuxiliaryEffectSlots And DelAuxiliaryEffectSlots

				; To determine how many Auxiliary Effects Slots are available,
				; create as many as possible (up To 128) Until the call fails.
				Dim EffectSlots.l(128)
				For iEffectSlotsGenerated = 0 To 128
					CallCFunctionFast(GenAuxiliaryEffectSlots, 1, @EffectSlots(iEffectSlotsGenerated))
					If alGetError() <> #AL_NO_ERROR : Break : EndIf
				Next
				Print(Str(iEffectSlotsGenerated) + " Auxiliary Effect Slot")
				If iEffectSlotsGenerated > 1 Or iEffectSlotsGenerated = 0 : Print("s") : EndIf
				PrintN("")

				; Free the Auxiliary Effect Slots.
				CallCFunctionFast(DelAuxiliaryEffectSlots, iEffectSlotsGenerated, @EffectSlots(0))

				; Retrieve the number of Auxiliary Effect Slots Sends available on each Source.
				iSends = 0
				alcGetIntegerv(OAL_device, #ALC_MAX_AUXILIARY_SENDS, 1, @iSends)
				Print(Str(iSends) + " Auxiliary Send")
				If iSends > 1 Or iSends = 0 : Print("s") : EndIf
				PrintN(" per Source")

				; To determine which Effects are supported, generate an effect object
				; and try to set its type to the various effect enum values.
				CallCFunctionFast(GenEffects, 1, @OAL_obj)
				If alGetError() = #AL_NO_ERROR
					OAL_function = OALF_alGetProcAddress("alEffecti")
					If OAL_function <> 0
						PrintN("")
						PrintN("Effects Supported: -")
						TestSupport(" Reverb            ", #AL_EFFECT_TYPE, #AL_EFFECT_REVERB)
						TestSupport(" EAX Reverb        ", #AL_EFFECT_TYPE, #AL_EFFECT_EAXREVERB)
						TestSupport(" Chorus            ", #AL_EFFECT_TYPE, #AL_EFFECT_CHORUS)
						TestSupport(" Distortion        ", #AL_EFFECT_TYPE, #AL_EFFECT_DISTORTION)
						TestSupport(" Echo              ", #AL_EFFECT_TYPE, #AL_EFFECT_ECHO)
						TestSupport(" Flanger           ", #AL_EFFECT_TYPE, #AL_EFFECT_FLANGER)
						TestSupport(" Frequency Shifter ", #AL_EFFECT_TYPE, #AL_EFFECT_FREQUENCY_SHIFTER)
						TestSupport(" Vocal Morpher     ", #AL_EFFECT_TYPE, #AL_EFFECT_VOCAL_MORPHER)
						TestSupport(" Pitch Shifter     ", #AL_EFFECT_TYPE, #AL_EFFECT_PITCH_SHIFTER)
						TestSupport(" Ring Modulator    ", #AL_EFFECT_TYPE, #AL_EFFECT_RING_MODULATOR)
						TestSupport(" Autowah           ", #AL_EFFECT_TYPE, #AL_EFFECT_AUTOWAH)
						TestSupport(" Compressor        ", #AL_EFFECT_TYPE, #AL_EFFECT_COMPRESSOR)
						TestSupport(" Equalizer         ", #AL_EFFECT_TYPE, #AL_EFFECT_EQUALIZER)
					EndIf

					; Delete effect object
					CallCFunctionFast(DelEffects, 1, @OAL_obj)
				EndIf

				; To determine which Filters are supported, generate a filter object
				; and try to set its type to the various filter enum values.
				CallCFunctionFast(GenFilters, 1, @OAL_obj)
				If alGetError() = #AL_NO_ERROR
					OAL_function = OALF_alGetProcAddress("alFilteri")
					If OAL_function <> 0
						PrintN("")
						PrintN("Filters Supported: -")
						TestSupport(" Low Pass          ", #AL_FILTER_TYPE, #AL_FILTER_LOWPASS)
						TestSupport(" High Pass         ", #AL_FILTER_TYPE, #AL_FILTER_HIGHPASS)
						TestSupport(" Band Pass         ", #AL_FILTER_TYPE, #AL_FILTER_BANDPASS)
					EndIf

					; Delete filter object
					CallCFunctionFast(DelFilters, 1, @OAL_obj)
				EndIf

			Else
				PrintN("-ERR: EFX not supported")
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
