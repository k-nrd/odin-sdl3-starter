package faudio

import "core:c"

/*
 * FAudio - Consolidated bindings for the FAudio library
 *
 * This file contains all Odin bindings for FAudio, an XAudio reimplementation that
 * focuses on a cross-platform, open-source implementation of the XAudio APIs.
 */

/* When on Windows, use FAudio.dll, otherwise use system:FAudio */
when ODIN_OS == .Windows {
	@(export)
	foreign import lib "FAudio.lib"
} else {
	@(export)
	foreign import lib "system:FAudio"
}

/* FAudio Core API */

/* Enumerations */

FAudioDeviceRole :: enum c.int {
	NotDefaultDevice            = 0x0,
	DefaultConsoleDevice        = 0x1,
	DefaultMultimediaDevice     = 0x2,
	DefaultCommunicationsDevice = 0x4,
	DefaultGameDevice           = 0x8,
	GlobalDefaultDevice         = 0xF,
	InvalidDeviceRole           = ~c.int(0xF),
}

FAudioFilterType :: enum c.int {
	LowPassFilter,
	BandPassFilter,
	HighPassFilter,
	NotchFilter,
}

/* Structures */

FAudioGUID :: struct #packed {
	Data1: u32,
	Data2: u16,
	Data3: u16,
	Data4: [8]u8,
}

FAudioWaveFormatEx :: struct #packed {
	wFormatTag:      u16,
	nChannels:       u16,
	nSamplesPerSec:  u32,
	nAvgBytesPerSec: u32,
	nBlockAlign:     u16,
	wBitsPerSample:  u16,
	cbSize:          u16,
}

FAudioWaveFormatExtensible :: struct #packed {
	Format:        FAudioWaveFormatEx,
	Samples:       struct #raw_union {
		wValidBitsPerSample: u16,
		wSamplesPerBlock:    u16,
		wReserved:           u16,
	},
	dwChannelMask: u32,
	SubFormat:     FAudioGUID,
}

FAudioADPCMCoefSet :: struct #packed {
	iCoef1: i16,
	iCoef2: i16,
}

FAudioADPCMWaveFormat :: struct #packed {
	wfx:              FAudioWaveFormatEx,
	wSamplesPerBlock: u16,
	wNumCoef:         u16,
	aCoef:            ^FAudioADPCMCoefSet,
}

FAudioXMA2WaveFormatEx :: struct #packed {
	wfx:              FAudioWaveFormatEx,
	wNumStreams:      u16,
	dwChannelMask:    u32,
	dwSamplesEncoded: u32,
	dwBytesPerBlock:  u32,
	dwPlayBegin:      u32,
	dwPlayLength:     u32,
	dwLoopBegin:      u32,
	dwLoopLength:     u32,
	bLoopCount:       u8,
	bEncoderVersion:  u8,
	wBlockCount:      u16,
}

FAudioDeviceDetails :: struct #packed {
	DeviceID:     [256]i16, /* Win32 wchar_t */
	DisplayName:  [256]i16, /* Win32 wchar_t */
	Role:         FAudioDeviceRole,
	OutputFormat: FAudioWaveFormatExtensible,
}

FAudioVoiceDetails :: struct #packed {
	CreationFlags:   u32,
	ActiveFlags:     u32,
	InputChannels:   u32,
	InputSampleRate: u32,
}

FAudioSendDescriptor :: struct #packed {
	Flags:        u32,
	pOutputVoice: ^FAudioVoice,
}

FAudioVoiceSends :: struct #packed {
	SendCount: u32,
	pSends:    ^FAudioSendDescriptor,
}

FAudioEffectDescriptor :: struct #packed {
	pEffect:        rawptr,
	InitialState:   c.int,
	OutputChannels: u32,
}

FAudioEffectChain :: struct #packed {
	EffectCount:        u32,
	pEffectDescriptors: ^FAudioEffectDescriptor,
}

FAudioFilterParameters :: struct #packed {
	Type:      FAudioFilterType,
	Frequency: f32,
	OneOverQ:  f32,
}

FAudioBuffer :: struct #packed {
	Flags:      u32,
	AudioBytes: u32,
	pAudioData: ^u8,
	PlayBegin:  u32,
	PlayLength: u32,
	LoopBegin:  u32,
	LoopLength: u32,
	LoopCount:  u32,
	pContext:   rawptr,
}

FAudioBufferWMA :: struct #packed {
	pDecodedPacketCumulativeBytes: ^u32,
	PacketCount:                   u32,
}

FAudioVoiceState :: struct #packed {
	pCurrentBufferContext: rawptr,
	BuffersQueued:         u32,
	SamplesPlayed:         u64,
}

FAudioPerformanceData :: struct #packed {
	AudioCyclesSinceLastQuery:  u64,
	TotalCyclesSinceLastQuery:  u64,
	MinimumCyclesPerQuantum:    u32,
	MaximumCyclesPerQuantum:    u32,
	MemoryUsageInBytes:         u32,
	CurrentLatencyInSamples:    u32,
	GlitchesSinceEngineStarted: u32,
	ActiveSourceVoiceCount:     u32,
	TotalSourceVoiceCount:      u32,
	ActiveSubmixVoiceCount:     u32,
	ActiveResamplerCount:       u32,
	ActiveMatrixMixCount:       u32,
	ActiveXmaSourceVoices:      u32,
	ActiveXmaStreams:           u32,
}

FAudioDebugConfiguration :: struct #packed {
	TraceMask:       u32,
	BreakMask:       u32,
	LogThreadID:     c.int,
	LogFileline:     c.int,
	LogFunctionName: c.int,
	LogTiming:       c.int,
}

/* Opaque Types */

FAudio :: struct {}
FAudioVoice :: struct {}
FAudioSourceVoice :: FAudioVoice
FAudioSubmixVoice :: FAudioVoice
FAudioMasteringVoice :: FAudioVoice
FAudioEngineCallbackObj :: struct {}
FAudioVoiceCallbackObj :: struct {}
FAudioEffectChainObj :: struct {}
FAPOBase :: struct {}
FACTEngine :: struct {}
FACTSoundBank :: struct {}
FACTWaveBank :: struct {}
FACTCue :: struct {}
FACTWave :: struct {}

/* Constants */

/* Speaker Positions */
SPEAKER_FRONT_LEFT :: 0x00000001
SPEAKER_FRONT_RIGHT :: 0x00000002
SPEAKER_FRONT_CENTER :: 0x00000004
SPEAKER_LOW_FREQUENCY :: 0x00000008
SPEAKER_BACK_LEFT :: 0x00000010
SPEAKER_BACK_RIGHT :: 0x00000020
SPEAKER_FRONT_LEFT_OF_CENTER :: 0x00000040
SPEAKER_FRONT_RIGHT_OF_CENTER :: 0x00000080
SPEAKER_BACK_CENTER :: 0x00000100
SPEAKER_SIDE_LEFT :: 0x00000200
SPEAKER_SIDE_RIGHT :: 0x00000400
SPEAKER_TOP_CENTER :: 0x00000800
SPEAKER_TOP_FRONT_LEFT :: 0x00001000
SPEAKER_TOP_FRONT_CENTER :: 0x00002000
SPEAKER_TOP_FRONT_RIGHT :: 0x00004000
SPEAKER_TOP_BACK_LEFT :: 0x00008000
SPEAKER_TOP_BACK_CENTER :: 0x00010000
SPEAKER_TOP_BACK_RIGHT :: 0x00020000

/* Speaker Configurations */
SPEAKER_MONO :: SPEAKER_FRONT_CENTER
SPEAKER_STEREO :: (SPEAKER_FRONT_LEFT | SPEAKER_FRONT_RIGHT)
SPEAKER_2POINT1 :: (SPEAKER_FRONT_LEFT | SPEAKER_FRONT_RIGHT | SPEAKER_LOW_FREQUENCY)
SPEAKER_SURROUND ::
	(SPEAKER_FRONT_LEFT | SPEAKER_FRONT_RIGHT | SPEAKER_FRONT_CENTER | SPEAKER_BACK_CENTER)
