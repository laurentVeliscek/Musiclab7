extends Control


const TAG = "->"
var myMasterSong:Song

onready var songTrackView:SongTrackView = $SongViewContainer/SongTrackView
onready var voicings_container:CenterContainer = $voicingContainer
onready var guitar_voicing_view:GuitarChordView = $voicingContainer/voicing_view
onready var pattern_lineEdit:LineEdit = $Pattern/pattern_lineEdit

onready var console:RichTextLabel = $console/console_RTL
onready var midi_player:MidiPlayer

onready var playStopBtn:Button = $Transport/playStop_btn
onready var playHead:ColorRect = $SongViewContainer/play_head_cr
#onready var rewindBtn:Button = $Transport/rewind_btn

onready var guitar_program_ob:OptionButton = $instruments/guitar_program_ob
onready var bass_program_ob:OptionButton = $instruments/bass_program_ob
onready var chords_program_ob:OptionButton = $instruments/satb_program_ob

onready var guitar_volume_vs:VSlider = $Volume/Volumes/guitar_volume/Guitar_volume_VS
onready var bass_volume_vs:VSlider = $Volume/Volumes/bass_volume/Bass_volume_VS
onready var chords_volume_vs:VSlider = $Volume/Volumes/Chords_volume/Chords_volume_VS
onready var octave_offset_vs:VSlider = $octave/HBoxContainer/octave_offset_vs

onready var max_chords_strings:VSlider = $playerConfig/VBoxContainer/config_sliders/max_chords_strings
onready var swing_amount:VSlider = $playerConfig/VBoxContainer/config_sliders/swing_amount
onready var strum_duration_min:VSlider = $playerConfig/VBoxContainer/config_sliders/strum_duration_min
onready var strum_duration_max:VSlider = $playerConfig/VBoxContainer/config_sliders/strum_duration_max
onready var mute_duration:VSlider = $playerConfig/VBoxContainer/config_sliders/mute_duration
onready var velocity_randomization:VSlider = $playerConfig/VBoxContainer/config_sliders/velocity_randomization
onready var accent_downbeat_factor:VSlider = $playerConfig/VBoxContainer/config_sliders/accent_downbeat_factor
onready var timing_variance:VSlider = $playerConfig/VBoxContainer/config_sliders/timing_variance
onready var down_velocity_base:VSlider = $playerConfig/VBoxContainer/config_sliders/down_velocity_base
onready var down_velocity_light:VSlider = $playerConfig/VBoxContainer/config_sliders/down_velocity_light
onready var up_velocity_base:VSlider = $playerConfig/VBoxContainer/config_sliders/up_velocity_base
onready var up_velocity_light:VSlider = $playerConfig/VBoxContainer/config_sliders/up_velocity_light
onready var pick_position:VSlider = $playerConfig/VBoxContainer/config_sliders/pick_position
onready var pick_influence:VSlider = $playerConfig/VBoxContainer/config_sliders/pick_influence
onready var chord_transition_gap:VSlider = $playerConfig/VBoxContainer/config_sliders/chord_transition_gap
onready var single_note_velocity:VSlider = $playerConfig/VBoxContainer/config_sliders/single_note_velocity
#onready var step_beat_length_btn = $playerConfig/VBoxContainer/config_sliders/buttons/step_beat_length_btn
onready var pattern = $Pattern

#onready var guitar_player:FolkGuitarPlayer = FolkGuitarPlayer.new()

# on copie en local (clone) les variables de folkGuitarPlayer

var gp:FolkGuitarPlayer

var song_playing_ended:bool = true
var myPlayingSong:Song = Song.new()

var posInTicks :int = 0
var started_playing_pos = 0
var marker_starting_pos_in_ticks:int = -1
var anim_songTrack_view = false


var chord_select = null
var selected_chord_index = 0

var copy_pattern_buffer:StrumPattern
var current_step_beat_value 

