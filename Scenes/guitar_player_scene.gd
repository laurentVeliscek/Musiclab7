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
onready var rewindBtn:Button = $Transport/rewind_btn

onready var guitar_program_ob:OptionButton = $instruments/guitar_program_ob
onready var bass_program_ob:OptionButton = $instruments/bass_program_ob
onready var satb_program_ob:OptionButton = $instruments/satb_program_ob

onready var guitar_volume_vs:VSlider = $Volume/Volumes/guitar_volume/Guitar_volume_VS
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

var song_playing_ended:bool = true
var myPlayingSong:Song = Song.new()

var posInTicks :int = 0
var started_playing_pos = 0
var marker_starting_pos_in_ticks:int = -1
var anim_songTrack_view = false

var chords_array = []
var chord_select = null
var selected_chord_index = 0

onready var guitar_player:FolkGuitarPlayer = FolkGuitarPlayer.new()
 
func _ready():
	# midiPlayerSetup
	
	musiclibMidiPlayer.setupMidiPlayer()
	midi_player = musiclibMidiPlayer.midiPlayer
	guitar_program_ob.set_program(25)
	bass_program_ob.set_program(32)
	satb_program_ob.set_program(16)
	
	
	myMasterSong = MusicLabGlobals.get_song()
	if myMasterSong == null:
		myMasterSong = dummy_song()
	#print(myMasterSong.to_string())
	songTrackView.song = myMasterSong
	songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
	setup_scene()
	
	LogBus.connect("log_entry", self, "_on_log_entry")
	LogBus._verbose = true
	LogBus.info(TAG,"Select a chord to set the guitar chord voicing")
	#clear_console()
	var sp:StrumPattern = StrumPattern.new()
	guitar_player.pattern_sequence = [sp]

func _process(_delta):
	if midi_player.playing :
		if anim_songTrack_view :
			playStopBtn.text = "Stop"
		var pos = midi_player.position
		if anim_songTrack_view :
			songTrackView.set_playing_pos_ticks(pos)
			playHead.modulate.a = .5 + .5 *(sin(pos * 2*PI / 480))
			playHead.show()
		#$tracePos_label.text = str(pos)
	else :
		if song_playing_ended == false :
			song_playing_ended = true
			playStopBtn.text = "Play"	
			playHead.hide()
			rewind()



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
		
func setup_scene():
	# songTrackView
	set_display_degrees()
	songTrackView.set_degree_display("jazzchord")
	songTrackView.select_wrapper(songTrackView._wrappers[0])
	# guitarChordView
	#voicings_container.add_child(guitar_voicing_view)
	guitar_voicing_view.rect_min_size = Vector2(260, 280)
	# remplit chords_array
	var degreeTrack:Track = songTrackView.get_track()
	for e in degreeTrack.events:
		if typeof(e) == TYPE_DICTIONARY and e.has("degree") and e.has("start"):
			var d:Degree = e["degree"]
			var time = e["start"]
			var g_chords = d.guitar_chords()
			for gc in g_chords:
				gc.time = time
				gc.beat_length = d.length_beats
		
			var chord:Dictionary = {"selected":0, "guitar_chords":g_chords}
			chords_array.append(chord)
			
	# on affiche le premier voicing du premier accord
	#var displayed_chord:GuitarChord =  chords_array[0]["chords"][0]
	guitar_voicing_view.set_voicings(chords_array[0]["guitar_chords"])
	#view.set_chord(gc)
	update_chord_array()
	
	
	#$Pattern.current = 0
	$Pattern._update_pattern_display()
	
func set_display_degrees():
	songTrackView.song = myMasterSong
	songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
	
			
func _on_trackDisplayMode_item_selected(index):
	if index == 0 :
		myPlayingSong = computeGuitarSong()
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
	var gc_array = chords_array[index]
	var selected = gc_array["selected"]
	guitar_voicing_view.set_voicings(gc_array["guitar_chords"]) 
	guitar_voicing_view.set_voicing_index(selected)
	
	
	guitar_voicing_view.update()
	selected_chord_index = index

	
	
	
	if gc_array["guitar_chords"].size() > 1:
		LogBus.info(TAG,str(gc_array["guitar_chords"].size()) + " voicings available\n")
		LogBus.info(TAG,"Use arrows on the tablature to change the chord voicing...")
	else :	
		LogBus.info(TAG,"One voicing available")
	var gc:GuitarChord =  gc_array["guitar_chords"][gc_array["selected"]]

	var pos = wrapper.get_meta("start_time")

	var pattern_index = guitar_player.get_strum_pattern_index_at_pos(pos)
	$Pattern/pattern_number_sb._on_pattern_number_sb_value_changed(pattern_index+1)

	play_chord(gc)
	
	