SPEAKER_QUAD :: (SPEAKER_FRONT_LEFT | SPEAKER_FRONT_RIGHT | SPEAKER_BACK_LEFT | SPEAKER_BACK_RIGHT)
SPEAKER_4POINT1 ::
	(SPEAKER_FRONT_LEFT |
		SPEAKER_FRONT_RIGHT |
		SPEAKER_LOW_FREQUENCY |
		SPEAKER_BACK_LEFT |
		SPEAKER_BACK_RIGHT)
SPEAKER_5POINT1 ::
	(SPEAKER_FRONT_LEFT |
		SPEAKER_FRONT_RIGHT |
		SPEAKER_FRONT_CENTER |
		SPEAKER_LOW_FREQUENCY |
		SPEAKER_BACK_LEFT |
		SPEAKER_BACK_RIGHT)
SPEAKER_7POINT1 ::
	(SPEAKER_FRONT_LEFT |
		SPEAKER_FRONT_RIGHT |
		SPEAKER_FRONT_CENTER |
		SPEAKER_LOW_FREQUENCY |
		SPEAKER_BACK_LEFT |
		SPEAKER_BACK_RIGHT |
		SPEAKER_FRONT_LEFT_OF_CENTER |
		SPEAKER_FRONT_RIGHT_OF_CENTER)
SPEAKER_5POINT1_SURROUND ::
	(SPEAKER_FRONT_LEFT |
		SPEAKER_FRONT_RIGHT |
		SPEAKER_FRONT_CENTER |
		SPEAKER_LOW_FREQUENCY |
		SPEAKER_SIDE_LEFT |
		SPEAKER_SIDE_RIGHT)
SPEAKER_7POINT1_SURROUND ::
	(SPEAKER_FRONT_LEFT |
		SPEAKER_FRONT_RIGHT |
		SPEAKER_FRONT_CENTER |
		SPEAKER_LOW_FREQUENCY |
		SPEAKER_BACK_LEFT |
		SPEAKER_BACK_RIGHT |
		SPEAKER_SIDE_LEFT |
		SPEAKER_SIDE_RIGHT)

/* Max audio channels */
FAUDIO_MAX_BUFFER_CHANNELS :: 64
FAUDIO_MAX_AUDIO_CHANNELS :: 64

/* Default sample rate */
FAUDIO_DEFAULT_SAMPLE_RATE :: 48000

/* Format tags */
FAUDIO_FORMAT_PCM :: 1
FAUDIO_FORMAT_MSADPCM :: 2
FAUDIO_FORMAT_IEEE_FLOAT :: 3
FAUDIO_FORMAT_WMAUDIO2 :: 0x0161
FAUDIO_FORMAT_WMAUDIO3 :: 0x0162
FAUDIO_FORMAT_XMAUDIO2 :: 0x0166
FAUDIO_FORMAT_EXTENSIBLE :: 0xFFFE

/* FAudio version constants */
VERSION_MAJOR :: 21
VERSION_MINOR :: 03

/* FAudio version */
FAUDIO_MAJOR_VERSION :: 25
FAUDIO_MINOR_VERSION :: 3
FAUDIO_PATCH_VERSION :: 0

/* Core Functions */

@(default_calling_convention = "c")
foreign lib {
	FAudioCreate :: proc(ppFAudio: ^^FAudio, Flags: u32, ProcessingMode: c.int) -> u32 ---
	FAudioCreateWithCustomAllocatorEXT :: proc(ppFAudio: ^^FAudio, Flags: u32, ProcessingMode: c.int, pMemAlloc: rawptr, pMemFree: rawptr, pMemRealloc: rawptr) -> u32 ---
	FAudioCOMConstructWithCustomAllocatorEXT :: proc(ppv: ^rawptr, pMemAlloc: rawptr, pMemFree: rawptr, pMemRealloc: rawptr) -> u32 ---
	FAudio_AddRef :: proc(audio: ^FAudio) -> u32 ---
	FAudio_Release :: proc(audio: ^FAudio) -> u32 ---
	FAudio_GetDeviceCount :: proc(audio: ^FAudio, pCount: ^u32) -> u32 ---
	FAudio_GetDeviceDetails :: proc(audio: ^FAudio, Index: u32, pDeviceDetails: ^FAudioDeviceDetails) -> u32 ---
	FAudio_Initialize :: proc(audio: ^FAudio, Flags: u32, XAudio2Processor: c.int) -> u32 ---
	FAudio_RegisterForCallbacks :: proc(audio: ^FAudio, pCallback: ^FAudioEngineCallbackObj) -> u32 ---
	FAudio_UnregisterForCallbacks :: proc(audio: ^FAudio, pCallback: ^FAudioEngineCallbackObj) -> u32 ---
	FAudio_CreateSourceVoice :: proc(audio: ^FAudio, ppSourceVoice: ^^FAudioSourceVoice, pSourceFormat: ^FAudioWaveFormatEx, Flags: u32, MaxFrequencyRatio: f32, pCallback: ^FAudioVoiceCallbackObj, pSendList: ^FAudioVoiceSends, pEffectChain: ^FAudioEffectChain) -> u32 ---
	FAudio_CreateSubmixVoice :: proc(audio: ^FAudio, ppSubmixVoice: ^^FAudioSubmixVoice, InputChannels: u32, InputSampleRate: u32, Flags: u32, ProcessingStage: u32, pSendList: ^FAudioVoiceSends, pEffectChain: ^FAudioEffectChain) -> u32 ---
	FAudio_CreateMasteringVoice :: proc(audio: ^FAudio, ppMasteringVoice: ^^FAudioMasteringVoice, InputChannels: u32, InputSampleRate: u32, Flags: u32, DeviceIndex: u32, pEffectChain: ^FAudioEffectChain) -> u32 ---
	FAudio_StartEngine :: proc(audio: ^FAudio) -> u32 ---
	FAudio_StopEngine :: proc(audio: ^FAudio) -> u32 ---
	FAudio_CommitChanges :: proc(audio: ^FAudio) -> u32 ---
	FAudio_GetPerformanceData :: proc(audio: ^FAudio, pPerfData: ^FAudioPerformanceData) -> u32 ---
	FAudio_SetDebugConfiguration :: proc(audio: ^FAudio, pDebugConfiguration: ^FAudioDebugConfiguration, pReserved: rawptr) ---
}

/* FAudioVoice Functions */

