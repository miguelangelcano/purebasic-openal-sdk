; *** PureBasic v4 and newer

; RIFF\WAVE\FMT structure:
Structure WAVE_FMT
	wFormatTag.w
	nChannels.w
	nSamplesPerSec.l
	nAvgBytesPerSec.l
	nBlockAlign.w
	wBitsPerSample.w
EndStructure

; Channel mapping:
#WAVE_FORMAT_PCM        = 1
#WAVE_FORMAT_EXTENSIBLE = $FFFE
#SPEAKER_FRONT_LEFT     = 1
#SPEAKER_FRONT_RIGHT    = 2
#SPEAKER_FRONT_CENTER   = 4
#SPEAKER_LOW_FREQUENCY  = 8
#SPEAKER_BACK_LEFT      = $10
#SPEAKER_BACK_RIGHT     = $20
#SPEAKER_BACK_CENTER    = $100
#SPEAKER_SIDE_LEFT      = $200
#SPEAKER_SIDE_RIGHT     = $400

Global alWAVE_file, alWAVE_size, alWAVE_format, alWAVE_frequency, alWAVE_bytespersample

; Read up to num_samples samples into the specified AL buffer.
; If num_samples is 0, reads all the samples available.
; Returns the number of bytes actually read.
; For example:
;    @ 8-bit  mono   -> 1 sample = 1 byte
;    @ 16-bit mono   -> 1 sample = 2 bytes
;    @ 8-bit  stereo -> 1 sample = 2 bytes
;    @ 16-bit stereo -> 1 sample = 4 bytes
; Returns 0 when no more samples could be read.
; This might be useful for EOF testing.
Procedure alWAVERead(OAL_buffer, num_samples)
	If alWAVE_file = 0 Or alWAVE_size = 0 : ProcedureReturn 0 : EndIf
	r = num_samples * alWAVE_bytespersample
	If r = 0 : r = alWAVE_size : EndIf
	*Buf = AllocateMemory(r)
	If *Buf
		r = ReadData(alWAVE_file, *Buf, r)
		alBufferData(OAL_buffer, alWAVE_format, *Buf, r, alWAVE_frequency)
		If alGetError() = #AL_NO_ERROR : alWAVE_size - r : Else : r = 0 : EndIf
		FreeMemory(*Buf)
	Else : r = 0 : EndIf
	ProcedureReturn r
EndProcedure

; Close the wave file
Procedure alWAVEClose()
	If alWAVE_file <> 0 : CloseFile(alWAVE_file) : alWAVE_file = 0 : EndIf
EndProcedure