var previous_playing_pattern_number:int = 0

var scene_is_ready:bool = false

var songview_is_displaying_degree = true
var progression_track_length



func _ready():
	# midiPlayerSetup
	
	musiclibMidiPlayer.setupMidiPlayer()
	midi_player = musiclibMidiPlayer.midiPlayer
	
	gp = FolkGuitarPlayer.new()
	
	
	myMasterSong = MusicLabGlobals.get_song().clone()
	if myMasterSong == null:
		myMasterSong = dummy_song()
	#print(myMasterSong.to_string())
	# on degage la piste guitare
	#myMasterSong.remove_track_by_name(Song.RYTHM_GUITAR_TRACK)
	
	
	
	songTrackView.song = myMasterSong
	songTrackView.trackName = Song.PROGRESSION_TRACK_NAME

	var progression_track:Track = myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME)

	progression_track_length = progression_track.length_beats * myMasterSong.ppq
	
#	for e in progression_track.events :
#		if e.has("degree"):
#			var d = e["degree"]
#			var guitar_chords = d.guitar_chords()
#			var gc:GuitarChord = guitar_chords[d.chord_voicing_index % guitar_chords.size()]
#			gc.start = e["start"]
#			gc.length_beats = d.length_beats
#			gp.chord_grid.append(gc)
	

	LogBus.connect("log_entry", self, "_on_log_entry")
	LogBus._verbose = true
	LogBus.info(TAG,"Select a chord to set the guitar chord voicing")
	#clear_console()
	#var sp:StrumPattern = StrumPattern.new()
	if  myMasterSong.strum_pattern_array.size() > 0 :
		gp.pattern_sequence = myMasterSong.strum_pattern_array
	else :
		var sp:StrumPattern = StrumPattern.new()
		gp.pattern_sequence = [sp]
	
	
	LogBus.debug(TAG,"progression_track.get_degrees_with_start().size():" + str(progression_track.get_degrees_with_start().size()))
	for dic in progression_track.get_degrees_with_start():
		var d:Degree = dic["degree"]
		var guitar_chords = d.guitar_chords()
		var gc:GuitarChord = guitar_chords[d.chord_voicing_index % guitar_chords.size()]
		gc.start = dic["start"]
		gc.length_beats = d.length_beats
		gp.chord_grid.append(gc)
		
	
	
	
	
	if gp.pattern_sequence.size() < 2:
		$Pattern/delete_btn.hide()
		$Pattern/next_btn.hide()
		
	$Pattern/paste_btn.hide()
	# On affiche le voicing du premier 
	
	var d:Degree = progression_track.get_degrees_array()[0]
	var voicings = d.guitar_chords()
	var voicing_number = d.chord_voicing_index % voicings.size()
	var current_voicing = voicings[voicing_number]
	#var guitar_player.chord_grid[index]  = 
	
	guitar_voicing_view.set_voicings(voicings) 
	guitar_voicing_view.set_voicing_index(voicing_number)
	guitar_voicing_view.update()
	
	MusicLabGlobals.yield(self)
	pattern._update_pattern_display()
	

	
	guitar_program_ob.set_program(25)
	bass_program_ob.set_program(32)
	chords_program_ob.set_program(50)
	
	var guitar_scene_params = myMasterSong.guitar_player_scene_params
	if guitar_scene_params != null:
		if guitar_scene_params.has("guitar_program"):
			guitar_program_ob.set_program(guitar_scene_params["guitar_program"])
		if guitar_scene_params.has("bass_program"):	
			bass_program_ob.set_program(guitar_scene_params["bass_program"])
		if guitar_scene_params.has("chords_program"):			
			chords_program_ob.set_program(guitar_scene_params["chords_program"])
		if guitar_scene_params.has("guitar_octave_offset"):			
			octave_offset_vs.value = int(guitar_scene_params["guitar_octave_offset"])
		if guitar_scene_params.has("guitar_volume"):	
			guitar_volume_vs.value = int(guitar_scene_params["guitar_volume"])
		if guitar_scene_params.has("bass_volume"):	
			bass_volume_vs.value = int(guitar_scene_params["bass_volume"])
		if guitar_scene_params.has("chords_volume"):		
			chords_volume_vs.value = int(guitar_scene_params["chords_volume"])
		
	
	#dic.get("guitar_player_scene_params", {})
	
	scene_is_ready = true
	#MusicLabGlobals.yield(self)
	rewind()