@(default_calling_convention = "c")
foreign lib {
	FAudioVoice_GetVoiceDetails :: proc(voice: ^FAudioVoice, pVoiceDetails: ^FAudioVoiceDetails) ---
	FAudioVoice_SetOutputVoices :: proc(voice: ^FAudioVoice, pSendList: ^FAudioVoiceSends) -> u32 ---
	FAudioVoice_SetEffectChain :: proc(voice: ^FAudioVoice, pEffectChain: ^FAudioEffectChain) -> u32 ---
	FAudioVoice_EnableEffect :: proc(voice: ^FAudioVoice, EffectIndex: u32, OperationSet: u32) -> u32 ---
	FAudioVoice_DisableEffect :: proc(voice: ^FAudioVoice, EffectIndex: u32, OperationSet: u32) -> u32 ---
	FAudioVoice_GetEffectState :: proc(voice: ^FAudioVoice, EffectIndex: u32, pEnabled: ^c.int) ---
	FAudioVoice_SetEffectParameters :: proc(voice: ^FAudioVoice, EffectIndex: u32, pParameters: rawptr, ParametersByteSize: u32, OperationSet: u32) -> u32 ---
	FAudioVoice_GetEffectParameters :: proc(voice: ^FAudioVoice, EffectIndex: u32, pParameters: rawptr, ParametersByteSize: u32) -> u32 ---
	FAudioVoice_SetFilterParameters :: proc(voice: ^FAudioVoice, pParameters: ^FAudioFilterParameters, OperationSet: u32) -> u32 ---
	FAudioVoice_GetFilterParameters :: proc(voice: ^FAudioVoice, pParameters: ^FAudioFilterParameters) ---
	FAudioVoice_SetOutputFilterParameters :: proc(voice: ^FAudioVoice, pDestinationVoice: ^FAudioVoice, pParameters: ^FAudioFilterParameters, OperationSet: u32) -> u32 ---
	FAudioVoice_GetOutputFilterParameters :: proc(voice: ^FAudioVoice, pDestinationVoice: ^FAudioVoice, pParameters: ^FAudioFilterParameters) ---
	FAudioVoice_SetVolume :: proc(voice: ^FAudioVoice, Volume: f32, OperationSet: u32) -> u32 ---
	FAudioVoice_GetVolume :: proc(voice: ^FAudioVoice, pVolume: ^f32) ---
	FAudioVoice_SetChannelVolumes :: proc(voice: ^FAudioVoice, Channels: u32, pVolumes: [^]f32, OperationSet: u32) -> u32 ---
	FAudioVoice_GetChannelVolumes :: proc(voice: ^FAudioVoice, Channels: u32, pVolumes: [^]f32) ---
	FAudioVoice_SetOutputMatrix :: proc(voice: ^FAudioVoice, pDestinationVoice: ^FAudioVoice, SourceChannels: u32, DestinationChannels: u32, pLevelMatrix: [^]f32, OperationSet: u32) -> u32 ---
	FAudioVoice_GetOutputMatrix :: proc(voice: ^FAudioVoice, pDestinationVoice: ^FAudioVoice, SourceChannels: u32, DestinationChannels: u32, pLevelMatrix: [^]f32) ---
	FAudioVoice_DestroyVoice :: proc(voice: ^FAudioVoice) ---
	FAudioVoice_DestroyVoiceSafeEXT :: proc(voice: ^FAudioVoice) -> u32 ---
}

/* FAudioSourceVoice Functions */

@(default_calling_convention = "c")
foreign lib {
	FAudioSourceVoice_Start :: proc(voice: ^FAudioSourceVoice, Flags: u32, OperationSet: u32) -> u32 ---
	FAudioSourceVoice_Stop :: proc(voice: ^FAudioSourceVoice, Flags: u32, OperationSet: u32) -> u32 ---
	FAudioSourceVoice_SubmitSourceBuffer :: proc(voice: ^FAudioSourceVoice, pBuffer: ^FAudioBuffer, pBufferWMA: ^FAudioBufferWMA) -> u32 ---
	FAudioSourceVoice_FlushSourceBuffers :: proc(voice: ^FAudioSourceVoice) -> u32 ---
	FAudioSourceVoice_Discontinuity :: proc(voice: ^FAudioSourceVoice) -> u32 ---
	FAudioSourceVoice_ExitLoop :: proc(voice: ^FAudioSourceVoice, OperationSet: u32) -> u32 ---
	FAudioSourceVoice_GetState :: proc(voice: ^FAudioSourceVoice, pVoiceState: ^FAudioVoiceState, Flags: u32) ---
	FAudioSourceVoice_SetFrequencyRatio :: proc(voice: ^FAudioSourceVoice, Ratio: f32, OperationSet: u32) -> u32 ---
	FAudioSourceVoice_GetFrequencyRatio :: proc(voice: ^FAudioSourceVoice, pRatio: ^f32) ---
	FAudioSourceVoice_SetSourceSampleRate :: proc(voice: ^FAudioSourceVoice, NewSourceSampleRate: u32) -> u32 ---
}

/* Callback Types and Structures */

// FAudioEngineCallback Interface - Callbacks for engine-level events

// OnCriticalErrorFunc is called when a critical error occurs
OnCriticalErrorFunc :: #type proc "c" (engineCallback: ^FAudioEngineCallbackObj, Error: u32)
// OnProcessingPassEndFunc is called when an audio processing pass ends
OnProcessingPassEndFunc :: #type proc "c" (engineCallback: ^FAudioEngineCallbackObj)
// OnProcessingPassStartFunc is called when an audio processing pass begins
OnProcessingPassStartFunc :: #type proc "c" (engineCallback: ^FAudioEngineCallbackObj)

// FAudioEngineCallback contains function pointers for engine callbacks
FAudioEngineCallback :: struct {
	OnCriticalError:       OnCriticalErrorFunc,
	OnProcessingPassEnd:   OnProcessingPassEndFunc,
	OnProcessingPassStart: OnProcessingPassStartFunc,
}

// FAudioVoiceCallback Interface - Callbacks for voice-level events

// OnBufferEndFunc is called when a buffer finishes playing
OnBufferEndFunc :: #type proc "c" (voiceCallback: ^FAudioVoiceCallbackObj, pBufferContext: rawptr)
// OnBufferStartFunc is called when a buffer begins playing
OnBufferStartFunc :: #type proc "c" (
	voiceCallback: ^FAudioVoiceCallbackObj,
	pBufferContext: rawptr,
)
// OnLoopEndFunc is called when a buffer's loop count is exhausted
OnLoopEndFunc :: #type proc "c" (voiceCallback: ^FAudioVoiceCallbackObj, pBufferContext: rawptr)
// OnStreamEndFunc is called when all buffers have finished playing
OnStreamEndFunc :: #type proc "c" (voiceCallback: ^FAudioVoiceCallbackObj)
// OnVoiceErrorFunc is called when a voice error occurs
OnVoiceErrorFunc :: #type proc "c" (
	voiceCallback: ^FAudioVoiceCallbackObj,
	pBufferContext: rawptr,
	Error: u32,
)
// OnVoiceProcessingPassEndFunc is called when voice processing pass ends
OnVoiceProcessingPassEndFunc :: #type proc "c" (voiceCallback: ^FAudioVoiceCallbackObj)
// OnVoiceProcessingPassStartFunc is called when voice processing pass begins
OnVoiceProcessingPassStartFunc :: #type proc "c" (
	voiceCallback: ^FAudioVoiceCallbackObj,
	BytesRequired: u32,
)

// FAudioVoiceCallback contains function pointers for voice callbacks
FAudioVoiceCallback :: struct {
	OnBufferEnd:                OnBufferEndFunc,
	OnBufferStart:              OnBufferStartFunc,
	OnLoopEnd:                  OnLoopEndFunc,
	OnStreamEnd:                OnStreamEndFunc,
	OnVoiceError:               OnVoiceErrorFunc,
	OnVoiceProcessingPassEnd:   OnVoiceProcessingPassEndFunc,
	OnVoiceProcessingPassStart: OnVoiceProcessingPassStartFunc,
}

/* FAudioFX API */

/* Structures */

// FAudioFXReverbParameters defines the properties for standard reverb effect
FAudioFXReverbParameters :: struct #packed {
	WetDryMix:           f32,
	ReflectionsDelay:    u32,
	ReverbDelay:         u8,
	RearDelay:           u8,
	PositionLeft:        u8,
	PositionRight:       u8,
	PositionMatrixLeft:  u8,
	PositionMatrixRight: u8,
	EarlyDiffusion:      u8,
	LateDiffusion:       u8,
	LowEQGain:           u8,
	LowEQCutoff:         u8,
	HighEQGain:          u8,
	HighEQCutoff:        u8,
	RoomFilterFreq:      f32,
	RoomFilterMain:      f32,
	RoomFilterHF:        f32,
	ReflectionsGain:     f32,
	ReverbGain:          f32,
	DecayTime:           f32,
	Density:             f32,
	RoomSize:            f32,
}

