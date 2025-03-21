; EFXFilter
; ---------
; Shows how to use the EFX extension to create and use a low-pass
; filter object.

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

Global alFilterf, alFilteri, alIsFilter, alGenFilters, alDelFilters
Global alGenAuxiliaryEffectSlots, alDelAuxiliaryEffectSlots
Global alIsAuxiliaryEffectSlot, alAuxiliaryEffectSloti
Global alGenEffects, alDelEffects, alIsEffect, alEffecti

; Create a filter object
Procedure CreateFilter(filterType, gain.f, gainHF.f)
	alGetError() ; Reset OpenAL error state
	CallCFunctionFast(alGenFilters, 1, @OAL_filter)
	If alGetError() <> #AL_NO_ERROR : ProcedureReturn #AL_FALSE : EndIf
	If CallCFunctionFast(alIsFilter, OAL_filter)
		CallCFunctionFast(alFilteri, OAL_filter, #AL_FILTER_TYPE, filterType)
		If alGetError() <> #AL_NO_ERROR
			CallCFunctionFast(alDelFilters, 1, @OAL_filter)
			ProcedureReturn #AL_FALSE
		EndIf
	EndIf
	CallCFunctionFast(alFilterf, OAL_filter, #AL_LOWPASS_GAIN, gain)
	CallCFunctionFast(alFilterf, OAL_filter, #AL_LOWPASS_GAINHF, gainHF)
	ProcedureReturn OAL_filter
EndProcedure

; Create an effect object
Procedure CreateEffect(effectType, OAL_effectslot)
	alGetError() ; Reset OpenAL error state
	CallCFunctionFast(alGenEffects, 1, @OAL_effect)
	If alGetError() <> #AL_NO_ERROR : ProcedureReturn #AL_FALSE : EndIf
	If CallCFunctionFast(alIsEffect, OAL_effect)
		CallCFunctionFast(alEffecti, OAL_effect, #AL_EFFECT_TYPE, effectType)
		If alGetError() <> #AL_NO_ERROR
			CallCFunctionFast(alDelEffects, 1, @OAL_effect)
			ProcedureReturn #AL_FALSE
		EndIf
		; Load effect into slot.
		If CallCFunctionFast(alIsAuxiliaryEffectSlot, OAL_effectslot)
			CallCFunctionFast(alAuxiliaryEffectSloti, OAL_effectslot, #AL_EFFECTSLOT_EFFECT, OAL_effect)
		EndIf
	EndIf
	ProcedureReturn OAL_effect
EndProcedure

; Wait while OpenAL plays the given source
Procedure Play(OAL_source)
	alSourcePlay(OAL_source)
	Repeat
		Delay(100)
		alGetSourcei(OAL_source, #AL_SOURCE_STATE, @OAL_state)
	Until OAL_state <> #AL_PLAYING
EndProcedure

; Play the source with no filter
Procedure PlayDry(OAL_source)
	PrintN("   Source played dry")
	Play(OAL_source)
EndProcedure

; Play the source with a direct filter
Procedure PlayDirectFilter(OAL_source)
	PrintN("   Source played through a direct lowpass filter")
	OAL_filter = CreateFilter(#AL_FILTER_LOWPASS, 1.0, 0.5)
	If OAL_filter = #AL_FALSE
		PrintN("   -ERR: Could not create the lowpass filter")
	Else
		; Assign filter to the source
		alSourcei(OAL_source, #AL_DIRECT_FILTER, OAL_filter)
		If alGetError() <> #AL_NO_ERROR
			PrintN("   -ERR: Could not assign the lowpass filter")
		Else
			Play(OAL_source)
			alSourcei(OAL_source, #AL_DIRECT_FILTER, #AL_FILTER_NULL) ; Cleanup
		EndIf
		CallCFunctionFast(alDelFilters, 1, @OAL_filter)
	EndIf
EndProcedure

; Play the source through an auxiliary reverb with no filter
Procedure PlayAuxiliaryNoFilter(OAL_source)
	PrintN("   Source played through an auxiliary reverb without filtering")
	CallCFunctionFast(alGenAuxiliaryEffectSlots, 1, @OAL_effectslot)
	OAL_effect = CreateEffect(#AL_EFFECT_REVERB, OAL_effectslot)
	If OAL_effect = #AL_FALSE
		PrintN("   -ERR: Could not create the reverb effect")
	Else
		; Enable Send 0 from the Source to the Auxiliary Effect Slot without filtering
		alSource3i(OAL_source, #AL_AUXILIARY_SEND_FILTER, OAL_effectslot, 0, #AL_FILTER_NULL)
		If alGetError() <> #AL_NO_ERROR
			PrintN("   -ERR: Could not enable send 0")
		Else
			Play(OAL_source)
			alSource3i(OAL_source, #AL_AUXILIARY_SEND_FILTER, #AL_EFFECTSLOT_NULL, 0, #AL_FILTER_NULL) ; Cleanup
		EndIf
		CallCFunctionFast(alDelEffects, 1, @OAL_effect)
	EndIf
	CallCFunctionFast(alDelAuxiliaryEffectSlots, 1, @OAL_effectslot)
EndProcedure

; Play the source through an auxiliary reverb with an auxiliary filter
Procedure PlayAuxiliaryFilter(OAL_source)
	PrintN("   Source played through an auxiliary reverb with lowpass filter")
	CallCFunctionFast(alGenAuxiliaryEffectSlots, 1, @OAL_effectslot)
	OAL_effect = CreateEffect(#AL_EFFECT_REVERB, OAL_effectslot)
	If OAL_effect = #AL_FALSE
		PrintN("   -ERR: Could not create the reverb effect")
	Else
		OAL_filter = CreateFilter(#AL_FILTER_LOWPASS, 1.0, 0.1)
		If OAL_filter = #AL_FALSE
			PrintN("   -ERR: Could not create the lowpass filter")
		Else
			; Enable Send 0 from the Source to the Auxiliary Effect Slot without filtering
			alSource3i(OAL_source, #AL_AUXILIARY_SEND_FILTER, OAL_effectslot, 0, OAL_filter)
			If alGetError() <> #AL_NO_ERROR
				PrintN("   -ERR: Could not enable send 0")
			Else
				Play(OAL_source)
				alSource3i(OAL_source, #AL_AUXILIARY_SEND_FILTER, #AL_EFFECTSLOT_NULL, 0, #AL_FILTER_NULL) ; Cleanup
			EndIf
			CallCFunctionFast(alDelFilters, 1, @OAL_filter)
		EndIf
		CallCFunctionFast(alDelEffects, 1, @OAL_effect)
	EndIf
	CallCFunctionFast(alDelAuxiliaryEffectSlots, 1, @OAL_effectslot)
EndProcedure

; Initialize Console library
OpenConsole()

; See if we have any available OpenAL devices
If ListSize(OALF_devices()) = 0
	PrintN("-ERR: Could not initialize OpenAL")
Else
	; Get the default device name
	defaultDeviceName$ = OALF_GetDefaultDeviceName()

	; Print a menu with the available devices and highlight the default one
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

			; Load some extension functions
			alFilterf    = OALF_alGetProcAddress("alFilterf")
			alFilteri    = OALF_alGetProcAddress("alFilteri")
			alIsFilter   = OALF_alGetProcAddress("alIsFilter")
			alGenFilters = OALF_alGetProcAddress("alGenFilters")
			alDelFilters = OALF_alGetProcAddress("alDeleteFilters")
			alEffecti    = OALF_alGetProcAddress("alEffecti")
			alIsEffect   = OALF_alGetProcAddress("alIsEffect")
			alGenEffects = OALF_alGetProcAddress("alGenEffects")
			alDelEffects = OALF_alGetProcAddress("alDeleteEffects")
			alAuxiliaryEffectSloti    = OALF_alGetProcAddress("alAuxiliaryEffectSloti")
			alIsAuxiliaryEffectSlot   = OALF_alGetProcAddress("alIsAuxiliaryEffectSlot")
			alGenAuxiliaryEffectSlots = OALF_alGetProcAddress("alGenAuxiliaryEffectSlots")
			alDelAuxiliaryEffectSlots = OALF_alGetProcAddress("alDeleteAuxiliaryEffectSlots")
			If alFilterf And alFilteri And alIsFilter And alGenFilters And alDelFilters And alGenAuxiliaryEffectSlots And alDelAuxiliaryEffectSlots And alEffecti And alIsEffect And alGenEffects And alDelEffects And alAuxiliaryEffectSloti And alIsAuxiliaryEffectSlot

				; Load wave file
				If alWAVEOpen("..\..\Media\Footsteps.wav") = 0
					PrintN("-ERR: Failed to load the WAV")
				Else
					; Load data into the AL buffer and close the file
					alWAVERead(OAL_buffer, 0)
					alWAVEClose()
					alGenSources(1, @OAL_source)      ; Generate a source to playback the buffer
					alSourcei(OAL_source, #AL_BUFFER, OAL_buffer) ; Attach source to buffer
					PlayDry(OAL_source)               ; Play the source with no filter
					PlayDirectFilter(OAL_source)      ; Play the source with a direct filter
					PlayAuxiliaryNoFilter(OAL_source) ; Play the source through an auxiliary reverb with no filter
					PlayAuxiliaryFilter(OAL_source)   ; Play the source through an auxiliary reverb with an auxiliary filter
					; Clean up by deleting source and buffer
					alDeleteSources(1, @OAL_source)
					alDeleteBuffers(1, @OAL_buffer)
				EndIf
			Else
				PrintN("-ERR: Filters not supported")
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