func get_dico_from_interface_sliders()->Dictionary:
	var dico = {
		"guitar_program":guitar_program_ob.get_program(),
		"bass_program":bass_program_ob.get_program(),
		"chords_program":chords_program_ob.get_program(),
		"guitar_octave_offset":octave_offset_vs.value,	
		"guitar_volume":guitar_volume_vs.value,	
		"bass_volume":bass_volume_vs.value,	
		"chords_volume":chords_volume_vs.value,	
	}
	return dico

func _process(_delta):
	if midi_player.playing :
		if anim_songTrack_view :
			playStopBtn.text = "Stop"
		var pos = midi_player.position
		if anim_songTrack_view :
			if songview_is_displaying_degree:
				songTrackView.set_playing_pos_ticks(fmod(pos,progression_track_length))
			else:
				songTrackView.set_playing_pos_ticks(pos)
			
			playHead.modulate.a = .5 + .5 *(sin(pos * 2*PI / 480))
			playHead.show()
			$playing_step_lbl.show()
			var pat_pos = (midi_player.position ) / (7680 * current_step_beat_value) 
			var num_pattern = int(pat_pos) % gp.pattern_sequence.size()
			
			var decimal_part = pat_pos - floor(pat_pos)
			
			$playing_step_lbl.text = "Playing pattern #" + str(num_pattern +1)
			$playing_step_lbl.modulate.a = 1 -  decimal_part

	else :
		$playing_step_lbl.hide()
		$Pattern/preview_btn.text = "Preview"
		playStopBtn.text = "Play"
		pattern.preview_playing = false
		if song_playing_ended == false :
			song_playing_ended = true
			rewind()
			playStopBtn.text = "Play"	
			playHead.hide()


# gestion du clavier

func _input(event):
	if event is InputEventKey and pattern_lineEdit.has_focus() == false:
		#accept_event()
		if  event.is_released():
			return



		if event.scancode == KEY_SPACE :
			_on_playStop_btn_pressed()
			accept_event()



func dummy_song()->Song:
	var dummySong = Song.new()
	var degrees = [1,2,5,6]
	var k:HarmonicKey = HarmonicKey.new()
	k.root_midi = 69
	k.scale_name = "harmonic_minor"
	
	var prog_track = Track.new()
	
	prog_track.name = Song.PROGRESSION_TRACK_NAME
	for n in degrees:
		var d:Degree = Degree.new()
		d.degree_number = n
		d.length_beats = 4
		d.key = k
		prog_track.add_degree(prog_track.length_beats,d)
	
	dummySong.add_track(prog_track)
	return dummySong
		
#func setup_scene():
#
#	set_display_degrees()
#	songTrackView.set_degree_display("jazzchord")
#	songTrackView.select_wrapper(songTrackView._wrappers[0])
#
#	guitar_voicing_view.rect_min_size = Vector2(260, 280)
#	# remplit chords_array
#	var degreeTrack:Track = songTrackView.get_track()
#	for d in degreeTrack.
		
			
	#guitar_player.chord_grid.append()
			

#	guitar_voicing_view.set_voicings(chords_array[0]["guitar_chords"])

	
	
	#$Pattern.current = 0
	$Pattern._update_pattern_display()
	
func set_display_degrees():
	songTrackView.song = myMasterSong
	songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
	
			