// FAudioFXReverbParameters9 defines the properties for enhanced reverb effect (XAudio 2.9)
FAudioFXReverbParameters9 :: struct #packed {
	WetDryMix:           f32,
	ReflectionsDelay:    u32,
	ReverbDelay:         u8,
	RearDelay:           u8,
	SideDelay:           u8,
	PositionLeft:        u8,
	PositionRight:       u8,
	PositionMatrixLeft:  u8,
	PositionMatrixRight: u8,
	EarlyDiffusion:      u8,
	LateDiffusion:       u8,
	LowEQGain:           u8,
	LowEQCutoff:         u8,
	HighEQGain:          u8,
	HighEQCutoff:        u8,
	RoomFilterFreq:      f32,
	RoomFilterMain:      f32,
	RoomFilterHF:        f32,
	ReflectionsGain:     f32,
	ReverbGain:          f32,
	DecayTime:           f32,
	Density:             f32,
	RoomSize:            f32,
}

/* Constants */

// Default values for reverb parameters
FAUDIOFX_REVERB_DEFAULT_WET_DRY_MIX :: 100.0
FAUDIOFX_REVERB_DEFAULT_REFLECTIONS_DELAY :: 5
FAUDIOFX_REVERB_DEFAULT_REVERB_DELAY :: 5
FAUDIOFX_REVERB_DEFAULT_REAR_DELAY :: 5
FAUDIOFX_REVERB_DEFAULT_7POINT1_SIDE_DELAY :: 5
FAUDIOFX_REVERB_DEFAULT_7POINT1_REAR_DELAY :: 20
FAUDIOFX_REVERB_DEFAULT_POSITION :: 6
FAUDIOFX_REVERB_DEFAULT_POSITION_MATRIX :: 27
FAUDIOFX_REVERB_DEFAULT_EARLY_DIFFUSION :: 8
FAUDIOFX_REVERB_DEFAULT_LATE_DIFFUSION :: 8
FAUDIOFX_REVERB_DEFAULT_LOW_EQ_GAIN :: 8
FAUDIOFX_REVERB_DEFAULT_LOW_EQ_CUTOFF :: 4
FAUDIOFX_REVERB_DEFAULT_HIGH_EQ_GAIN :: 8
FAUDIOFX_REVERB_DEFAULT_HIGH_EQ_CUTOFF :: 4
FAUDIOFX_REVERB_DEFAULT_ROOM_FILTER_FREQ :: 5000.0
FAUDIOFX_REVERB_DEFAULT_ROOM_FILTER_MAIN :: 0.0
FAUDIOFX_REVERB_DEFAULT_ROOM_FILTER_HF :: 0.0
FAUDIOFX_REVERB_DEFAULT_REFLECTIONS_GAIN :: 0.0
FAUDIOFX_REVERB_DEFAULT_REVERB_GAIN :: 0.0
FAUDIOFX_REVERB_DEFAULT_DECAY_TIME :: 1.0
FAUDIOFX_REVERB_DEFAULT_DENSITY :: 100.0
FAUDIOFX_REVERB_DEFAULT_ROOM_SIZE :: 100.0

/* Functions */

@(default_calling_convention = "c")
foreign lib {
	// CreateReverb creates a standard reverb effect
	FAudioCreateReverb :: proc(ppApo: ^^FAPOBase, Flags: u32) -> u32 ---
	// CreateReverb9 creates an enhanced reverb effect (XAudio 2.9 compatible)
	FAudioCreateReverb9 :: proc(ppApo: ^^FAPOBase, Flags: u32) -> u32 ---
}

/* FAPO API */

/* Enumerations */

FAPORegistrationProperties_Flags :: enum u32 {
	FAPO_FLAG_CHANNELS_MUST_MATCH      = 0x1,
	FAPO_FLAG_FRAMERATE_MUST_MATCH     = 0x2,
	FAPO_FLAG_BITSPERSAMPLE_MUST_MATCH = 0x4,
	FAPO_FLAG_BUFFERCOUNT_MUST_MATCH   = 0x8,
	FAPO_FLAG_INPLACE_REQUIRED         = 0x10,
	FAPO_FLAG_INPLACE_SUPPORTED        = 0x20,
}

/* Structures */

FAPORegistrationProperties :: struct #packed {
	clsid:                FAudioGUID,
	FriendlyName:         [256]i16, /* Win32 wchar_t */
	CopyrightInfo:        [256]i16, /* Win32 wchar_t */
	MajorVersion:         u32,
	MinorVersion:         u32,
	Flags:                u32,
	MinInputBufferCount:  u32,
	MaxInputBufferCount:  u32,
	MinOutputBufferCount: u32,
	MaxOutputBufferCount: u32,
}

FAPOLockForProcessBufferParameters :: struct #packed {
	pFormat:       ^FAudioWaveFormatEx,
	MaxFrameCount: u32,
}

FAPOProcessBufferParameters :: struct #packed {
	pBuffer:    rawptr,
	FrameCount: u32,
	Flags:      u32,
}

FAPONotificationDescriptor :: struct #packed {
	Type:         u8,
	Handler:      rawptr,
	OperationSet: rawptr,
}

/* Functions */

@(default_calling_convention = "c")
foreign lib {
	FAPOCreateFAPO :: proc(pRegistrationProperties: ^FAPORegistrationProperties, ppAPO: ^^FAPOBase) -> u32 ---
	FAPOCreateFAPOWithCustomAllocatorEXT :: proc(pRegistrationProperties: ^FAPORegistrationProperties, ppAPO: ^^FAPOBase, pMemAlloc: rawptr, pMemFree: rawptr) -> u32 ---
}

/* FAPO Interface */

@(default_calling_convention = "c")
foreign lib {
	FAPOBase_AddRef :: proc(fapo: ^FAPOBase) -> u32 ---
	FAPOBase_Release :: proc(fapo: ^FAPOBase) -> u32 ---
	FAPOBase_GetRegistrationProperties :: proc(fapo: ^FAPOBase, ppRegistrationProperties: ^^FAPORegistrationProperties) -> u32 ---
	FAPOBase_IsInputFormatSupported :: proc(fapo: ^FAPOBase, pOutputFormat: ^FAudioWaveFormatEx, pRequestedInputFormat: ^FAudioWaveFormatEx, ppSupportedInputFormat: ^^FAudioWaveFormatEx) -> u32 ---
	FAPOBase_IsOutputFormatSupported :: proc(fapo: ^FAPOBase, pInputFormat: ^FAudioWaveFormatEx, pRequestedOutputFormat: ^FAudioWaveFormatEx, ppSupportedOutputFormat: ^^FAudioWaveFormatEx) -> u32 ---
	FAPOBase_Initialize :: proc(fapo: ^FAPOBase, pData: rawptr, DataByteSize: u32) -> u32 ---
	FAPOBase_Reset :: proc(fapo: ^FAPOBase) ---
	FAPOBase_LockForProcess :: proc(fapo: ^FAPOBase, InputLockedParameterCount: u32, pInputLockedParameters: ^FAPOLockForProcessBufferParameters, OutputLockedParameterCount: u32, pOutputLockedParameters: ^FAPOLockForProcessBufferParameters) -> u32 ---
	FAPOBase_UnlockForProcess :: proc(fapo: ^FAPOBase) ---
	FAPOBase_Process :: proc(fapo: ^FAPOBase, InputParameterCount: u32, pInputParameters: ^FAPOProcessBufferParameters, OutputParameterCount: u32, pOutputParameters: ^FAPOProcessBufferParameters, IsEnabled: c.int) ---
	FAPOBase_ValidateFormatPair :: proc(fapo: ^FAPOBase, pSupportedInputFormat: ^FAudioWaveFormatEx, pSupportedOutputFormat: ^FAudioWaveFormatEx, pRequestedInputFormat: ^FAudioWaveFormatEx, pRequestedOutputFormat: ^FAudioWaveFormatEx) -> u32 ---
	FAPOBase_GetParameterInfo :: proc(fapo: ^FAPOBase, ppParameterInfo: ^rawptr, pParameterByteSize: ^u32) -> u32 ---
	FAPOBase_GetParameterByIndex :: proc(fapo: ^FAPOBase, ParameterIndex: u32, pParameter: rawptr) -> u32 ---
	FAPOBase_SetParameterByIndex :: proc(fapo: ^FAPOBase, ParameterIndex: u32, pParameter: rawptr) -> u32 ---
	FAPOBase_GetParameters :: proc(fapo: ^FAPOBase, pParameters: rawptr, ParameterByteSize: u32) -> u32 ---
	FAPOBase_SetParameters :: proc(fapo: ^FAPOBase, pParameters: rawptr, ParameterByteSize: u32) -> u32 ---
	FAPOBase_OnSetConfiguration :: proc(fapo: ^FAPOBase, pSource: rawptr) -> u32 ---
	FAPOBase_OnProcess :: proc(fapo: ^FAPOBase, pfnCallback: rawptr, pvContext: rawptr) -> u32 ---
	FAPOBase_CalcInputFrames :: proc(fapo: ^FAPOBase, OutputFrameCount: u32) -> u32 ---
	FAPOBase_CalcOutputFrames :: proc(fapo: ^FAPOBase, InputFrameCount: u32) -> u32 ---
	FAPOBase_GetRegistrationPropertiesWithType :: proc(fapo: ^FAPOBase, ppRegistrationProperties: ^^FAPORegistrationProperties) -> u32 ---
}