; Load the specified wave file into an AL buffer.
Procedure alWAVEOpen(filename.s)
	alWAVE_size          = 0
	alWAVE_data          = 0
	alWAVE_fmt_processed = 0
	r                    = 0
	alWAVE_file = ReadFile(#PB_Any, filename)
	If alWAVE_file
		wav_l0 = ReadLong(alWAVE_file) ; RIFF
		wav_l1 = ReadLong(alWAVE_file) ; size (skip)

		; Is it a valid RIFF\WAVE?
		If wav_l0 = $46464952 And ReadLong(alWAVE_file) = $45564157

			; Iterate through all the available chunks until
			; EOF or until we've read FMT and DATA.
			While Eof(alWAVE_file) = 0
				wav_l0 = ReadLong(alWAVE_file) ; ckID
				wav_l1 = ReadLong(alWAVE_file) ; size
				wav_current_loc = Loc(alWAVE_file)
				wav_next_chunk = wav_l1 + wav_current_loc
				Select wav_l0

					; 'fmt '
					Case $20746D66
						ReadData(alWAVE_file, @wave_fmt.WAVE_FMT, SizeOf(WAVE_FMT))
						alWAVE_frequency = wave_fmt\nSamplesPerSec
						Select wave_fmt\wFormatTag

							; Ordinar PCM (no compression):
							Case #WAVE_FORMAT_PCM
								Select wave_fmt\nChannels
									; Mono
									Case 1
										If wave_fmt\wBitsPerSample = 16
											alWAVE_format = OALF_alGetEnumValue("AL_FORMAT_MONO16")
											alWAVE_bytespersample = 2
										Else
											alWAVE_format = OALF_alGetEnumValue("AL_FORMAT_MONO8")
											alWAVE_bytespersample = 1
										EndIf
									; Stereo
									Case 2
										If wave_fmt\wBitsPerSample = 16
											alWAVE_format = OALF_alGetEnumValue("AL_FORMAT_STEREO16")
											alWAVE_bytespersample = 4
										Else
											alWAVE_format = OALF_alGetEnumValue("AL_FORMAT_STEREO8")
											alWAVE_bytespersample = 2
										EndIf
									; Quad
									Case 4
										If wave_fmt\wBitsPerSample = 16
											alWAVE_format = OALF_alGetEnumValue("AL_FORMAT_QUAD16")
											alWAVE_bytespersample = 8
										EndIf
								EndSelect

							; Extensible subformat:
							Case #WAVE_FORMAT_EXTENSIBLE
								dwChannelMask = ReadLong(alWAVE_file) ; skip cbSize and wReserved
								dwChannelMask = ReadLong(alWAVE_file)

								Select wave_fmt\nChannels
									; Mono
									Case 1
										If dwChannelMask = #SPEAKER_FRONT_CENTER
											If wave_fmt\wBitsPerSample = 16
												alWAVE_format = OALF_alGetEnumValue("AL_FORMAT_MONO16")
												alWAVE_bytespersample = 2
											Else
												alWAVE_format = OALF_alGetEnumValue("AL_FORMAT_MONO8")
												alWAVE_bytespersample = 1
											EndIf
										EndIf
									; Stereo
									Case 2
										If dwChannelMask = #SPEAKER_FRONT_LEFT | #SPEAKER_FRONT_RIGHT
											If wave_fmt\wBitsPerSample = 16
												alWAVE_format = OALF_alGetEnumValue("AL_FORMAT_STEREO16")
												alWAVE_bytespersample = 4
											Else
												alWAVE_format = OALF_alGetEnumValue("AL_FORMAT_STEREO8")
												alWAVE_bytespersample = 2
											EndIf
										ElseIf dwChannelMask = #SPEAKER_BACK_LEFT | #SPEAKER_BACK_RIGHT
											If wave_fmt\wBitsPerSample = 16
												alWAVE_format = OALF_alGetEnumValue("AL_FORMAT_REAR16")
												alWAVE_bytespersample = 4
											EndIf
										EndIf
									; Quad
									Case 4
										If dwChannelMask = #SPEAKER_FRONT_LEFT | #SPEAKER_FRONT_RIGHT | #SPEAKER_BACK_LEFT | #SPEAKER_BACK_RIGHT
											If wave_fmt\wBitsPerSample = 16
												alWAVE_format = OALF_alGetEnumValue("AL_FORMAT_QUAD16")
												alWAVE_bytespersample = 8
											EndIf
										EndIf
									; 5.1
									Case 6
										If dwChannelMask = #SPEAKER_FRONT_LEFT | #SPEAKER_FRONT_RIGHT | #SPEAKER_FRONT_CENTER | #SPEAKER_LOW_FREQUENCY | #SPEAKER_BACK_LEFT | #SPEAKER_BACK_RIGHT
											If wave_fmt\wBitsPerSample = 16
												alWAVE_format = OALF_alGetEnumValue("AL_FORMAT_51CHN16")
												alWAVE_bytespersample = 12
											EndIf
										EndIf
									; 6.1
									Case 7
										If dwChannelMask = #SPEAKER_FRONT_LEFT | #SPEAKER_FRONT_RIGHT | #SPEAKER_FRONT_CENTER | #SPEAKER_LOW_FREQUENCY | #SPEAKER_BACK_LEFT | #SPEAKER_BACK_RIGHT | #SPEAKER_BACK_CENTER
											If wave_fmt\wBitsPerSample = 16
												alWAVE_format = OALF_alGetEnumValue("AL_FORMAT_61CHN16")
												alWAVE_bytespersample = 14
											EndIf
										EndIf
									; 7.1
									Case 8
										If dwChannelMask = #SPEAKER_FRONT_LEFT | #SPEAKER_FRONT_RIGHT | #SPEAKER_FRONT_CENTER | #SPEAKER_LOW_FREQUENCY | #SPEAKER_BACK_LEFT | #SPEAKER_BACK_RIGHT | #SPEAKER_SIDE_LEFT | #SPEAKER_SIDE_RIGHT
											If wave_fmt\wBitsPerSample = 16
												alWAVE_format = OALF_alGetEnumValue("AL_FORMAT_71CHN16")
												alWAVE_bytespersample = 16
											EndIf
										EndIf
								EndSelect

						EndSelect

						; Unsupported or invalid WAVE file format.
						If alWAVE_format = 0 : Break : EndIf
						alWAVE_fmt_processed = 1

					; 'data'
					Case $61746164
						alWAVE_data = wav_current_loc
						alWAVE_size = wav_l1

				EndSelect

				; Got everything required to load the WAVE data?
				If alWAVE_fmt_processed = 1 And alWAVE_data <> 0
					FileSeek(alWAVE_file, alWAVE_data) : r = 1 : Break
				EndIf

				; Goto next chunk.
				FileSeek(alWAVE_file, wav_next_chunk)
			Wend

		EndIf
	EndIf
	ProcedureReturn r
EndProcedure
