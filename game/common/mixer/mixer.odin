package mixer

import "bindings:faudio"
import "core:log"
import "core:mem"
import "core:strings"
import "vendor:sdl3"

// Audio context for managing audio engine state
MixerContext :: struct {
	audio:           ^faudio.FAudio,
	mastering_voice: ^faudio.FAudioMasteringVoice,
	initialized:     bool,
	sounds:          map[string]Sound, // Store sounds by name
}

// Sound structure - each sound has its own source voice
Sound :: struct {
	data:         []byte,
	buffer:       faudio.FAudioBuffer,
	wfx:          faudio.FAudioWaveFormatEx,
	source_voice: ^faudio.FAudioSourceVoice,
}

// Create and initialize a new audio context
mixer_create :: proc() -> ^MixerContext {
	ctx := new(MixerContext)
	ctx.sounds = make(map[string]Sound)

	// Initialize SDL audio subsystem
	if !sdl3.InitSubSystem(sdl3.INIT_AUDIO) {
		log.errorf("Failed to initialize SDL3 audio: %s", sdl3.GetError())
		free(ctx)
		return nil
	}

	// Create FAudio instance
	if faudio.FAudioCreate(&ctx.audio, 0, 0) != 0 {
		log.error("Failed to create FAudio instance")
		free(ctx)
		return nil
	}

	// Create mastering voice
	if result := faudio.FAudio_CreateMasteringVoice(
		ctx.audio,
		&ctx.mastering_voice,
		2, // stereo
		48000, // 48kHz
		0,
		0,
		nil,
	); result != 0 {
		log.error("Failed to create mastering voice")
		faudio.FAudio_Release(ctx.audio)
		ctx.audio = nil
		free(ctx)
		return nil
	}

	ctx.initialized = true
	return ctx
}

// Shutdown and free the audio context
mixer_destroy :: proc(ctx: ^MixerContext) {
	if ctx == nil do return

	// Free all loaded sounds
	for _, &sound in ctx.sounds {
		sound_free_internal(&sound)
	}
	delete(ctx.sounds)

	if ctx.mastering_voice != nil {
		faudio.FAudioVoice_DestroyVoice(ctx.mastering_voice)
		ctx.mastering_voice = nil
	}

	if ctx.audio != nil {
		faudio.FAudio_Release(ctx.audio)
		ctx.audio = nil
	}

	ctx.initialized = false
	free(ctx)
}

// Load a sound from a file and store it in the context by name
sound_load :: proc(ctx: ^MixerContext, name: string, filename: string) -> bool {
	if ctx == nil || !ctx.initialized do return false

	// Convert filename to cstring for SDL
	filename_cstr := strings.clone_to_cstring(filename)
	defer delete(filename_cstr)

	// Use SDL to load the WAV file
	spec: sdl3.AudioSpec
	buf: [^]u8
	len: u32

	if !sdl3.LoadWAV(filename_cstr, &spec, &buf, &len) {
		log.errorf("Failed to load WAV: %s", sdl3.GetError())
		return false
	}
	defer sdl3.free(buf)

	// Create a new sound
	sound: Sound

	// Copy audio data to our own buffer
	sound.data = make([]byte, len)
	mem.copy(&sound.data[0], buf, int(len))

	// Set up wave format
	sound.wfx = faudio.FAudioWaveFormatEx {
		wFormatTag      = 1, // PCM
		nChannels       = u16(spec.channels),
		nSamplesPerSec  = u32(spec.freq),
		wBitsPerSample  = 16, // Assuming 16-bit samples
		nBlockAlign     = u16(spec.channels * 2),
		nAvgBytesPerSec = u32(spec.freq) * u32(spec.channels * 2),
		cbSize          = 0,
	}

	// Set up audio buffer
	sound.buffer = faudio.FAudioBuffer {
		Flags      = 0,
		AudioBytes = len,
		pAudioData = raw_data(sound.data),
		PlayBegin  = 0,
		PlayLength = 0, // Play the entire buffer
		LoopBegin  = 0,
		LoopLength = 0,
		LoopCount  = 0,
		pContext   = nil,
	}

	// Create source voice for this sound
	if result := faudio.FAudio_CreateSourceVoice(
		ctx.audio,
		&sound.source_voice,
		&sound.wfx,
		0,
		1.0,
		nil,
		nil,
		nil,
	); result != 0 {
		log.error("Failed to create source voice")
		delete(sound.data)
		return false
	}

	// Store the sound in the context
	ctx.sounds[name] = sound
	return true
}

// Play a sound by name from the context
sound_play_by_name :: proc(ctx: ^MixerContext, name: string, volume: f32 = 1.0) -> bool {
	if ctx == nil || !ctx.initialized do return false

	// Find the sound by name
	sound, ok := ctx.sounds[name]
	if !ok do return false

	// Play the sound
	return sound_play(sound, volume)
}

// Get a sound by name
sound_get :: proc(ctx: ^MixerContext, name: string) -> (Sound, bool) {
	if ctx == nil || !ctx.initialized {
		sound: Sound
		return sound, false
	}
	sound, ok := ctx.sounds[name]
	return sound, ok
}

// Internal function to free a sound's resources without removing from the context
sound_free_internal :: proc(sound: ^Sound) {
	if sound == nil do return

	if sound.source_voice != nil {
		faudio.FAudioSourceVoice_Stop(sound.source_voice, 0, 0)
		faudio.FAudioVoice_DestroyVoice(sound.source_voice)
		sound.source_voice = nil
	}

	if sound.data != nil {
		delete(sound.data)
		sound.data = nil
	}
}

// Free a single sound from the context
sound_free :: proc(ctx: ^MixerContext, name: string) -> bool {
	if ctx == nil || !ctx.initialized do return false

	sound, ok := &ctx.sounds[name]
	if !ok do return false

	sound_free_internal(sound)
	delete_key(&ctx.sounds, name)
	return true
}

// Play a sound directly (use sound_play_by_name instead if possible)
sound_play :: proc(sound: Sound, volume: f32 = 1.0) -> bool {
	if sound.source_voice == nil do return false

	// Stop any previous playback
	faudio.FAudioSourceVoice_Stop(sound.source_voice, 0, 0)
	faudio.FAudioSourceVoice_FlushSourceBuffers(sound.source_voice)

	// Set volume
	faudio.FAudioVoice_SetVolume(sound.source_voice, volume, 0)

	// Submit buffer
	buffer_copy := sound.buffer
	if result := faudio.FAudioSourceVoice_SubmitSourceBuffer(
		sound.source_voice,
		&buffer_copy,
		nil,
	); result != 0 {
		return false
	}

	// Start playback
	return faudio.FAudioSourceVoice_Start(sound.source_voice, 0, 0) == 0
}