/* F3DAudio API */

/* Constants */

F3DAUDIO_PI :: 3.141592654
F3DAUDIO_2PI :: 6.283185307

F3DAUDIO_CALCULATE_MATRIX :: 0x00000001
F3DAUDIO_CALCULATE_DELAY :: 0x00000002
F3DAUDIO_CALCULATE_LPF_DIRECT :: 0x00000004
F3DAUDIO_CALCULATE_LPF_REVERB :: 0x00000008
F3DAUDIO_CALCULATE_REVERB :: 0x00000010
F3DAUDIO_CALCULATE_DOPPLER :: 0x00000020
F3DAUDIO_CALCULATE_EMITTER_ANGLE :: 0x00000040
F3DAUDIO_CALCULATE_ZEROCENTER :: 0x00010000
F3DAUDIO_CALCULATE_REDIRECT_TO_LFE :: 0x00020000

/* Structures */

F3DAUDIO_HANDLE :: struct #packed {
	data: [20]u8,
}

F3DAUDIO_VECTOR :: struct #packed {
	x: f32,
	y: f32,
	z: f32,
}

F3DAUDIO_DISTANCE_CURVE_POINT :: struct #packed {
	Distance:   f32,
	DSPSetting: f32,
}

F3DAUDIO_DISTANCE_CURVE :: struct #packed {
	pPoints:    ^F3DAUDIO_DISTANCE_CURVE_POINT,
	PointCount: u32,
}

F3DAUDIO_LISTENER :: struct #packed {
	Position:    F3DAUDIO_VECTOR,
	Velocity:    F3DAUDIO_VECTOR,
	OrientFront: F3DAUDIO_VECTOR,
	OrientTop:   F3DAUDIO_VECTOR,
	pCone:       ^F3DAUDIO_CONE,
}

F3DAUDIO_CONE :: struct #packed {
	InnerAngle:  f32,
	OuterAngle:  f32,
	InnerVolume: f32,
	OuterVolume: f32,
	InnerLPF:    f32,
	OuterLPF:    f32,
	InnerReverb: f32,
	OuterReverb: f32,
}

F3DAUDIO_EMITTER :: struct #packed {
	pCone:               ^F3DAUDIO_CONE,
	Position:            F3DAUDIO_VECTOR,
	Velocity:            F3DAUDIO_VECTOR,
	OrientFront:         F3DAUDIO_VECTOR,
	OrientTop:           F3DAUDIO_VECTOR,
	InnerRadius:         f32,
	InnerRadiusAngle:    f32,
	ChannelCount:        u32,
	ChannelRadius:       f32,
	pChannelAzimuths:    ^f32,
	pVolumeCurve:        ^F3DAUDIO_DISTANCE_CURVE,
	pLFECurve:           ^F3DAUDIO_DISTANCE_CURVE,
	pLPFDirectCurve:     ^F3DAUDIO_DISTANCE_CURVE,
	pLPFReverbCurve:     ^F3DAUDIO_DISTANCE_CURVE,
	pReverbCurve:        ^F3DAUDIO_DISTANCE_CURVE,
	CurveDistanceScaler: f32,
	DopplerScaler:       f32,
}

F3DAUDIO_DSP_SETTINGS :: struct #packed {
	ListenerToEmitterDistance:            f32,
	EmitterToListenerDistance:            f32,
	EmitterToListenerAngle:               f32,
	EmitterToListenerAngleForLFE:         f32,
	EmitterToListenerAngleForDoppler:     f32,
	EmitterToListenerAngleForResampling:  f32,
	DopplerFactor:                        f32,
	EmitterToListenerDistance_LPF_Direct: f32,
	EmitterToListenerDistance_LPF_Reverb: f32,
	EmitterToListenerDistance_Reverb:     f32,
	DelayTime:                            f32,
	ReverbLevel:                          f32,
	LFE_Level:                            f32,
	DirectLevel:                          f32,
	MatrixCoefficients:                   ^f32,
}

/* Functions */

@(default_calling_convention = "c")
foreign lib {
	F3DAudioInitialize :: proc(SpeakerChannelMask: u32, SpeedOfSound: f32, Instance: ^F3DAUDIO_HANDLE) -> u32 ---
	F3DAudioCalculate :: proc(Instance: ^F3DAUDIO_HANDLE, pListener: ^F3DAUDIO_LISTENER, pEmitter: ^F3DAUDIO_EMITTER, Flags: u32, pDSPSettings: ^F3DAUDIO_DSP_SETTINGS) -> u32 ---
}

/* FACT API */

/* Enumerations */

FACT_NOTIFICATION_TYPE :: enum c.int {
	STOP = 0,
	PLAY,
	PAUSE,
	MARKER,
	VARIABLECHANGED,
	CUEDESTROY,
	WAVEBANKDESTROY,
	SOUNDBANKDESTROY,
}

FACT_CUE_STATE :: enum c.int {
	STOPPED = 0,
	PLAYING,
	STOPPING,
	PREPARING,
}

FACT_STATE_FLAGS :: enum u32 {
	FACT_STATE_CREATED   = 0x01,
	FACT_STATE_PREPARING = 0x02,
	FACT_STATE_PREPARED  = 0x04,
	FACT_STATE_PLAYING   = 0x08,
	FACT_STATE_STOPPING  = 0x10,
	FACT_STATE_STOPPED   = 0x20,
	FACT_STATE_PAUSED    = 0x40,
	FACT_STATE_INUSE     = 0x80,
}

/* Structures */

FACTRendererDetails :: struct #packed {
	rendererID:        [0x40]i16, /* Win32 wchar_t */
	rendererID_length: i32,
	deviceID:          [0x40]i16, /* Win32 wchar_t */
	deviceID_length:   i32,
	defaultDevice:     c.int,
	active:            c.int,
	outputChannels:    u32,
}

FACTRuntimeParameters :: struct #packed {
	lookAheadTime:                 u32,
	pGlobalSettingsBuffer:         rawptr,
	globalSettingsBufferSize:      u32,
	globalSettingsFlags:           u32,
	globalSettingsAllocAttributes: u32,
	pRendererID:                   ^i16, /* Win32 wchar_t* */
	pXAudio2:                      rawptr, /* IXAudio2* */
	pMasteringVoice:               rawptr, /* IXAudio2MasteringVoice* */
}

FACTStreamingParameters :: struct #packed {
	file:       rawptr, /* File handle */
	offset:     u32,
	flags:      u32,
	packetSize: u16,
}

FACTWaveBankRegion :: struct #packed {
	dwOffset: u32,
	dwLength: u32,
}

FACTWaveBankSampleRegion :: struct #packed {
	dwStartSample:  u32,
	dwTotalSamples: u32,
}