func _on_trackDisplayMode_item_selected(index):
	if index == 0 :
		#myPlayingSong = computeGuitarSong()
		songTrackView.song = myPlayingSong
		songTrackView.trackName = Song.RYTHM_GUITAR_TRACK
		songTrackView.set_degree_display("midi")
	elif index == 1 :
		set_display_degrees()
		songTrackView.set_degree_display("jazzchord")
	elif index == 2 :
		set_display_degrees()
		songTrackView.set_degree_display("roman")
	elif index == 3 :
		set_display_degrees()
		songTrackView.set_degree_display("keyboard")
		
	songTrackView.update()


func _on_trackViewScale_sl_value_changed(value):
	songTrackView.set_scale(value)
	

func _on_log_entry(entry):
	#entry = {time_str, msec, level, tag, message}
	var level = entry["level"]
	var tag = entry["tag"]
	var message = entry["message"]
	
	if level == "INFO":
		#console.text += level + "|"  + tag + "|" + message + "\n"
		console.text +=  message + "\n"
	else :
		console.text += level + "|"  + tag + "|" + message + "\n"
	#console.set_scroll_follow(true)

func clear_console():
	console.text = ""


func _on_SongTrackView_element_clicked(element, index, wrapper):
	
	
	clear_console()
	selected_chord_index = index

	var d:Degree= element
	var voicings = d.guitar_chords()
	var voicing_number = d.chord_voicing_index % voicings.size()
	var current_voicing = voicings[voicing_number]
	#var guitar_player.chord_grid[index]  = 
	
	guitar_voicing_view.set_voicings(voicings) 
	guitar_voicing_view.set_voicing_index(voicing_number)
	guitar_voicing_view.update()


	var pos = wrapper.get_meta("start_time")
	var pattern_index = gp.get_strum_pattern_index_at_pos(pos)
	$Pattern/pattern_number_sb._on_pattern_number_sb_value_changed(pattern_index+1)

	play_chord(current_voicing)
	LogBus.info(TAG,str(voicings.size()) + " voicings available")
	
#
	
func _on_voicing_view_voicing_index_changed(current, total):
	#var guitar_player:FolkGuitarPlayer = FolkGuitarPlayer.new()
	#clear_console()
	
	LogBus.debug(TAG,"selected_chord_index: " + str(selected_chord_index))
	var progression_track = myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME)	
	#var d:Degree = progression_track.get_degrees_array()[selected_chord_index]
	var dic = progression_track.get_degrees_with_start()[selected_chord_index]
	var d:Degree = dic["degree"]
	d.chord_voicing_index = current
	
	var gc:GuitarChord = d.guitar_chords()[current]
	gc.start = dic["start"]
	gc.length_beats = d.length_beats
	gp.chord_grid[selected_chord_index] = gc
#	gp.chord_grid[selected_chord_index] = d.guitar_chords()[current]
#	gp.chord_grid[selected_chord_index].start = dic["start"]
#	gp.chord_grid[selected_chord_index].
#	var current_guitar_chord = d.guitar_chords()[d.chord_voicing_index]
	
	
	#var gc = chords_array[selected_chord_index]["guitar_chords"][chords_array[selected_chord_index]["selected"] ]
	#update_chord_array()
	#guitar_player.chord_grid[selected_chord_index] = current_guitar_chord
#	var MasterSongDegrees = myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME).get_degrees_array()
#	var current_degree:Degree = MasterSongDegrees[selected_chord_index]
#	current_degree.chord_voicing_index = selected_chord_index

	
	play_chord(gc)
	LogBus.info(TAG,"chord voicing: " + str(current + 1) + " / " + str(total) ) 
	