func _on_voicing_view_voicing_index_changed(current, total):

	chords_array[selected_chord_index]["selected"] = current
	clear_console()
	LogBus.info(TAG,"chord voicing: " + str(current + 1) + " / " + str(total) ) 
	var gc = chords_array[selected_chord_index]["guitar_chords"][chords_array[selected_chord_index]["selected"] ]
	update_chord_array()
	play_chord(gc)
	
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
	song_playing_ended = false
	rewindBtn.show()
	if midi_player.playing and anim_songTrack_view == true:
		#stop !
		song_playing_ended = true
		midi_player.stop()
		playStopBtn.text = "Play"
		$SongViewContainer/trackDisplayMode.emit_signal("item_selected", 1)
	else :
		# play !
		started_playing_pos = songTrackView._playing_pos_ticks
		midi_player.stop()
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
		playStopBtn.text = "Stop"
		yield(get_tree(), "idle_frame") 
		midi_player.play(posInTicks)	
	
func _on_rewind_btn_pressed():
	rewind()
		
func rewind() :
	$SongViewContainer/trackDisplayMode.emit_signal("item_selected", 1)
	marker_starting_pos_in_ticks = -1
	midi_player.stop()
	playStopBtn.text = "Play"
	songTrackView.scroll_to_pos(0,.5)
	#songTrackView.update_ui()
	rewindBtn.hide()


func computeGuitarSong(with_program_change:bool = true) -> Song:

	var notes = guitar_player.generate()
	
	var guitarTrack:Track = Track.new()
	guitarTrack.channel = 1
	guitarTrack.adopt_channel = true
	guitarTrack.name = Song.RYTHM_GUITAR_TRACK
	var guitar_pc = ProgramChange.new()
	guitar_pc.set_channel(1)
	guitar_pc.set_program(guitar_program_ob.get_program())
	
	if with_program_change:
		guitarTrack.set_program_change(guitar_pc)
	
	

	for n in notes:
		var note:Note = Note.new()
		note.midi = n["pitch"] + (octave_offset_vs.value)*12
		note.length_beats = n["duration"]
		note.velocity = n["velocity"]
		guitarTrack.add_note( n["position"],note)

	
	var mySong:Song = Song.new()
	mySong.tempo_bpm = myMasterSong.tempo_bpm
	mySong.title = myMasterSong.title + " [guitar]"
	mySong.add_track(guitarTrack)
	
	
	# on ajoute le SATB
#	var satb_track = myMasterSong.get_track_by_name(Song.SATB_TRACK_NAME).clone()
#
#	satb_track.channel = 2
#	satb_track.adopt_channel = true
#	#satb_track.name = Song.RYTHM_GUITAR_TRACK
#	var satb_pc = ProgramChange.new()
#	satb_pc.set_channel(2)
#	satb_pc.set_program(satb_program_ob.get_program())
#
#	if with_program_change:
#		satb_track.set_program_change(satb_pc)
#
#	mySong.add_track(satb_track)
#
	return mySong
	

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
	var mime_type = "audio/midi"	
	var filename = myPlayingSong.title + ".mid"
	var bytes: PoolByteArray = myPlayingSong.get_midi_bytes_type1()
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
	


#func _on_step_beat_length_btn_pressed():
#	match button.text:
#		# double croche
#		"$":
#			step_beat_length_btn.text = "."
#		".":
#			step_beat_length_btn.text = ")"
#		")":
#			step_beat_length_btn.text = "$"
			
func update_chord_array():
	var chord_grid:Array = []
	for c in chords_array:
		chord_grid.append(c["guitar_chords"][c["selected"]])
		guitar_player.chord_grid = chord_grid
		



func _on_duplicate_btn_pressed():
	var current_pattern_index = pattern.current
	var new_pattern:StrumPattern = guitar_player.pattern_sequence[current_pattern_index].clone()
	guitar_player.pattern_sequence.insert(current_pattern_index + 1,new_pattern)
	$Pattern/pattern_number_sb.value += 1
	$Pattern/delete_btn.show()
	clear_console()
	LogBus.info(TAG,"Pattern duplicated")
	midi_player.stop()
	
func _on_Export_tabs_pressed():
	var txt = guitar_player.generate_ascii_tab(4,80,true)
	#LogBus.info(TAG,txt)
	_save_text_to_disk(txt,"tabs.txt")
	




func _on_Menu_btn_pressed():
	midi_player.stop()
	get_tree().get_root().get_node("Main").change_scene_preloaded("menu")