FACTWaveBankHeader :: struct #packed {
	dwSignature:                u32,
	dwVersion:                  u32,
	dwHeaderVersion:            u32,
	SeekTables:                 FACTWaveBankRegion,
	Names:                      FACTWaveBankRegion,
	Data:                       FACTWaveBankRegion,
	dwEntryCount:               u32,
	dwEntryMetaDataElementSize: u32,
	dwEntryNameElementSize:     u32,
	dwAlignment:                u32,
	dwCompactFormat:            u32,
	dwBuildTime:                u64,
}

FACTWaveBankMiniWaveFormat :: struct #packed {
	dwValue: u32,
}

FACTWaveBankEntry :: struct #packed {
	dwFlagsAndDuration: u32,
	Format:             FACTWaveBankMiniWaveFormat,
	PlayRegion:         FACTWaveBankRegion,
	LoopRegion:         FACTWaveBankSampleRegion,
}

FACTWaveBankEntryCompact :: struct #packed {
	dwFlagsAndDuration: u32,
	dwFormat:           u32,
}

FACTWaveProperties :: struct #packed {
	BasicWaveData:  FACTWaveBankEntry,
	dwChannelCount: u32,
	LoopRegion:     FACTWaveBankSampleRegion,
	dwSampleRate:   u32,
}

FACTWaveInstanceProperties :: struct #packed {
	BackgroundMusic:           c.int,
	FadeInMS:                  u32,
	FadeOutMS:                 u32,
	InstanceFlags:             u8,
	Volume:                    f32,
	Pitch:                     f32,
	ReverbSend:                f32,
	FilterCategory:            u8,
	FilterFrequencyCenter:     f32,
	FilterFrequencyHighCutoff: f32,
	FilterFrequencyLowCutoff:  f32,
	FilterQ:                   f32,
	FilterType:                u8,
	Priority:                  u8,
}

FACTCueInstanceProperties :: struct #packed {
	Allocated:           c.int,
	Weight:              u8,
	fadeInMS:            u32,
	fadeOutMS:           u32,
	instanceFlags:       u8,
	MaxInstanceBehavior: u8,
	InstanceLimit:       u16,
}

FACTNotificationDescription :: struct #packed {
	type:               FACT_NOTIFICATION_TYPE,
	cueIndex:           u16,
	soundBankIndex:     u8,
	waveBankIndex:      u8,
	cueInstanceIndex:   u16,
	soundInstanceIndex: u8,
	waveInstanceIndex:  u8,
	varIndex:           u16,
	varValue:           f32,
	markerValue:        u32,
	pwstrValue:         ^i16, /* Win32 wchar_t* */
}

FACTNotificationCallback :: #type proc "c" (pNotification: ^FACTNotificationDescription)

/* Functions */

@(default_calling_convention = "c")
foreign lib {
	FACTCreateEngine :: proc(ppEngine: ^^FACTEngine) -> u32 ---
	FACTCreateEngineWithCustomAllocatorEXT :: proc(ppEngine: ^^FACTEngine, pMemAlloc: rawptr, pMemFree: rawptr) -> u32 ---
}

/* FACTAudioEngine Interface */

@(default_calling_convention = "c")
foreign lib {
	FACTAudioEngine_AddRef :: proc(engine: ^FACTEngine) -> u32 ---
	FACTAudioEngine_Release :: proc(engine: ^FACTEngine) -> u32 ---
	FACTAudioEngine_GetRendererCount :: proc(engine: ^FACTEngine, pnRendererCount: ^u16) -> u32 ---
	FACTAudioEngine_GetRendererDetails :: proc(engine: ^FACTEngine, nRendererIndex: u16, pRendererDetails: ^FACTRendererDetails) -> u32 ---
	FACTAudioEngine_GetFinalMixFormat :: proc(engine: ^FACTEngine, pFinalMixFormat: ^FAudioWaveFormatEx) -> u32 ---
	FACTAudioEngine_Initialize :: proc(engine: ^FACTEngine, pParams: ^FACTRuntimeParameters) -> u32 ---
	FACTAudioEngine_ShutDown :: proc(engine: ^FACTEngine) -> u32 ---
	FACTAudioEngine_DoWork :: proc(engine: ^FACTEngine) -> u32 ---
	FACTAudioEngine_CreateSoundBank :: proc(engine: ^FACTEngine, pvBuffer: rawptr, dwSize: u32, dwFlags: u32, dwAllocAttributes: u32, ppSoundBank: ^^FACTSoundBank) -> u32 ---
	FACTAudioEngine_CreateInMemoryWaveBank :: proc(engine: ^FACTEngine, pvBuffer: rawptr, dwSize: u32, dwFlags: u32, dwAllocAttributes: u32, ppWaveBank: ^^FACTWaveBank) -> u32 ---
	FACTAudioEngine_CreateStreamingWaveBank :: proc(engine: ^FACTEngine, pParms: ^FACTStreamingParameters, ppWaveBank: ^^FACTWaveBank) -> u32 ---
	FACTAudioEngine_PrepareWave :: proc(engine: ^FACTEngine, dwFlags: u32, szWavePath: cstring, wStreamingPacketSize: u16, dwAlignment: u32, dwPlayOffset: u32, nLoopCount: u8, ppWave: ^^FACTWave) -> u32 ---
	FACTAudioEngine_PrepareInMemoryWave :: proc(engine: ^FACTEngine, dwFlags: u32, pWaveData: ^FACTWaveBankEntry, pWaveBank: ^FACTWaveBank, ppWave: ^^FACTWave) -> u32 ---
	FACTAudioEngine_PrepareStreamingWave :: proc(engine: ^FACTEngine, dwFlags: u32, pStreamingParams: ^FACTStreamingParameters, wStreamingPacketSize: u16, dwAlignment: u32, dwPlayOffset: u32, nLoopCount: u8, ppWave: ^^FACTWave) -> u32 ---
	FACTAudioEngine_RegisterNotification :: proc(engine: ^FACTEngine, pNotificationDesc: ^FACTNotificationDescription) -> u32 ---
	FACTAudioEngine_UnRegisterNotification :: proc(engine: ^FACTEngine, pNotificationDesc: ^FACTNotificationDescription) -> u32 ---
	FACTAudioEngine_GetNotification :: proc(engine: ^FACTEngine, pNotificationDesc: ^FACTNotificationDescription, pNotification: rawptr) -> u32 ---
	FACTAudioEngine_StopAllWaves :: proc(engine: ^FACTEngine) -> u32 ---
	FACTAudioEngine_SetVolume :: proc(engine: ^FACTEngine, nCategory: u16, nVolume: f32) -> u32 ---
	FACTAudioEngine_Pause :: proc(engine: ^FACTEngine, nCategory: u16, fPause: c.int) -> u32 ---
	FACTAudioEngine_GetCategory :: proc(engine: ^FACTEngine, szFriendlyName: cstring, pCategory: ^u16) -> u32 ---
	FACTAudioEngine_Stop :: proc(engine: ^FACTEngine, nCategory: u16, dwFlags: u32) -> u32 ---
	FACTAudioEngine_SetReverb :: proc(engine: ^FACTEngine, nReverb: u16, nReverbLevel: f32) -> u32 ---
	FACTAudioEngine_SetMasterVolume :: proc(engine: ^FACTEngine, nVolume: f32) -> u32 ---
}

/* FACTSoundBank Interface */