func play_chord(gc:GuitarChord):
	rewind()
	midi_player.stop()
	anim_songTrack_view = false
	var current_song = Song.new()
	var chord_track = Track.new()
	var chord_pc = ProgramChange.new()
	chord_pc.set_channel(0)
	chord_pc.set_program(guitar_program_ob.get_program())
	
	chord_track.set_program_change(chord_pc)
	var delta_notes = .15
	var pos = 0
	for m in gc.midiNotes():
		var n:Note = Note.new()
		n.velocity = int(guitar_volume_vs.value)
		n.length_beats = 4
		n.midi = m
		chord_track.add_note(pos,n)
		pos += delta_notes
	current_song.add_track(chord_track)
	midi_player.load_from_bytes(current_song.get_midi_bytes_type1())
	midi_player.play()
		


	
func _on_playStop_btn_pressed():
	
	#rewindBtn.show()
	if midi_player.playing and anim_songTrack_view == true:
		#stop !
		song_playing_ended = true
		midi_player.stop()
		rewind()
		playStopBtn.text = "Play"
		$SongViewContainer/trackDisplayMode.emit_signal("item_selected", 1)
		songview_is_displaying_degree = true
	else :
		# play !
		clear_console()
		started_playing_pos = songTrackView._playing_pos_ticks
		midi_player.stop()

		playStopBtn.hide()
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame") 
		yield(get_tree(), "idle_frame") 
		#MusicLabGlobals.wait_one_frame(self)
		myPlayingSong.remove_track_by_name(Song.RYTHM_GUITAR_TRACK)
		myPlayingSong = computeGuitarSong()
		myPlayingSong.title = myMasterSong.title + " [guitar]"
		var bytes = myPlayingSong.get_midi_bytes_type1()
		#var bytes = myPlayingSong.get_midi_bytes_type1()
		midi_player.load_from_bytes(bytes)
		if marker_starting_pos_in_ticks > -1 :
			posInTicks = marker_starting_pos_in_ticks
		else:
			posInTicks = 480 * (songTrackView.get_scroll_beats())
		anim_songTrack_view = true
		$SongViewContainer/trackDisplayMode.emit_signal("item_selected", 0)
		songview_is_displaying_degree = false
		playStopBtn.show()
		playStopBtn.text = "Stop"
		LogBus.info(TAG,"Playing...")
		yield(get_tree(), "idle_frame") 
		yield(get_tree(), "idle_frame") 
		yield(get_tree(), "idle_frame") 
		
		song_playing_ended = false
		midi_player.play(posInTicks)	
	
func _on_rewind_btn_pressed():
	rewind()
		
func rewind() :
	clear_console()
	$SongViewContainer/trackDisplayMode.emit_signal("item_selected", 1)
	marker_starting_pos_in_ticks = -1
	midi_player.stop()
	playStopBtn.text = "Play"
	songTrackView.scroll_to_pos(0,.5)
	#songTrackView.update_ui()
	#rewindBtn.hide()


