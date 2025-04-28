package game

import "bindings:faudio"
import "core:log"
import "core:mem"
import "core:strings"
import "vendor:sdl3"

/*
   init_audio initializes the FAudio system and creates a mastering voice.
   This is called during window initialization and only needs to be done once.
   Returns true on success, false on failure.
*/
init_audio :: proc() -> bool {
	if faudio.FAudioCreate(&g_app_state.audio.audio, 0, 0) != 0 {
		log.errorf("Failed to create FAudio, error:")
		return false
	}

	if result := faudio.FAudio_CreateMasteringVoice(
		g_app_state.audio.audio,
		&g_app_state.audio.masteringVoice,
		2, // stereo
		48000, // 48kHz
		0,
		0,
		nil,
	); result != 0 {
		log.errorf("Failed to create mastering voice, error:", result)
		return false
	}

	return true
}

/*
   load_audio loads a WAV file into memory and prepares it for playback.
   If a sound is already loaded, it will be unloaded first.
   Returns true on success, false on failure.
   
   Parameters:
     filename: Path to the WAV file to load
*/
load_audio :: proc(filename: string) -> bool {
	// First close any existing audio
	if g_app_state.audio.audioData != nil {
		delete(g_app_state.audio.audioData)
		g_app_state.audio.audioData = nil
	}

	if g_app_state.audio.sourceVoice != nil {
		faudio.FAudioVoice_DestroyVoice(g_app_state.audio.sourceVoice)
		g_app_state.audio.sourceVoice = nil
	}

	// Use SDL to load WAV file
	audio_spec: sdl3.AudioSpec
	audio_buf: [^]u8
	audio_len: u32

	// Convert string to cstring for SDL
	filename_cstr := strings.clone_to_cstring(filename)
	defer delete(filename_cstr)

	if !sdl3.LoadWAV(filename_cstr, &audio_spec, &audio_buf, &audio_len) {
		log.errorf("Failed to load WAV file:", sdl3.GetError())
		return false
	}
	defer sdl3.free(audio_buf) // Use SDL's generic free function

	log.debugf(
		"Loaded WAV: %s, %d Hz, %d channels, %d bytes\n",
		filename,
		audio_spec.freq,
		audio_spec.channels,
		audio_len,
	)

	// Set up wave format
	g_app_state.audio.wfx = faudio.FAudioWaveFormatEx {
		wFormatTag      = 1, // PCM
		nChannels       = u16(audio_spec.channels),
		nSamplesPerSec  = u32(audio_spec.freq),
		wBitsPerSample  = 16, // Assuming 16-bit samples
		nBlockAlign     = u16(audio_spec.channels * 2), // channels * bytes per sample
		nAvgBytesPerSec = u32(audio_spec.freq) * u32(audio_spec.channels * 2),
		cbSize          = 0,
	}

	// Create source voice
	if result := faudio.FAudio_CreateSourceVoice(
		g_app_state.audio.audio,
		&g_app_state.audio.sourceVoice,
		&g_app_state.audio.wfx,
		0,
		1.0,
		nil, // No callback
		nil, // No sends
		nil, // No effect chain
	); result != 0 {
		log.errorf("Failed to create source voice, error:", result)
		return false
	}

	// Copy audio data
	g_app_state.audio.audioData = make([]byte, audio_len)
	mem.copy(&g_app_state.audio.audioData[0], audio_buf, int(audio_len))

	// Set up audio buffer
	g_app_state.audio.buffer = faudio.FAudioBuffer {
		Flags      = 0,
		AudioBytes = audio_len,
		pAudioData = raw_data(g_app_state.audio.audioData),
		PlayBegin  = 0,
		PlayLength = 0, // Play the entire buffer
		LoopBegin  = 0,
		LoopLength = 0,
		LoopCount  = 0,
		pContext   = nil,
	}

	return true
}

/*
   play_sound plays the currently loaded sound.
   If a sound is already playing, it will be stopped first.
   Returns true on success, false on failure.
*/
play_sound :: proc() -> bool {
	if result := faudio.FAudioSourceVoice_Stop(g_app_state.audio.sourceVoice, 0, 0); result != 0 {
		log.errorf("Failed to stop source voice, error:", result)
		return false
	}

	if result := faudio.FAudioSourceVoice_SubmitSourceBuffer(
		g_app_state.audio.sourceVoice,
		&g_app_state.audio.buffer,
		nil,
	); result != 0 {
		log.errorf("Failed to submit source buffer, error:", result)
		return false
	}

	if result := faudio.FAudioVoice_SetVolume(g_app_state.audio.sourceVoice, 1.0, 0); result != 0 {
		log.errorf("Failed to set volume, error:", result)
		return false
	}

	if result := faudio.FAudioSourceVoice_Start(g_app_state.audio.sourceVoice, 0, 0); result != 0 {
		log.errorf("Failed to start source voice, error:", result)
		return false
	}

	log.debug("Playing sound...")
	return true
}

/*
   close_audio cleans up all audio resources.
   This should be called during game shutdown or before a hot reload.
*/
close_audio :: proc() {
	if g_app_state.audio.audioData != nil {
		delete(g_app_state.audio.audioData)
		g_app_state.audio.audioData = nil
	}

	if g_app_state.audio.sourceVoice != nil {
		faudio.FAudioVoice_DestroyVoice(g_app_state.audio.sourceVoice)
		g_app_state.audio.sourceVoice = nil
	}

	if g_app_state.audio.masteringVoice != nil {
		faudio.FAudioVoice_DestroyVoice(g_app_state.audio.masteringVoice)
		g_app_state.audio.masteringVoice = nil
	}

	if g_app_state.audio.audio != nil {
		faudio.FAudio_Release(g_app_state.audio.audio)
		g_app_state.audio.audio = nil
	}
}