@(default_calling_convention = "c")
foreign lib {
	FACTSoundBank_GetState :: proc(soundBank: ^FACTSoundBank, pdwState: ^u32) -> u32 ---
	FACTSoundBank_GetCueIndex :: proc(soundBank: ^FACTSoundBank, szFriendlyName: cstring, pnIndex: ^u16) -> u32 ---
	FACTSoundBank_GetCueProperties :: proc(soundBank: ^FACTSoundBank, nCueIndex: u16, ppProperties: ^FACTCueInstanceProperties) -> u32 ---
	FACTSoundBank_Prepare :: proc(soundBank: ^FACTSoundBank, nCueIndex: u16, dwFlags: u32, timeOffset: u32, ppCue: ^^FACTCue) -> u32 ---
	FACTSoundBank_Play :: proc(soundBank: ^FACTSoundBank, nCueIndex: u16, dwFlags: u32, timeOffset: u32, ppCue: ^^FACTCue) -> u32 ---
	FACTSoundBank_Stop :: proc(soundBank: ^FACTSoundBank, nCueIndex: u16, dwFlags: u32) -> u32 ---
	FACTSoundBank_Destroy :: proc(soundBank: ^FACTSoundBank) -> u32 ---
	FACTSoundBank_GetCueInstanceCount :: proc(soundBank: ^FACTSoundBank, nCueIndex: u16, pnCount: ^u16) -> u32 ---
	FACTSoundBank_SetCueInstanceLimit :: proc(soundBank: ^FACTSoundBank, nCueIndex: u16, nInstanceLimit: u16, nInstanceCount: ^u16) -> u32 ---
}

/* FACTWaveBank Interface */

@(default_calling_convention = "c")
foreign lib {
	FACTWaveBank_Destroy :: proc(waveBank: ^FACTWaveBank) -> u32 ---
	FACTWaveBank_GetState :: proc(waveBank: ^FACTWaveBank, pdwState: ^u32) -> u32 ---
	FACTWaveBank_GetNumWaves :: proc(waveBank: ^FACTWaveBank, pnNumWaves: ^u16) -> u32 ---
	FACTWaveBank_GetWaveIndex :: proc(waveBank: ^FACTWaveBank, szFriendlyName: cstring, pnIndex: ^u16) -> u32 ---
	FACTWaveBank_GetWaveProperties :: proc(waveBank: ^FACTWaveBank, nWaveIndex: u16, pWaveProperties: ^FACTWaveProperties) -> u32 ---
	FACTWaveBank_Prepare :: proc(waveBank: ^FACTWaveBank, nWaveIndex: u16, dwFlags: u32, dwPlayOffset: u32, nLoopCount: u8, ppWave: ^^FACTWave) -> u32 ---
	FACTWaveBank_Play :: proc(waveBank: ^FACTWaveBank, nWaveIndex: u16, dwFlags: u32, dwPlayOffset: u32, nLoopCount: u8, ppWave: ^^FACTWave) -> u32 ---
	FACTWaveBank_Stop :: proc(waveBank: ^FACTWaveBank, nWaveIndex: u16, dwFlags: u32) -> u32 ---
}

/* FACTWave Interface */

@(default_calling_convention = "c")
foreign lib {
	FACTWave_Destroy :: proc(wave: ^FACTWave) -> u32 ---
	FACTWave_Play :: proc(wave: ^FACTWave) -> u32 ---
	FACTWave_Stop :: proc(wave: ^FACTWave, dwFlags: u32) -> u32 ---
	FACTWave_Pause :: proc(wave: ^FACTWave, fPause: c.int) -> u32 ---
	FACTWave_GetState :: proc(wave: ^FACTWave, pdwState: ^u32) -> u32 ---
	FACTWave_SetPitch :: proc(wave: ^FACTWave, pitch: i16) -> u32 ---
	FACTWave_SetVolume :: proc(wave: ^FACTWave, volume: f32) -> u32 ---
	FACTWave_SetMatrixCoefficients :: proc(wave: ^FACTWave, uSrcChannelCount: u32, uDstChannelCount: u32, pMatrixCoefficients: ^f32) -> u32 ---
	FACTWave_GetProperties :: proc(wave: ^FACTWave, ppWaveInstanceProperties: ^FACTWaveInstanceProperties) -> u32 ---
}

/* FACTCue Interface */

@(default_calling_convention = "c")
foreign lib {
	FACTCue_Destroy :: proc(cue: ^FACTCue) -> u32 ---
	FACTCue_Play :: proc(cue: ^FACTCue) -> u32 ---
	FACTCue_Stop :: proc(cue: ^FACTCue, dwFlags: u32) -> u32 ---
	FACTCue_GetState :: proc(cue: ^FACTCue, pdwState: ^u32) -> u32 ---
	FACTCue_SetMatrixCoefficients :: proc(cue: ^FACTCue, uSrcChannelCount: u32, uDstChannelCount: u32, pMatrixCoefficients: ^f32) -> u32 ---
	FACTCue_GetVariableIndex :: proc(cue: ^FACTCue, szFriendlyName: cstring, pnIndex: ^u16) -> u32 ---
	FACTCue_SetVariable :: proc(cue: ^FACTCue, nIndex: u16, nValue: f32) -> u32 ---
	FACTCue_GetVariable :: proc(cue: ^FACTCue, nIndex: u16, pnValue: ^f32) -> u32 ---
	FACTCue_Pause :: proc(cue: ^FACTCue, fPause: c.int) -> u32 ---
	FACTCue_GetProperties :: proc(cue: ^FACTCue, ppProperties: ^FACTCueInstanceProperties) -> u32 ---
	FACTCue_SetOutputVoices :: proc(cue: ^FACTCue, pSendList: ^FAudioVoiceSends) -> u32 ---
	FACTCue_SetOutputVoiceMatrix :: proc(cue: ^FACTCue, pDestinationVoice: ^FAudioVoice, SourceChannels: u32, DestinationChannels: u32, pLevelMatrix: ^f32) -> u32 ---
}

/* FACT3D API */

/* Enumerations */

FACT3DCalculateFlags :: enum u32 {
	FACT3DCALCULATE_MATRIX                   = 0x0001,
	FACT3DCALCULATE_DELAY                    = 0x0002,
	FACT3DCALCULATE_LPF_DIRECT               = 0x0004,
	FACT3DCALCULATE_LPF_REVERB               = 0x0008,
	FACT3DCALCULATE_REVERB                   = 0x0010,
	FACT3DCALCULATE_DOPPLER                  = 0x0020,
	FACT3DCALCULATE_EMITTER_ANGLE            = 0x0040,
	FACT3DCALCULATE_INNER_RADIUS_ANGLE       = 0x0080,
	FACT3DCALCULATE_MATRIX_CHANNEL_WEIGHTING = 0x0100,
}

/* Structures */

FACT3DVector :: struct #packed {
	x: f32,
	y: f32,
	z: f32,
}

FACT3DCone :: struct #packed {
	InsideAngle:   f32,
	OutsideAngle:  f32,
	InsideVolume:  f32,
	OutsideVolume: f32,
	LPFRolloff:    f32,
	ReverbRolloff: f32,
}

FACT3DDistanceCurvePoint :: struct #packed {
	Distance:   f32,
	DSPSetting: f32,
}

FACT3DDistanceCurve :: struct #packed {
	pPoints:    ^FACT3DDistanceCurvePoint,
	PointCount: u32,
}

FACT3DListener :: struct #packed {
	Position:    FACT3DVector,
	Velocity:    FACT3DVector,
	OrientFront: FACT3DVector,
	OrientTop:   FACT3DVector,
	pCone:       ^FACT3DCone,
}

FACT3DEmitter :: struct #packed {
	pCone:               ^FACT3DCone,
	OrientFront:         FACT3DVector,
	OrientTop:           FACT3DVector,
	Position:            FACT3DVector,
	Velocity:            FACT3DVector,
	InnerRadius:         f32,
	InnerRadiusAngle:    f32,
	ChannelCount:        u32,
	ChannelRadius:       f32,
	pChannelAzimuths:    ^f32,
	pVolumeCurve:        ^FACT3DDistanceCurve,
	pLFECurve:           ^FACT3DDistanceCurve,
	pLPFDirectCurve:     ^FACT3DDistanceCurve,
	pLPFReverbCurve:     ^FACT3DDistanceCurve,
	pReverbCurve:        ^FACT3DDistanceCurve,
	CurveDistanceScaler: f32,
	DopplerScaler:       f32,
}