func computeGuitarSong(with_program_change:bool = true) -> Song:
	
	#var guitar_player:FolkGuitarPlayer = FolkGuitarPlayer.new()
	
	var song:Song = Song.new()
	song.tempo_bpm = myMasterSong.tempo_bpm
	song.time_num = myMasterSong.time_num
	song.time_den = myMasterSong.time_den
	
	var transpose = $octave/HBoxContainer/octave_offset_vs.value * 12
	var volume_guitare = $Volume/Volumes/guitar_volume/Guitar_volume_VS.value
	var volume_chords = $Volume/Volumes/Chords_volume/Chords_volume_VS.value
	var volume_basse = $Volume/Volumes/bass_volume/Bass_volume_VS.value
	
	var program_change_guitare = $instruments/guitar_program_ob.get_program_change()
	var program_change_bass = $instruments/bass_program_ob.get_program_change()
	var program_change_chords = $instruments/satb_program_ob.get_program_change()
	
	# On reconstruit chord_grid depuis myMasterSong

	var progression_track = myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME).clone()
	
	
	



	for gc in gp.chord_grid:
		LogBus.debug(TAG,gc.to_string())
		
	
	#var guitar_score =  gp.generate()
	#MusicLabGlobals.save_text_html5(JSON.print(guitar_score,"\t"), "guitar_score.txt")
	var guitar_track = gp.generate_track(transpose)
	guitar_track.channel = 0
	guitar_track.adopt_channel = true
	

	var bass_track = myMasterSong.get_track_by_name(Song.SATB_BASS).clone()
	bass_track.name = "Bass"
	bass_track.channel = 1
	bass_track.adopt_channel = true
	bass_track.transpose_octave(-1)
	
	
	var Chords_track = myMasterSong.get_track_by_name(Song.SATB_TRACK_NAME).clone()
	Chords_track.name = "SATB Chords"
	Chords_track.channel = 2
	Chords_track.adopt_channel = true
	
	
	# ON AJOUTE LES CONTROLEURS
	if with_program_change :
		var midi_cc_volume_guitare:MidiCC = MidiCC.new()
		midi_cc_volume_guitare.set_controller(7)
		midi_cc_volume_guitare.set_value(volume_guitare)
		guitar_track.add_midiCC(0,midi_cc_volume_guitare)

		var midi_cc_volume_basse:MidiCC = MidiCC.new()
		midi_cc_volume_basse.set_controller(7)
		midi_cc_volume_basse.set_value(volume_basse)
		bass_track.add_midiCC(0,midi_cc_volume_basse)

		var midi_cc_volume_chords:MidiCC = MidiCC.new()
		midi_cc_volume_chords.set_controller(7)
		midi_cc_volume_chords.set_value(volume_chords)
		Chords_track.add_midiCC(0,midi_cc_volume_chords)

		guitar_track.program_change = program_change_guitare
		bass_track.program_change = program_change_bass
		Chords_track.program_change = program_change_chords
		
	
	var duree_beats_song = guitar_track.length_beats
	var duree_progression = bass_track.length_beats
	
	
	var multiplier = floor(duree_beats_song/duree_progression) + 1
	bass_track.multiply(multiplier,false)
	Chords_track.multiply(multiplier,false)
#	for i in range(0,multiplier):
#		bass_track.merge_track(bass_track,bass_track.length_beats,false)
#		Chords_track.merge_track(Chords_track,Chords_track.length_beats,false)

	bass_track = bass_track.extract(0,duree_beats_song)
	Chords_track = Chords_track.extract(0,duree_beats_song)
	
	 
	
	song.add_track(guitar_track)
	song.add_track(bass_track)	
	song.add_track(Chords_track)

	return song
	

func _save_text_to_disk(content: String, filename: String) -> void:
	# Écrit dans user:// (persistance locale; en HTML5 = IndexedDB)
	var path = "user://" + filename
	var f = File.new()
	var err = f.open(path, File.WRITE)
	if err == OK:
		f.store_string(content)
		f.close()


func _on_Export_console_btn_pressed():
	_save_text_to_disk(console.text, "console.txt")
	LogBus.info(TAG,'Console.txt exported to "user://console.txt"')


func _on_Export_midi_btn_pressed():
	var myExported_song = computeGuitarSong(false)
	
	var mime_type = "audio/midi"	
	var filename = myMasterSong.title + "[GUITAR].mid"
	var bytes: PoolByteArray = myExported_song.get_midi_bytes_type1()
	if bytes.size() <= 0:
		LogBus.error("[MidiExport]","No Midi Bytes to export (bytes.size == 0).")
		return
	
	if OS.has_feature("HTML5") and Engine.has_singleton("JavaScript"):
		_html5_download_bytes(bytes, filename, mime_type)
	else:
		_save_locally(bytes, "user://" + filename)
		LogBus.info("[MidiExport]", "midifile Exported to user://" + filename)

