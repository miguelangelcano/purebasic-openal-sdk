; *** Common OpenAL Framework (OALF)
; Requires PureBasic v4 or later.
; Note: For compatibility with PureBasic v3 include oalf_pb3.pb instead.

; Returns the default OpenAL device name
Procedure.s OALF_GetDefaultDeviceName()
	defaultDeviceName = alcGetString(0, #ALC_DEFAULT_DEVICE_SPECIFIER)
	If defaultDeviceName = 0
		ProcedureReturn ""
	Else
		ProcedureReturn PeekS(defaultDeviceName, -1, #PB_Ascii)
	EndIf
EndProcedure

; Convert a PB string into ASCIIz
Procedure OALF_2ASCIIz(s$)
	*s = AllocateMemory(Len(s$) + 1)
	If *s : PokeS(*s, s$, -1, #PB_Ascii) : EndIf
	ProcedureReturn *s
EndProcedure

; Opens the specified OpenAL device
Procedure OALF_alcOpenDevice(devicename$)
	r = 0
	*DeviceName = OALF_2ASCIIz(devicename$)
	If *DeviceName
		r = alcOpenDevice(*DeviceName)
		FreeMemory(*DeviceName)
	EndIf
	ProcedureReturn r
EndProcedure

; Queries if a specified extension is available
Procedure OALF_alIsExtensionPresent(ext$)
	r = 0
	*Ext = OALF_2ASCIIz(ext$)
	If *Ext
		r = alIsExtensionPresent(*Ext)
		FreeMemory(*Ext)
	EndIf
	ProcedureReturn r
EndProcedure

; Queries if a specified context extension is available
Procedure OALF_alcIsExtensionPresent(device, ext$)
	r = 0
	*Ext = OALF_2ASCIIz(ext$)
	If *Ext
		r = alcIsExtensionPresent(device, *Ext)
		FreeMemory(*Ext)
	EndIf
	ProcedureReturn r
EndProcedure

; Queries if a specified extension is available
Procedure OALF_alGetEnumValue(enum$)
	r = 0
	*Enum = OALF_2ASCIIz(enum$)
	If *Enum
		r = alGetEnumValue(*Enum)
		FreeMemory(*Enum)
	EndIf
	ProcedureReturn r
EndProcedure

; Returns the address of an OpenAL extension function
Procedure OALF_alGetProcAddress(fname$)
	r = 0
	*FName = OALF_2ASCIIz(fname$)
	If *FName
		r = alGetProcAddress(*FName)
		FreeMemory(*FName)
	EndIf
	ProcedureReturn r
EndProcedure

; Wait for user input and return the key code
; 1 - 9 : valid key codes
; 0     : any other key
Procedure OALF_wait4numkeyevent()
	Repeat
		key_pressed$ = Inkey()
		If key_pressed$<>""
			key_pressed = Asc(key_pressed$) - $30
			If key_pressed < 0 Or key_pressed > 9 : key_pressed = 0 : EndIf
			ProcedureReturn key_pressed
		EndIf
		Delay(50)
	ForEver
EndProcedure

; Fill a linked list with the available OpenAL devices names
NewList OALF_devices.s()
; Get a pointer to an array containing the OpenAL available devices names,
; separated by single NULL characters and terminated with a double NULL
OALF_devices = alcGetString(0, #ALC_DEVICE_SPECIFIER)
; Does it support enumerating the available devices?
If OALF_alcIsExtensionPresent(0, "ALC_ENUMERATION_EXT") <> #ALC_FALSE And OALF_devices <> 0
	; Go through the array and add all its entries to our linked list
	Repeat
		OALF_devices$ = PeekS(OALF_devices, -1, #PB_Ascii)
		OALF_i = Len(OALF_devices$)
		If OALF_i = 0 : Break : EndIf
		AddElement(OALF_devices())
		OALF_devices() = OALF_devices$
		OALF_devices + OALF_i + 1
	ForEver
EndIf
ResetList(OALF_devices())
