package game

import "bindings:faudio"
import "core:fmt"
import "core:mem"
import "core:strings"
import "vendor:sdl3"

// Initialize the audio system
init_audio :: proc() -> bool {
	// Initialize FAudio
	result := faudio.FAudioCreate(&g_state.audio_state.audio, 0, 0)
	if result != 0 {
		fmt.eprintln("Failed to create FAudio, error:", result)
		return false
	}

	// Create mastering voice
	result = faudio.FAudio_CreateMasteringVoice(
		g_state.audio_state.audio,
		&g_state.audio_state.masteringVoice,
		2, // stereo
		48000, // 48kHz
		0,
		0,
		nil,
	)
	if result != 0 {
		fmt.eprintln("Failed to create mastering voice, error:", result)
		return false
	}

	return true
}

// Load audio from a WAV file
load_audio :: proc(filename: string) -> bool {
	// First close any existing audio
	if g_state.audio_state.audioData != nil {
		delete(g_state.audio_state.audioData)
		g_state.audio_state.audioData = nil
	}

	if g_state.audio_state.sourceVoice != nil {
		faudio.FAudioVoice_DestroyVoice(g_state.audio_state.sourceVoice)
		g_state.audio_state.sourceVoice = nil
	}

	// Use SDL to load WAV file
	audio_spec: sdl3.AudioSpec
	audio_buf: [^]u8
	audio_len: u32

	// Convert string to cstring for SDL
	filename_cstr := strings.clone_to_cstring(filename)
	defer delete(filename_cstr)

	if !sdl3.LoadWAV(filename_cstr, &audio_spec, &audio_buf, &audio_len) {
		fmt.eprintln("Failed to load WAV file:", sdl3.GetError())
		return false
	}
	defer sdl3.free(audio_buf) // Use SDL's generic free function

	fmt.printf(
		"Loaded WAV: %s, %d Hz, %d channels, %d bytes\n",
		filename,
		audio_spec.freq,
		audio_spec.channels,
		audio_len,
	)

	// Set up wave format
	g_state.audio_state.wfx = faudio.FAudioWaveFormatEx {
		wFormatTag      = 1, // PCM
		nChannels       = u16(audio_spec.channels),
		nSamplesPerSec  = u32(audio_spec.freq),
		wBitsPerSample  = 16, // Assuming 16-bit samples
		nBlockAlign     = u16(audio_spec.channels * 2), // channels * bytes per sample
		nAvgBytesPerSec = u32(audio_spec.freq) * u32(audio_spec.channels * 2),
		cbSize          = 0,
	}

	// Create source voice
	result := faudio.FAudio_CreateSourceVoice(
		g_state.audio_state.audio,
		&g_state.audio_state.sourceVoice,
		&g_state.audio_state.wfx,
		0,
		1.0,
		nil, // No callback
		nil, // No sends
		nil, // No effect chain
	)

	if result != 0 {
		fmt.eprintln("Failed to create source voice, error:", result)
		return false
	}

	// Copy audio data
	g_state.audio_state.audioData = make([]byte, audio_len)
	mem.copy(&g_state.audio_state.audioData[0], audio_buf, int(audio_len))

	// Set up audio buffer
	g_state.audio_state.buffer = faudio.FAudioBuffer {
		Flags      = 0,
		AudioBytes = audio_len,
		pAudioData = raw_data(g_state.audio_state.audioData),
		PlayBegin  = 0,
		PlayLength = 0, // Play the entire buffer
		LoopBegin  = 0,
		LoopLength = 0,
		LoopCount  = 0,
		pContext   = nil,
	}

	return true
}

// Play the loaded sound
play_sound :: proc() -> bool {
	// Stop any currently playing sound
	result := faudio.FAudioSourceVoice_Stop(g_state.audio_state.sourceVoice, 0, 0)
	if result != 0 {
		fmt.eprintln("Failed to stop source voice, error:", result)
		return false
	}

	// Submit the buffer
	result = faudio.FAudioSourceVoice_SubmitSourceBuffer(
		g_state.audio_state.sourceVoice,
		&g_state.audio_state.buffer,
		nil,
	)

	if result != 0 {
		fmt.eprintln("Failed to submit source buffer, error:", result)
		return false
	}

	// Set volume to 100%
	result = faudio.FAudioVoice_SetVolume(g_state.audio_state.sourceVoice, 1.0, 0)
	if result != 0 {
		fmt.eprintln("Failed to set volume, error:", result)
		return false
	}

	// Start the voice
	result = faudio.FAudioSourceVoice_Start(g_state.audio_state.sourceVoice, 0, 0)
	if result != 0 {
		fmt.eprintln("Failed to start source voice, error:", result)
		return false
	}

	fmt.println("Playing sound...")
	return true
}

// Clean up audio resources
close_audio :: proc() {
	if g_state.audio_state.audioData != nil {
		delete(g_state.audio_state.audioData)
		g_state.audio_state.audioData = nil
	}

	if g_state.audio_state.sourceVoice != nil {
		faudio.FAudioVoice_DestroyVoice(g_state.audio_state.sourceVoice)
		g_state.audio_state.sourceVoice = nil
	}

	if g_state.audio_state.masteringVoice != nil {
		faudio.FAudioVoice_DestroyVoice(g_state.audio_state.masteringVoice)
		g_state.audio_state.masteringVoice = nil
	}

	if g_state.audio_state.audio != nil {
		faudio.FAudio_Release(g_state.audio_state.audio)
		g_state.audio_state.audio = nil
	}
}