func _html5_download_bytes(bytes: PoolByteArray, fname: String, mime: String) -> void:
	# Encode en base64 côté Godot (rapide et fiable)
	var b64: String = Marshalls.raw_to_base64(bytes)
	
	# Installe une fonction JS si absente, puis appelle le download
	var js_win = JavaScript.get_interface("window")
	if js_win == null:
		LogBus.error(TAG,"[MidiExport] JavaScript window interface non available.")
		printerr("[MidiExport] JavaScript window interface non disponible.")
		return
	
	if not js_win.has("musiclib_download_b64"):
		var code = ""
		code += "window.musiclib_download_b64 = function(b64, filename, mime) {"
		code += "  try {"
		code += "    var bin = atob(b64);"
		code += "    var len = bin.length;"
		code += "    var arr = new Uint8Array(len);"
		code += "    for (var i = 0; i < len; i++) arr[i] = bin.charCodeAt(i);"
		code += "    var blob = new Blob([arr], {type: mime || 'application/octet-stream'});"
		code += "    var a = document.createElement('a');"
		code += "    a.href = URL.createObjectURL(blob);"
		code += "    a.download = filename || 'export.bin';"
		code += "    document.body.appendChild(a);"
		code += "    a.click();"
		code += "    setTimeout(function(){ URL.revokeObjectURL(a.href); a.remove(); }, 0);"
		code += "  } catch(e) { console.error('musiclib_download_b64 error', e); }"
		code += "};"
		JavaScript.eval(code, true)	#﻿
	
	if OS.has_feature("HTML5") and Engine.has_singleton("JavaScript"):
		# Appel direct
		js_win.musiclib_download_b64(b64, fname, mime)
	else:
		LogBus.error(TAG,"[MidiExport] JavaScript environment required for export.")


func _save_locally(bytes: PoolByteArray, path: String) -> void:
	var f = File.new()
	var err = f.open(path, File.WRITE)
	if err != OK:
		LogBus.error("[MidiExport]","Cannot open file: " +  path + " code=" + err)
		return
	f.store_buffer(bytes)
	f.close()


func _on_clear_console_btn_pressed():
	clear_console()



func get_player_config()->Dictionary:
	var config:Dictionary = {
		"max_chords_strings":max_chords_strings.value,
		"swing_amount":swing_amount.value,
		"strum_duration_min":strum_duration_min.value,
		"strum_duration_max":strum_duration_max.value,
		"velocity_randomization":velocity_randomization.value,
		"mute_duration":mute_duration.value,
		"accent_downbeat_factor":accent_downbeat_factor.value,
		"humanize_timing": true,
		"timing_variance":timing_variance.value,
		"velocity_down_base":down_velocity_base.value,
		"velocity_down_light":down_velocity_light.value,
		"velocity_up_base":up_velocity_base.value,
		"velocity_up_light":up_velocity_light.value,
		"pick_position":pick_position.value,
		"pick_position_influence":pick_influence.value,
		"chord_transition_gap":chord_transition_gap.value,
		"single_note_velocity":single_note_velocity.value
	}	
	
	return config
	
func set_player_config(s:StrumPattern):
	yield(get_tree(), "idle_frame") 
	#var a:Array = s.config_override
	var config_dico =  s.config_override
	max_chords_strings.value = config_dico["max_chords_strings"]
	swing_amount.value = config_dico["swing_amount"]
	strum_duration_min.value = config_dico["strum_duration_min"]
	strum_duration_max.value = config_dico["strum_duration_max"]
	mute_duration.value = config_dico["mute_duration"]
	velocity_randomization.value = config_dico["velocity_randomization"]
	accent_downbeat_factor.value = config_dico["accent_downbeat_factor"]
	timing_variance.value = config_dico["timing_variance"]
	down_velocity_base.value =  config_dico["velocity_down_base"]
	down_velocity_light.value = config_dico["velocity_down_light"]
	up_velocity_base.value = config_dico["velocity_up_base"]
	up_velocity_light.value = config_dico["velocity_up_light"]
	pick_position.value = config_dico["pick_position"]
	pick_influence.value = config_dico["pick_position_influence"]
	chord_transition_gap.value = config_dico["chord_transition_gap"]
	single_note_velocity.value = config_dico["single_note_velocity"]