FACT3DDspSettings :: struct #packed {
	MatrixCoefficients:        ^f32,
	DelayTimes:                ^f32,
	LPFDirectCoefficient:      f32,
	LPFReverbCoefficient:      f32,
	ReverbLevel:               f32,
	DopplerFactor:             f32,
	EmitterToListenerAngle:    f32,
	EmitterToListenerDistance: f32,
	EmitterVelocityComponent:  f32,
	ListenerVelocityComponent: f32,
}

FACT3DInitSettings :: struct #packed {
	SpeedOfSound:       f32,
	MaxAudioPathLength: f32,
	DopplerScaler:      f32,
}

/* Functions */

@(default_calling_convention = "c")
foreign lib {
	FACT3DInitialize :: proc(engine: ^FACTEngine, F3DInstance: [^]u8) -> u32 ---
	FACT3DCalculate :: proc(F3DInstance: [^]u8, pListener: ^F3DAUDIO_LISTENER, pEmitter: ^F3DAUDIO_EMITTER, pDSPSettings: ^F3DAUDIO_DSP_SETTINGS) -> u32 ---
	FACT3DApply :: proc(pDSPSettings: ^F3DAUDIO_DSP_SETTINGS, cue: ^FACTCue) -> u32 ---
}

/* FAudio I/O API */

/* Callback Types */

FAudioIOReadFunc :: #type proc "c" (data: rawptr, offset: u64, size: u64, ptr: rawptr) -> u64
FAudioIOSeekFunc :: #type proc "c" (data: rawptr, offset: u64) -> c.int

/* Structures */

FAudioIOStream :: struct #packed {
	data:      rawptr,
	read:      FAudioIOReadFunc,
	seek:      FAudioIOSeekFunc,
	size:      u64,
	lock:      rawptr,
	position:  u64,
	closeFunc: rawptr,
}

/* Functions */

@(default_calling_convention = "c")
foreign lib {
	FAudioIOStreamOpen :: proc(path: cstring, io: ^^FAudioIOStream) -> u32 ---
	FAudioIOStreamOpenMemory :: proc(data: ^u8, size: u32, io: ^^FAudioIOStream) -> u32 ---
	FAudioIOStreamClose :: proc(io: ^FAudioIOStream) ---
}

/* XNA Song API */

/* Enumerations */

FAudioPlatform :: enum c.int {
	Windows,
	Xbox,
	OSX,
	IOS,
	Android,
	Linux,
	TVOS,
	Switch,
	XboxOne,
	PS4,
	PS5,
	Count,
}

/* Functions */

@(default_calling_convention = "c")
foreign lib {
	XNA_SongInit :: proc() -> u32 ---
	XNA_SongQuit :: proc() ---
	XNA_SongReset :: proc() ---
	XNA_SongPlayEx :: proc(name: cstring, volume: f32, pitch: f32, loop: c.int) -> u32 ---
	XNA_SongPlay :: proc(name: cstring) -> u32 ---
	XNA_SongSetVolume :: proc(volume: f32) ---
	XNA_SongSetPitch :: proc(pitch: f32) ---
	XNA_SongPause :: proc() ---
	XNA_SongResume :: proc() ---
	XNA_SongStop :: proc() ---
	XNA_SongIsPlaying :: proc() -> c.int ---
	XNA_SongGetVolume :: proc() -> f32 ---
	XNA_SongGetPitch :: proc() -> f32 ---
	XNA_SongSetPan :: proc(pan: f32) ---
	XNA_SongGetPan :: proc() -> f32 ---
}

/* stb_vorbis API */

/* Structures */

stb_vorbis_alloc :: struct #packed {
	alloc_buffer:                 rawptr,
	alloc_buffer_length_in_bytes: c.int,
}

stb_vorbis_info :: struct #packed {
	sample_rate:                c.uint,
	channels:                   c.int,
	setup_memory_required:      c.uint,
	setup_temp_memory_required: c.uint,
	temp_memory_required:       c.uint,
	max_frame_size:             c.int,
}

/* Functions */

@(default_calling_convention = "c")
foreign lib {
	stb_vorbis_decode_filename :: proc(filename: cstring, channels: ^c.int, sample_rate: ^c.int, output: ^^i16) -> c.int ---
	stb_vorbis_decode_memory :: proc(mem: ^u8, len: c.int, channels: ^c.int, sample_rate: ^c.int, output: ^^i16) -> c.int ---
	stb_vorbis_open_memory :: proc(mem: ^u8, len: c.int, error: ^c.int, alloc: ^stb_vorbis_alloc) -> rawptr ---
	stb_vorbis_open_filename :: proc(filename: cstring, error: ^c.int, alloc: ^stb_vorbis_alloc) -> rawptr ---
	stb_vorbis_open_callbacks :: proc(callbacks: rawptr, user_data: rawptr, error: ^c.int, alloc: ^stb_vorbis_alloc) -> rawptr ---
	stb_vorbis_seek_frame :: proc(f: rawptr, sample_number: c.uint) -> c.int ---
	stb_vorbis_seek :: proc(f: rawptr, sample_number: c.uint) -> c.int ---
	stb_vorbis_seek_start :: proc(f: rawptr) -> c.int ---
	stb_vorbis_stream_length_in_samples :: proc(f: rawptr) -> c.uint ---
	stb_vorbis_stream_length_in_seconds :: proc(f: rawptr) -> f32 ---
	stb_vorbis_get_frame_float :: proc(f: rawptr, channels: ^c.int, output: ^^^f32) -> c.int ---
	stb_vorbis_get_frame_short_interleaved :: proc(f: rawptr, num_c: c.int, buffer: ^i16, num_shorts: c.int) -> c.int ---
	stb_vorbis_get_frame_short :: proc(f: rawptr, num_c: c.int, buffer: ^^i16, num_samples: c.int) -> c.int ---
	stb_vorbis_get_samples_float_interleaved :: proc(f: rawptr, channels: c.int, buffer: ^f32, num_floats: c.int) -> c.int ---
	stb_vorbis_get_samples_float :: proc(f: rawptr, channels: c.int, buffer: ^^f32, num_samples: c.int) -> c.int ---
	stb_vorbis_get_samples_short_interleaved :: proc(f: rawptr, channels: c.int, buffer: ^i16, num_shorts: c.int) -> c.int ---
	stb_vorbis_get_samples_short :: proc(f: rawptr, channels: c.int, buffer: ^^i16, num_samples: c.int) -> c.int ---
	stb_vorbis_get_info :: proc(f: rawptr) -> stb_vorbis_info ---
	stb_vorbis_get_error :: proc(f: rawptr) -> c.int ---
	stb_vorbis_close :: proc(f: rawptr) ---
	stb_vorbis_get_sample_offset :: proc(f: rawptr) -> c.uint ---
	stb_vorbis_get_file_offset :: proc(f: rawptr) -> c.int ---
}

/* qoa API */

/* Structures */

qoa_desc :: struct #packed {
	sample_rate: c.uint,
	samples:     c.uint,
	channels:    c.uint,
	frames:      c.uint,
}

/* Functions */

@(default_calling_convention = "c")
foreign lib {
	qoa_decode_header :: proc(bytes: ^u8, size: c.uint, desc: ^qoa_desc) -> c.int ---
	qoa_decode_frame :: proc(bytes: ^u8, size: c.uint, samples: ^i16) -> c.int ---
	qoa_decode :: proc(bytes: ^u8, size: c.uint, samples: ^^i16, desc: ^qoa_desc) -> c.int ---
	qoa_encode_header :: proc(desc: ^qoa_desc, bytes: ^u8) -> c.int ---
	qoa_encode_frame :: proc(samples: ^i16, desc: ^qoa_desc, bytes: ^u8) -> c.int ---
	qoa_encode :: proc(samples: ^i16, desc: ^qoa_desc, bytes: ^^u8) -> c.int ---
}