#	"chord_transition_gap":chord_transition_gap.value,
#	"single_note_velocity":single_note_velocity.value
#
	




func _on_duplicate_btn_pressed():
	var current_pattern_index = pattern.current
	var new_pattern:StrumPattern = gp.pattern_sequence[current_pattern_index].clone()
	gp.pattern_sequence.insert(current_pattern_index + 1,new_pattern)
	$Pattern/pattern_number_sb.value += 1
	$Pattern/delete_btn.show()
	rewind()
	LogBus.info(TAG,"Pattern duplicated")


func _on_duplicate_all_btn_pressed():
	midi_player.stop()
	var new_sequence = []
	for sp in gp.pattern_sequence:
		var new_sp:StrumPattern  = sp.clone()
		new_sequence.append(new_sp)
	gp.pattern_sequence.append_array(new_sequence)
	$Pattern/delete_btn.show()
	$Pattern/pattern_number_sb.value = gp.pattern_sequence.size()
	rewind()
	LogBus.info(TAG,"Pattern Sequence duplicated")

func _on_Export_tabs_pressed():
	var txt = gp.generate_ascii_tab(4,80,true)
	
	#_save_text_to_disk(txt,"tabs.txt")
	var title = myMasterSong.title + " [TABS].txt"
	MusicLabGlobals.save_text_html5(txt,title)




func _on_Menu_btn_pressed():
	midi_player.stop()
	myMasterSong.strum_pattern_array = gp.pattern_sequence
	myMasterSong.guitar_player_scene_params = get_dico_from_interface_sliders()
	myMasterSong.remove_track_by_name(Song.RYTHM_GUITAR_TRACK)
	MusicLabGlobals.set_song(myMasterSong)
	MusicLabGlobals.save_current_song_autosave()
	get_tree().get_root().get_node("Main").change_scene_preloaded("menu")



func _on_copy_btn_pressed():
	var current_pattern_index = pattern.current
	copy_pattern_buffer = gp.pattern_sequence[current_pattern_index].clone()
	$Pattern/paste_btn.show()
	clear_console()
	LogBus.info(TAG,"Current pattern copied to the clipboard")
	
	
func _on_paste_btn_pressed():
	var current_pattern_index = pattern.current
	gp.pattern_sequence[current_pattern_index] = copy_pattern_buffer.clone()
	pattern._update_pattern_display()
	rewind()
	LogBus.info(TAG,"Clipboard pattern pasted")
#	var current_value = $Pattern/pattern_number_sb.value 
#	$Pattern/pattern_number_sb.value  = current_value





func slider_updated(value):
	if scene_is_ready:
		rewind()



func _on_view_midi_btn_pressed():
	songview_is_displaying_degree = false
	#myPlayingSong = computeGuitarSong()
	songTrackView.song = myPlayingSong
	songTrackView.trackName = Song.RYTHM_GUITAR_TRACK
	songTrackView.set_degree_display("midi")
	songview_is_displaying_degree = true


func _on_view_degrees_pressed():
	set_display_degrees()
	songTrackView.set_degree_display("jazzchord")
	songview_is_displaying_degree = true
	
func _on_view_roman_btn_pressed():
	set_display_degrees()
	songTrackView.set_degree_display("roman")
	songview_is_displaying_degree = true




func _on_Debug_btn_pressed():
	clear_console()
	LogBus.debug(TAG,"gp.chord_grid.size(): " + str(gp.chord_grid.size()))
	for gc in gp.chord_grid:
		LogBus.debug(TAG,"gc.start: " + str(gc.start) + " midiNotes: " + str( gc.midiNotes) + "length: " + str(gc.length_beats))
	LogBus.debug(TAG,"gp.pattern_sequence.size(): " + str(gp.pattern_sequence.size()))


