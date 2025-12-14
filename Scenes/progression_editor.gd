extends Control

const TAG = "Musiclab"

const TONAL_KEYS:Array = ["major","minor","harmonic_minor", "melodic_minor"  ]



#const mySoundFontPath = "res://soundfonts/Aspirin-Stereo.sf2"
onready var midi_player:MidiPlayer 
onready var songTrackView:SongTrackView = $SongViewContainer/SongTrackView
onready var playStopBtn:Button = $Transport/playStop_btn
onready var menu_btn:Button = $Transport/menu_btn
onready var rewindBtn:Button = $Transport/rewind_btn
onready var playHead:ColorRect = $SongViewContainer/play_head_cr
onready var console:RichTextLabel = $console_panel_pn/logBusConsole_rtl
onready var export_midi_btn:Button = $"Transport/Export midi_btn"
onready var midi_export_dialog: FileDialog = $ExportMidiDialog
onready var songTrackView_view_display_mode_option = $SongViewContainer/trackDisplayMode
onready var songTrackView_scale_option = $SongViewContainer/trackViewScale_sl
onready var song_title_lbl:LineEdit = $Song_panel/title_line_edit
onready var time_signature_ob:OptionButton = $Song_panel/time_signature_optButton
onready var scale_select_ob:OptionButton = $Song_panel/scale_select_ob
onready var key_root_select_ob = $Song_panel/key_root_select_ob

onready var two_chords_per_bar_sb:CheckBox = $Song_panel/twoChordsprBar_cb
onready var satb_client = $SATB/SATBClient
onready var web_api_mode_btn:CheckButton = $CenterTabContainer/SATB/interface_switch/web_api_mode_checkButton
onready var legato_midi_cb:CheckButton = $CenterTabContainer/SATB/interface_switch/legato_midi_file_cb
onready var separate_satb_cb:CheckButton = $CenterTabContainer/SATB/interface_switch/separate_cb

#onready var satb_solution_selector_knob:Numeric_Knob = $SATB_Listen_panel/satb_solution_selector_knob
onready var satb_solution_Slider:HSlider = $CenterTabContainer/SATB/SATB_Listen_panel/satb_solution_Slider
onready var free_inversion_cb = $CenterTabContainer/SATB/VBoxContainer/manettes/SATB_checkbox/free_inversion_cb
onready var allow_repetition_cb = $CenterTabContainer/SATB/VBoxContainer/manettes/SATB_checkbox/allow_repetition_cb

onready var generate_btn = $Transport/Generate_btn
onready var compute_satb_btn = $Transport/compute_SATB_btn
onready var edit_progression_btn = $Transport/Edit_Progression_Btn

onready var parallel_Fifths_penalty_SL = $CenterTabContainer/SATB/VBoxContainer/manettes/penalty_panel/Penalty_container/para_fifths_penalty_SL
onready var parallel_octave_penalty_SL = $CenterTabContainer/SATB/VBoxContainer/manettes/penalty_panel/Penalty_container/para_octave_penalty_SL
onready var total_movement_factor_SL = $CenterTabContainer/SATB/VBoxContainer/manettes/penalty_panel/Penalty_container/total_movement_factor_SL
onready var leap_penalty_SL = $CenterTabContainer/SATB/VBoxContainer/manettes/penalty_panel/Penalty_container/leap_penalty_SL
onready var voicing_repetition_penalty_SL = $CenterTabContainer/SATB/VBoxContainer/manettes/penalty_panel/Penalty_container/voicing_repetition_penalty_SL2

onready var common_note_bonus_SL = $CenterTabContainer/SATB/VBoxContainer/manettes/Bonus_panel/Bonus_Container/common_note_bonus_SL
onready var contrary_motion_bonus_SL = $CenterTabContainer/SATB/VBoxContainer/manettes/Bonus_panel/Bonus_Container/contrary_motion_bonus_SL
onready var Leading_tone_resolution_bonus_SL = $CenterTabContainer/SATB/VBoxContainer/manettes/Bonus_panel/Bonus_Container/Leading_tone_resolution_bonus_SL
onready var conjunct_motion_bonus_SL = $CenterTabContainer/SATB/VBoxContainer/manettes/Bonus_panel/Bonus_Container/conjunct_motion_bonus_SL
onready var bass_conjunct_bonus_SL = $CenterTabContainer/SATB/VBoxContainer/manettes/Bonus_panel/Bonus_Container/bass_conjunct_bonus_SL
onready var soprano_conjunct_bonus_SL = $CenterTabContainer/SATB/VBoxContainer/manettes/Bonus_panel/Bonus_Container/soprano_conjunct_bonus_SL

onready	var temperature_SL  = $CenterTabContainer/SATB/VBoxContainer/manettes/SATB_params_panel/HBoxContainer/temperature_SL
onready	var temperature_proba_SL = $CenterTabContainer/SATB/VBoxContainer/manettes/SATB_params_panel/HBoxContainer/temp_proba_SL
onready var center_target_SL = $CenterTabContainer/SATB/VBoxContainer/manettes/SATB_params_panel/HBoxContainer/center_target_SL
onready var best_distance_SL = $CenterTabContainer/SATB/VBoxContainer/manettes/SATB_params_panel/HBoxContainer/best_distance_SL
onready var distance_scoring_SL = $CenterTabContainer/SATB/VBoxContainer/manettes/SATB_params_panel/HBoxContainer/distance_scoring_SL
onready var center_scoring_SL = $CenterTabContainer/SATB/VBoxContainer/manettes/SATB_params_panel/HBoxContainer/center_scoring_SL

onready var track_clip_board:Track = Track.new()
onready var key_command = 16777239

onready var center_tab_container:TabContainer = $CenterTabContainer

onready var pivot_chord_cb:CheckBox =  $CenterTabContainer/Modulation/HContainer/Techniques/Pivot_chord_cb
onready var other_technique_cb:CheckBox =  $CenterTabContainer/Modulation/HContainer/Techniques/other_technique_cb
onready var chromatic_cb:CheckBox = $CenterTabContainer/Modulation/HContainer/Techniques/chromatic_cb
onready var random_modulation_cb:CheckBox =  $CenterTabContainer/Modulation/HContainer/settings/random_cb


onready var pop_cb:CheckBox = $CenterTabContainer/Modulation/HContainer/style/pop_cb
onready var jazz_cb:CheckBox =  $CenterTabContainer/Modulation/HContainer/style/jazz_cb
onready var romantic_cb:CheckBox = $CenterTabContainer/Modulation/HContainer/style/romantic_cb
onready var classical_cb:CheckBox = $CenterTabContainer/Modulation/HContainer/style/classical_cb


onready var Dico = Harmony_dictionary.new()

#onready var no_inversion_cb = 

var satbs: Array = []

var myMasterSong:Song = Song.new()
var myPlayingSong:Song = Song.new()

var song_playing_ended:bool = true
var posInTicks :int = 0
var started_playing_pos = 0
var marker_starting_pos_in_ticks:int = -1
var anim_songTrack_view = false


#var myProgressionTrack:Track = Track.new()
var mySATBTrack:Track = Track.new()
var mySATB_Soprano:Track = Track.new()
var mySATB_Alto:Track = Track.new()
var mySATB_Tenor:Track = Track.new()
var mySATB_Bass:Track = Track.new()
var satb_solutions_array: Array = []
#onready var solver = $solverNode
var is_displaying_SATB:bool = false
var is_computing_satb:bool = false

var _pending_midi_bytes: PoolByteArray = PoolByteArray()

var _undo_tracks:Array = []
var _redo_tracks:Array = []
var _max_undo_levels = 1000


var rng:RandomNumberGenerator = RandomNumberGenerator.new()

var base_url: String
var RP:RockProgressionGenerator = RockProgressionGenerator.new()

var MDB:ModulationDatabase = MusicLabGlobals.modulationDatabase
var modManager:ModulationManager

var tonalProgressionHelper = TonalProgressionHelper.new()

var mode_debug = false

func _ready():
	# Connection LogBus à la console 
	LogBus.connect("log_entry", self, "_on_log_entry")
	LogBus._verbose = true
	LogBus.info(TAG,"Welcome to MusicLab© by Laurent Veliscek\n")

	midi_player= MusicLabGlobals.midi_player
	#MusicLabGlobals.set_sound_Font(MusicLabGlobals.SOUND_FONT_ESSENTIAL_KEYS)
#	key_command = 16777239
#	else :
#		os_keyboard_BTN.text = "Windows Keyboard"
#		key_command = KEY_CONTROL
#
	key_command = MusicLabGlobals.key_command
	
	# Détecter l'environnement
	if OS.has_feature("editor"):
		base_url = "http://127.0.0.1:8000"

	else:
		base_url = "https://www.theparselmouth.com/musiclab/api/"
		$CenterTabContainer/SATB/interface_switch/web_api_mode_checkButton.hide()
		$debug_btn.hide()
		#LogBus.info(TAG,"💻 Mode natif - API locale")
	
	if mode_debug == false:
		$debug_btn.hide()

	satb_client.api_url  = base_url
	satb_client.test_connection()

	rng = MusicLabGlobals.rng
	tonalProgressionHelper.rng = rng
	
	$Song_panel/seed_sb.get_line_edit().text = str(rng.randi() % 999999999)

	# midi_player
	#musiclibMidiPlayer.setupMidiPlayer()
	#midi_player = musiclibMidiPlayer.midiPlayer
	#MusicLabGlobals.setup_midi_player()

	midi_export_dialog.mode = FileDialog.MODE_SAVE_FILE
	midi_export_dialog.access = FileDialog.ACCESS_FILESYSTEM
	midi_export_dialog.clear_filters()
	midi_export_dialog.add_filter("*.mid ; MIDI File")
	midi_export_dialog.current_dir = MusicLabGlobals.get_midi_directory()
	if not midi_export_dialog.is_connected("file_selected", self, "_on_ExportMidiDialog_file_selected"):
			midi_export_dialog.connect("file_selected", self, "_on_ExportMidiDialog_file_selected")
	
	#guitar_base
	var nb_chords = MusicLabGlobals.GuitarBase._all_chords.size()
	LogBus.info(TAG,"Guitar Chord Database Loaded: " + str(nb_chords)+" chords")
	
	
	LogBus.info(TAG,"\nTrying to connect to SATB Engine "+satb_client.api_url)
	
	myMasterSong =  MusicLabGlobals.get_song()
	
	#on détruit les pistes SATB
	# elles seront forcément régénérées
	if myMasterSong:
		
		myMasterSong.remove_track_by_name(Song.SATB_TRACK_NAME)
		myMasterSong.remove_track_by_name(Song.SATB_SOPRANO)
		myMasterSong.remove_track_by_name(Song.SATB_ALTO)	
		myMasterSong.remove_track_by_name(Song.SATB_TENOR)
		myMasterSong.remove_track_by_name(Song.SATB_BASS)
		
	if myMasterSong == null or myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME) == null:
		myMasterSong = Song.new()
		myMasterSong.title = "Untitled Song"
		var new_progression_track:Track = Track.new()
		new_progression_track.name = Song.PROGRESSION_TRACK_NAME
		myMasterSong.add_track(new_progression_track)
		
	
	myPlayingSong = myMasterSong
	#myPlayingSong.title = myMasterSong.title
	#myPlayingSong.add_track(myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME))	
		

	
	songTrackView.song = myMasterSong
	songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
	songTrackView.set_degree_display("roman")
	# pour capturer la touche espace
	#self.grab_focus()
	
	# modulationDatabase
	#LogBus.info(TAG,"MDB: "+ MDB.stats())
	
	var myProgTrack = songTrackView.song.get_track_by_name(Song.PROGRESSION_TRACK_NAME)
	if myProgTrack == null or myProgTrack.get_degrees_array().size() == 0:
		compute_satb_btn.hide()
		edit_progression_btn.hide()
		playStopBtn.hide()
		rewindBtn.hide()
		playHead.hide()
		export_midi_btn.hide()
		#satb_solution_selector_knob.hide()
		satb_solution_Slider.hide()
		menu_btn.hide()
	else:
		compute_satb_btn.show()
		edit_progression_btn.hide()
		playStopBtn.show()
		rewindBtn.hide()
		playHead.hide()
		export_midi_btn.show()
		#satb_solution_selector_knob.hide()
		satb_solution_Slider.hide()
		menu_btn.hide()
	
	#myScene.grab_focus()
	modManager = ModulationManager.new()
	modManager.load_modulation_database()
	
	
	yield(get_tree(), "physics_frame")
	
	
	#MusicLabGlobals.set_sound_Font(MusicLabGlobals.SOUND_FONT_DORE_MARK)
	set_song_display()
	run_debug_test()
	$program_number/program_number_ob.select(2)
	if songTrackView.get_wrappers().size() ==  0:
		no_chords()

func set_song_display():
	$Song_panel/tempo_sb.value = myMasterSong.tempo_bpm
	song_title_lbl.text = myMasterSong.title
	
func run_debug_test():
	pass
	
#	

	

		
func get_modulation_degrees(d1:Degree,d2:Degree)-> Array:
	#var progressions = []
	
	# on convertit les degrés en degrés 1 minor ou major
	var d_from = d1.clone()
	var d_to = d2.clone()
		
	# on convertit en degré 1 minor/major si besoin et si possible
	d_from.tonalize()
	d_to.tonalize()
	
	
	
	if d_from.degree_number != 1 or d_to.degree_number != 1 or ["minor","major"].has(d_from.key.scale_name) == false or ["minor","major"].has(d_to.key.scale_name) == false or d_from.kind != "diatonic" or d_to.kind != "diatonic" :
		#LogBus.info(TAG,"modulation can only be applied to diatonic major or minor chords")
		return []
	
	# on récupère toutres les modulations possibles
	#get_all_modulations(from_key:int,from_mode:String, to_key: int, to_mode:String) -> Array:
	var modulations = modManager.get_all_modulations(d_from.key.root_midi % 12,d_from.key.scale_name, d_to.key.root_midi % 12,d_to.key.scale_name)
	
	if modulations.size() == 0:
		return []
	# filter by technique
	var filtered = []
	for p in modulations:
		if pivot_chord_cb.pressed and p["modulation_technique"]=="pivot_chord":
			filtered.append(p)

		elif chromatic_cb.pressed and  p["modulation_technique"] == "chromatic":
			filtered.append(p)
		elif other_technique_cb.pressed :
			filtered.append(p)
	
	# filtre style
	modulations = filtered
	filtered = []
	for p in modulations:
		if pop_cb.pressed and p["style"].has("pop"):
			filtered.append(p)
		elif jazz_cb.pressed and p["style"].has("kazz"):
			filtered.append(p)
		elif romantic_cb.pressed and  p["style"].has("romantic") :
			filtered.append(p)
		elif classical_cb.pressed and  p["style"].has("classical") :
			filtered.append(p)
	
	
	if filtered.size() == 0:
		#LogBus.info(TAG,"No modulation Path found")
		return []
	
	LogBus.info(TAG,"modulation -> found " + str(filtered.size()) + " paths\n")
	var selected = null
	
	
	if random_modulation_cb.pressed and filtered.size() > 1:
		var solution_number = rng.randi()%filtered.size()
		LogBus.info(TAG,"choosed solution #" + str(solution_number + 1))
		selected = filtered[solution_number]
	else :
		selected = filtered[0]
		LogBus.info(TAG,"choosed best solution")
		
	LogBus.info(TAG,"modulation technique: [" + str(selected["id"]) + "] -> "+selected["modulation_technique"])

	#var quality = selected["quality"]
	#LogBus.info(TAG,"voice leading: " + str(quality["voice_leading"]))
	#LogBus.info(TAG,"chromatic direction: " + str(quality["chromatic_direction"]))
	#LogBus.info(TAG,"functional coherence: " + str(quality["functional_coherence"]))
	
#
#	var metadata = selected["metadata"]	
#	LogBus.info(TAG,"character: " + metadata["character"])
#	if metadata["warnings"] != []:
#		for w in metadata["warnings"]:
#			LogBus.info(TAG,"Warning: " + w)
	
	var degrees = []
	#var degree_offset = 0
	for c in selected["chords"]:
		var d:Degree = Degree.new()
		var k:HarmonicKey = HarmonicKey.new()
		k.root_midi = 60 + int( (c["key_root"] + d_from.key.root)) %12
		k.scale_name = c["key_mode"]
		d.key = k
		d.degree_number = c["degree_number"]
		if c["seventh"]:
			d.realization = [1,3,5,7]
		d.inversion = c["inversion"]
		var tech = selected["modulation_technique"].replace("_"," ")
		d.comment = tech + "\nmodulation: " +  c["comment"]
		degrees.append(d)
		
	return degrees
	
	
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




func _on_trackDisplayMode_item_selected(index):
	

	var selected_indexes= []
	for w in songTrackView._wrappers:
		if w.get_meta("selected") == true:
			selected_indexes.append(w.get_meta("index"))
		
	if index == 0 :
		songTrackView.set_degree_display("midi")
	elif index == 1 :
		songTrackView.set_degree_display("jazzchord")
	elif index == 2 :
		songTrackView.set_degree_display("roman")
	elif index == 3 :
		songTrackView.set_degree_display("keyboard")
		
	var wrappers = songTrackView._wrappers
	for idx in selected_indexes:
		songTrackView.select_wrapper(wrappers[idx])
	songTrackView_view_display_mode_option.select(index)
	#update_songTrackView_withSelection()

func _on_trackViewScale_sl_value_changed(value):
	
	var selected_indexes= []
	for w in songTrackView._wrappers:
		if w.get_meta("selected") == true:
			selected_indexes.append(w.get_meta("index"))	

	songTrackView.set_scale(value)

	var wrappers = songTrackView._wrappers
	for idx in selected_indexes:
		songTrackView.select_wrapper(wrappers[idx])
	#update_songTrackView_withSelection()

func _process(_delta):
	if Input.is_key_pressed(key_command):
		$CMD_LBL.show()
	else :
		$CMD_LBL.hide()
	if midi_player:
		if midi_player.playing :
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


func _on_playStop_btn_pressed():
	
	song_playing_ended = false
	rewindBtn.show()
	if midi_player.playing :
		#stop !
		song_playing_ended = true
		midi_player.stop()
		playStopBtn.text = "Play"
	else :
		# play !
		started_playing_pos = songTrackView._playing_pos_ticks
		midi_player.stop()

		
			
		var myPlayingSong_with_PC:Song = Song.new()
		myPlayingSong_with_PC.tempo_bpm = myPlayingSong.tempo_bpm
		myPlayingSong_with_PC.time_num = myPlayingSong.time_num
		myPlayingSong_with_PC.time_den = myPlayingSong.time_den
		
		
		var myPlayingProgressionTrack = myPlayingSong.get_track(0).clone()
		var pc:ProgramChange = ProgramChange.new()
		pc.set_program($program_number/program_number_ob.selected)
		myPlayingProgressionTrack.set_program_change(pc)		
		var midiCC_reverb = MidiCC.new()
		midiCC_reverb.set_controller(91)
		midiCC_reverb.set_value(15)
		myPlayingProgressionTrack.add_midiCC(0,midiCC_reverb)
		myPlayingSong_with_PC.add_track(myPlayingProgressionTrack)
		
		var bytes = myPlayingSong_with_PC.get_midi_bytes_type1()
		
		
			######### LEGATO
		#var midiBytes = myPlayingSong.get_midi_bytes_type1()
		
		var MTF = MidiFileTools.new()
		if legato_midi_cb.pressed :
			# Legato
			bytes = MTF.same_pitch_legato(bytes,1)
	

			#humanize
		bytes = MTF.humanize_chords(bytes,1,0.01,0.03,.3)
		
		
		
		midi_player.load_from_bytes(bytes)
		if marker_starting_pos_in_ticks > -1 :
			posInTicks = marker_starting_pos_in_ticks
		else:
			posInTicks = int(480 * (songTrackView.get_scroll_beats()))

		anim_songTrack_view = true
		playStopBtn.text = "Stop"
		midi_player.play(posInTicks)	
		


func _on_rewind_btn_pressed():
	rewind()

func rewind() :
	marker_starting_pos_in_ticks = -1
	midi_player.stop()
	playStopBtn.text = "Play"
	songTrackView.scroll_to_pos(0,.3)
	
#	songTrackView.update_ui()
	rewindBtn.hide()


func get_params_from_dashboard(_seed:int = 1) -> Dictionary:
	var params:Dictionary = {}
	
	return params

#
#func set_Edit_Button():
#	compute_satb_btn.text = "Edit Progression"
#	
#	compute_satb_btn.show()
#	songTrackView_view_display_mode_option.hide()
#
#func set_SATB_button():
#	compute_satb_btn.text = "Compute SATB"
#	is_displaying_SATB = false
#	compute_satb_btn.show()
#	songTrackView_view_display_mode_option.show()

func _on_Generate_btn_pressed():
	add_current_progression_track_to_undo()
	clear_console()
	midi_player.stop()
	playStopBtn.text = "Play"
	
	var _nb_chords_per_bar = 1
	if two_chords_per_bar_sb.pressed:
		_nb_chords_per_bar = 2
	var time_num_value = 4
	var time_num_selected = time_signature_ob.selected
	match time_num_selected:
		0: time_num_value = 3
		1: time_num_value = 4
		2: time_num_value = 5
		3: time_num_value = 7
		

	if $Song_panel/auto_seed_cb.pressed :
		_randomize_seed()
	var mySeed = int($Song_panel/seed_sb.get_line_edit().text)
	rng.seed = mySeed


	
	
	var tr = Track.new()
	tr.name = Song.PROGRESSION_TRACK_NAME
	

#
#
	
	
	#var rng = RandomNumberGenerator.new()
	rng.seed = mySeed
	

	tr = Track.new()
	tr.name = Song.PROGRESSION_TRACK_NAME
	

	
	var myPreviousTrack = myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME)
	if myPreviousTrack == null:
		myPreviousTrack = Track.new()
	
	var last_degree = null
	var previous_length = myPreviousTrack.length_beats 
	if previous_length > 0:
		last_degree = myPreviousTrack.get_degrees_array()[-1]
	else:
		myMasterSong.title = $titleGenerator.generate_title(mySeed)
		LogBus.info(TAG,"random seed: " + str(mySeed))
		LogBus.info(TAG,"Song generated: " + myMasterSong.title)

	var gene_key = -1
	if key_root_select_ob.selected < 12:
		gene_key = key_root_select_ob.selected 
	
	var gene_scale = ""
	match scale_select_ob.selected:
		0: gene_scale = "major"
		1: gene_scale = "minor"
		2: gene_scale = "harmonic_minor"
		3: gene_scale = "melodic_minor"	
	# ????	
	var key = HarmonicKey.new()
	key.scale_name = "major"

	



	#func generate( key_root:int = -1,scale:String = "",_seed:int = -1, lastDegree = null) -> Array:
	var degrees = RP.generate(gene_key,gene_scale, mySeed, last_degree)
	
	var duration1 = time_num_value
	var duration2 = time_num_value
	
	if two_chords_per_bar_sb.pressed:
		match time_num_value:
			3:
				duration1 = 2
				duration2 = 1
			4:
				duration1 = 2
				duration2 = 2
			5:
				duration1 = 2
				duration2 = 3
			7:
				duration1 = 3
				duration2 = 4
	
	var pos = 0
	
	for i in range(0,degrees.size()):
		var d:Degree = degrees[i]
		if i%2 == 0 :
			d.length_beats = duration1
			tr.add_degree(pos,d)
			pos += duration1
		else:
			d.length_beats = duration2
			tr.add_degree(pos,d)
			pos += duration2


	
	myPreviousTrack.merge_track(tr,previous_length)
	myMasterSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
	myMasterSong.add_track(myPreviousTrack)
	  
	myPlayingSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
	myPlayingSong.add_track(myPreviousTrack)
	myPlayingSong.title = myMasterSong.title
	song_title_lbl.text = myPlayingSong.title
	songTrackView.set_song(myPlayingSong)
	songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
	
	#	myMasterSong = Song.new()
	myMasterSong.time_den = 4
	myMasterSong.time_num = time_num_value
	myMasterSong.tempo_bpm = $Song_panel/tempo_sb.value	

#	myPlayingSong = Song.new()
	myPlayingSong.time_den = myMasterSong.time_den 
	myPlayingSong.time_num = myMasterSong.time_num 
	myPlayingSong.tempo_bpm = myMasterSong.tempo_bpm 
	
	
	songTrackView.set_degree_display("roman")
	songTrackView_view_display_mode_option.select(2)
	songTrackView.update()
	playStopBtn.show()
	export_midi_btn.show()
	compute_satb_btn.show()
	#_compute_progression_satbs()
	set_song_display()
	rewind()
	

	
func _on_clear_console_btn_pressed():
	clear_console()
	
func clear_console():
	console.text = ""

func _save_text_to_disk(content: String, filename: String) -> void:
	# Écrit dans le dossier utilisateur (persistance locale)
	var path = MusicLabGlobals.get_text_export_path(filename)
	var ok = MusicLabGlobals.save_text_to_file(path, content)
	if ok:
		MusicLabGlobals.set_user_setting(MusicLabGlobals.LAST_TEXT_DIR_KEY, path.get_base_dir())
		LogBus.info(TAG,"console.txt saved to "+ path)
		
func _on_export_console_btn_pressed():
	_save_text_to_disk(console.text, "console.txt")
	LogBus.info(TAG, 'Console.txt exported')

func _randomize_seed():
	rng.randomize()
	var random_number = rng.randi()
	var lineEdit = $Song_panel/seed_sb.get_line_edit()
	lineEdit.text = str(random_number)
	$Song_panel/seed_sb.apply()





func _on_tempo_sb_value_changed(value):
	MusicLabGlobals.yield(self)
	myPlayingSong.tempo_bpm = value
	myMasterSong.tempo_bpm = value
	if midi_player :
		midi_player.stop()
		rewind()
		playStopBtn.text = "Play"
	
	
	
	
func _on_Export_midi_btn_pressed():

	var filename = myMasterSong.title
	var bytes: PoolByteArray
	# construction de la song SATB
	if is_displaying_SATB and separate_satb_cb.pressed:
		bytes =  myMasterSong.get_midi_bytes_type1()
		filename += " [SATB]"
	else:	
		bytes = myPlayingSong.get_midi_bytes_type1()
		#filename += " "
		
	if bytes.size() <= 0:
		LogBus.error("[MidiExport]","No Midi Bytes to export (bytes.size == 0).")
		return
	
	if legato_midi_cb.pressed :
		var MFT:MidiFileTools = MidiFileTools.new()
		bytes = MFT.same_pitch_legato(bytes,1)
		filename += "[Legato]"
	_pending_midi_bytes = bytes
	var export_path = MusicLabGlobals.get_midi_export_path(filename)
	midi_export_dialog.current_dir = export_path.get_base_dir()
	midi_export_dialog.current_file = export_path.get_file()
	midi_export_dialog.popup_centered_ratio(0.8)

func _on_ExportMidiDialog_file_selected(path: String) -> void:
	clear_console()
	if _pending_midi_bytes.size() <= 0:
		LogBus.error(TAG, "[MidiExport] No Midi Bytes to export (bytes.size == 0).")
		return

	if not path.ends_with(MusicLabGlobals.MIDI_EXTENSION):
		path += MusicLabGlobals.MIDI_EXTENSION

	var base_dir = path.get_base_dir()
	if base_dir != "":
		MusicLabGlobals._ensure_directory(base_dir)

	var result = MusicLabGlobals._save_locally(_pending_midi_bytes, path)
	LogBus.info(TAG, result)
	if base_dir != "":
		MusicLabGlobals.set_user_setting(MusicLabGlobals.LAST_MIDI_DIR_KEY, base_dir)
	_pending_midi_bytes = PoolByteArray()
	


func _input(event):
	if event is InputEventKey:
		if song_title_lbl.has_focus() or $Song_panel/tempo_sb.get_line_edit().has_focus():
			return
		
		
		
		accept_event()
		#accept_event()
		if  event.is_released():
			return
		if event.shift == false and (event.scancode != key_command and  event.scancode != KEY_ALT and event.scancode != KEY_META and event.scancode != KEY_SPACE and event.scancode != KEY_0 ):
			clear_console()
		
		var wrappers = songTrackView.get_wrappers()
		var selected_wrappers = songTrackView.get_selected_wrappers()	
		# PRINT event.scancode
		#LogBus.debug(TAG,"event.scancode: "+ str(event.scancode))
		
		#ALT FLECHE DROITE -> décale end/start de 2 accords vers la droite
		if event.scancode == KEY_RIGHT and Input.is_key_pressed(KEY_ALT) :
			if selected_wrappers.size() != 2:
				LogBus.info(TAG,"You must select 2 chords to shift length")
				return
			var w1 = selected_wrappers[0]
			var w2 = selected_wrappers[1]
			var d1:Degree = w1.get_meta("degree")
			var d2:Degree = w2.get_meta("degree")
			if d2.length_beats < 1.0 :
				LogBus.info(TAG,"Unable to expand the first, chord the second chord is too short")
				return
			
			add_current_progression_track_to_undo()	
			# on allonge d1 d'une croche, on raccourcit d2 d'une croche, on décale d2 d'une croche
			var new_prog_track = myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME).clone()
			var two_degree_track = new_prog_track.extract(w1.get_meta("start"), w1.get_meta("start") + d1.length_beats+d2.length_beats,true)
			
			var degree_events = []
			for ev in two_degree_track.events:
				if ev["degree"] != null :
					degree_events.append(ev)
			
			
			if degree_events.size() != 2:
				LogBus.error(TAG,'Oups, two_degree_track has not 2 degrees !')
				LogBus.error(TAG,two_degree_track.to_string())
				LogBus.error(TAG,"Please Save your song and send an email to laurent.veliscek@gmail.com with the saved song" )
				return
			
			var ev1 = degree_events[0]
			var ev2= degree_events[-1]
			
			var deg1:Degree = ev1["degree"]
			var deg2:Degree = ev2["degree"]
			deg1.length_beats += .5
			deg2.length_beats += - .5
			ev2["start"] +=  .5
			
			var out_track = new_prog_track.extract(0,w1.get_meta("start"))
			two_degree_track.shift_time(out_track.length_beats)
			out_track.merge_track(two_degree_track)
			var end_track = new_prog_track.extract(out_track.length_beats,new_prog_track.length_beats)
			out_track.merge_track(end_track)
			replace_progression_track_with_track(out_track)

			return

		#ALT FLECHE GAUCHE -> décale end/start de 2 accords vers la gauche
		if event.scancode == KEY_LEFT and Input.is_key_pressed(KEY_ALT) :
			if selected_wrappers.size() != 2:
				LogBus.info(TAG,"You must select 2 chords to shift length")
				return
			var w1 = selected_wrappers[0]
			var w2 = selected_wrappers[1]
			var d1:Degree = w1.get_meta("degree")
			var d2:Degree = w2.get_meta("degree")
			if d1.length_beats < 1.0 :
				LogBus.info(TAG,"Unable to contract the first chord, it is too short")
				return
			
			add_current_progression_track_to_undo()	
			# on allonge d1 d'une croche, on raccourcit d2 d'une croche, on décale d2 d'une croche
			var new_prog_track = myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME).clone()
			var two_degree_track = new_prog_track.extract(w1.get_meta("start"), w1.get_meta("start") + d1.length_beats+d2.length_beats,true)
			
			var degree_events = []
			for ev in two_degree_track.events:
				if ev["degree"] != null :
					degree_events.append(ev)
			
			
			if degree_events.size() != 2:
				LogBus.error(TAG,'Oups, two_degree_track has not 2 degrees !')
				LogBus.error(TAG,two_degree_track.to_string())
				LogBus.error(TAG,"Please Save your song and send an email to laurent.veliscek@gmail.com with the saved song" )
				return
			
			var ev1 = degree_events[0]
			var ev2= degree_events[-1]
			
			var deg1:Degree = ev1["degree"]
			var deg2:Degree = ev2["degree"]
			deg1.length_beats += - .5
			deg2.length_beats += + .5
			ev2["start"] +=  - .5
			
			var out_track = new_prog_track.extract(0,w1.get_meta("start"))
			two_degree_track.shift_time(out_track.length_beats)
			out_track.merge_track(two_degree_track)
			var end_track = new_prog_track.extract(out_track.length_beats,new_prog_track.length_beats)
			out_track.merge_track(end_track)
			replace_progression_track_with_track(out_track)

			return


		
			
		# 61 -> =  egalize octaves
		elif event.scancode == 61 or event.scancode == KEY_EQUAL :
			var track:Track= songTrackView.get_track()
			if track == null or track.get_degrees_array().size() < 2 :
				return
			clear_console()
			LogBus.info(TAG,"Chords octave adjusted")
			track.adjust_track_degree_octaves()
			update_songTrackView_withSelection()
			return
		# KEY_SPACE -> PLAY/STOP
		elif event.pressed and event.scancode == KEY_SPACE and is_computing_satb == false:
			accept_event()  # Empêche l'événement de se propager à d'autres nœuds
			# alias pour gérer le bouton play avec la barre espcae
			_on_playStop_btn_pressed()
			
		#0 -> return to ZERO
		elif event.pressed and (event.scancode == 16777350 or event.scancode == 48 or event.scancode == KEY_0):
			#accept_event()  # Empêche l'événement de se propager à d'autres nœuds
			marker_starting_pos_in_ticks = -1
			rewind()


		
		# Touches de fonction -> Display
		elif event.pressed and (event.scancode == 16777244 or event.scancode == KEY_F1):
			_on_trackDisplayMode_item_selected(0)
#
#			var selected_indexes= []
#			for w in songTrackView._wrappers:
#				if w.get_meta("selected") == true:
#					selected_indexes.append(w.get_meta("index"))
#
#			#songTrackView.set_degree_display("midi")
#			songTrackView_view_display_mode_option.select(0)
#			wrappers = songTrackView._wrappers
#			for idx in selected_indexes:
#				songTrackView.select_wrapper(wrappers[idx])
				
		elif event.pressed and (event.scancode == 16777245 or event.scancode == KEY_F2):
			_on_trackDisplayMode_item_selected(1)
		elif event.pressed and (event.scancode == 16777246 or event.scancode == KEY_F3):
			_on_trackDisplayMode_item_selected(2)
		elif event.pressed and (event.scancode == 16777247 or event.scancode == KEY_F4):
			_on_trackDisplayMode_item_selected(3)
		
		# Touches de fonction -> ZOOM
		elif event.pressed and (event.scancode == 16777248 or event.scancode == KEY_F5 ):
			var v = songTrackView_scale_option.value
			var vmin = songTrackView_scale_option.min_value
			v = max(vmin, v - 1)
			songTrackView_scale_option.value = v
			songTrackView.update()
		elif event.pressed and (event.scancode == 16777249 or event.scancode == KEY_F6) :
			accept_event()
			var v = songTrackView_scale_option.value
			var vmax = songTrackView_scale_option.max_value
			v = min(vmax, v + 1)
			songTrackView_scale_option.value = v
			

		# shift "." -> set marker
		elif (event.scancode == 16777348 or event.scancode == KEY_COMMA) and event.shift :
			marker_starting_pos_in_ticks = songTrackView._playing_pos_ticks
			LogBus.info(TAG,"Marker set !")
			
		
		#elif event.pressed and Input.is_key_pressed(KEY_SHIFT) and is_displaying_SATB == false :
		elif is_displaying_SATB == false :	
			compute_satb_btn.visible = true
			# on sort de la lecture satb
			var prog_track = myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME)
			for w in wrappers :
				var d:Degree = w.get_meta("degree")
				d.satb_dictionary = {}
				d.satb_objects = []
				
				
				
				
			# POMME-P = PULSE				# 
			
			##########################################################
			# COMMAND
			##########################################################
			# Fonctions avec "Command"
			if Input.is_key_pressed(key_command):

				#POMME R Rythme
				if event.scancode == KEY_R :	
					if selected_wrappers.size() != 4 :
						LogBus.info(TAG,"you must select 4 chords to apply chord groove")
						return
					rewind()
					add_current_progression_track_to_undo()
					var before_track:Track = myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME).clone()
					
					var pos_in = selected_wrappers[0].get_meta("start")
					var last_degree:Degree = selected_wrappers[-1].get_meta("degree") 
					var pos_out = selected_wrappers[-1].get_meta("start") + last_degree.length_beats
					
					
					LogBus.debug(TAG,"pos_in: "+str(pos_in))
					LogBus.debug(TAG,"pos_out: "+str(pos_out))
					var four_chords_track:Track = before_track.extract(pos_in,pos_out,true)
					var gen = ChordDurationPatternGenerator.new()
					#var pattern_length = 2 + (2 *(rng.randi() % 2))
					var pattern_length = 2 
					var complexity = rng.randi() % 3
					var pattern = gen.get_pattern(pattern_length, complexity)
					
					var new_track:Track = Track.new()
					var degrees = four_chords_track.get_degrees_array()
					for idx in range(0,4):
						var d:Degree = degrees[idx].clone()
						d.length_beats = pattern[idx]
						new_track.add_degree(new_track.length_beats,d)
					LogBus.debug(TAG,"new_track: ")
					LogBus.debug(TAG,new_track.to_string())
					
					var out_track:Track = before_track.track_with_cut(pos_in,pos_out)
					LogBus.debug(TAG,"track with cut: ")
					LogBus.debug(TAG,out_track.to_string())
					
					var final_track = out_track.track_with_insert(pos_in,new_track)
					
					LogBus.debug(TAG,"final_track: ")
					LogBus.debug(TAG,final_track.to_string())
					
					replace_progression_track_with_track(final_track)
					return
					
				
				#  POMME FLECHE GAUCHE: delete current chord and select previous
				elif event.scancode == 16777231 or event.scancode == KEY_LEFT:
					clear_console()
					var myProgressionTrack:Track = myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME)
					var degrees_array = myProgressionTrack.get_degrees_array()
					if degrees_array.size() < 2 :
						LogBus.info(TAG,"Cannot delete the selected chord")
						LogBus.info(TAG,"Progression must have at least one chord")
						return
					
					# selectionner le degree de depart
					var selected_wrapper
					if selected_wrappers.size() == 0:
						selected_wrapper = wrappers[-1]
					else :
						selected_wrapper = selected_wrappers[-1]
					
					
					add_current_progression_track_to_undo()	
					
					var index_selected = selected_wrapper.get_meta("index")
					var degree_from:Degree = selected_wrapper.get_meta("degree")
					var degree_from_start = selected_wrapper.get_meta("start")
					var degree_from_length = degree_from.length_beats

					var new_track:Track = prog_track.extract(0,degree_from_start)
					var end_track = prog_track.extract(degree_from_start+degree_from_length, prog_track.length_beats)
					
					

					end_track.shift_time(-1.0 * degree_from_length)
					new_track.merge_track(end_track)

					new_track.name = Song.PROGRESSION_TRACK_NAME
					
					update_songTrackView_withSelection()
					myMasterSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myMasterSong.add_track(new_track)
					myPlayingSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myPlayingSong.add_track(new_track)
					songTrackView.song = myPlayingSong
					songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
					
					var new_selected_wrapper = songTrackView._wrappers[index_selected - 1]
					songTrackView.select_only_wrapper(new_selected_wrapper)
					
					update_songTrackView_withSelection()
					play_wrapper(new_selected_wrapper)
					display_harmonic_function(new_selected_wrapper.get_meta("degree"))
					#songTrackView.update_ui()
					
					LogBus.info(TAG,"Selected chord has been deleted")
					
					
					return
				
				
				# NEXT CHORD TonalProgressionHelper POMME FLECHE DROITE
				elif event.scancode == 16777233 or event.scancode == KEY_RIGHT:
					clear_console()
					var myProgressionTrack:Track = myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME)
					var degrees_array = myProgressionTrack.get_degrees_array()
					
					if degrees_array.size() == 0:
						if $Song_panel/auto_seed_cb.pressed :
							_randomize_seed()
						var mySeed = int($Song_panel/seed_sb.get_line_edit().text)
						rng.seed = mySeed
						myMasterSong.title = $titleGenerator.generate_title(mySeed)
						myPlayingSong.title = myMasterSong.title
						song_title_lbl.text = myMasterSong.title
						
						var new_track:Track = Track.new()
						var new_degree:Degree = Degree.new()
						
						var time_num_value = 4
						var time_num_selected = time_signature_ob.selected
						match time_num_selected:
							0: time_num_value = 3
							1: time_num_value = 4
							2: time_num_value = 5
							3: time_num_value = 7						
						var duration1
						if two_chords_per_bar_sb.pressed:
							match time_num_value:
								3:
									duration1 = 2
								4:
									duration1 = 2
								5:
									duration1 = 2
								7:
									duration1 = 3
						new_degree.length_beats = duration1
						new_track.add_degree(0,new_degree)
							
						new_track.name = Song.PROGRESSION_TRACK_NAME
						
						update_songTrackView_withSelection()
						myMasterSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
						myMasterSong.add_track(new_track)
						myPlayingSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
						myPlayingSong.add_track(new_track)
						songTrackView.song = myPlayingSong
						songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
						
						var new_selected_wrapper = songTrackView._wrappers[0]
						songTrackView.select_only_wrapper(new_selected_wrapper)
						
						update_songTrackView_withSelection()
						play_wrapper(new_selected_wrapper)
						#songTrackView.update_ui()
						LogBus.info(TAG,"New song created.\n")
						LogBus.info(TAG,"Title: " + myMasterSong.title)	
						display_harmonic_function(new_degree)					
						return							
										
					

					# selectionner le degree de depart
					var selected_wrapper
					if selected_wrappers.size() == 0:
						selected_wrapper = wrappers[-1]
					else :
						selected_wrapper = selected_wrappers[-1]
					
					
					
					add_current_progression_track_to_undo()	
					
					var index_selected = selected_wrapper.get_meta("index")
					var degree_from:Degree = selected_wrapper.get_meta("degree")
					var degree_from_start = selected_wrapper.get_meta("start")
					var degree_from_length = degree_from.length_beats
					
					var not_tonal_scale_name = ""
					var not_tonal_degree = null
					add_current_progression_track_to_undo()	
					
					###
					var deceptive:bool = event.shift
					var next_degree
					if ["major","minor","harmonic_minor","melodic_minor"].has(degree_from.key.scale_name) == false:
						LogBus.info(TAG,">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
						LogBus.info(TAG,"WARNING ! " + degree_from.key.scale_name + " is not a tonal mode !\n")
						LogBus.info(TAG,"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
						not_tonal_scale_name = degree_from.key.scale_name
						not_tonal_degree = degree_from.clone()
						
						# on substitue un degre_from majeur ou mineur
						# pour cela, on regarde si la tonalité est plutot majeur
						var degree_test:Degree = Degree.new()
						
						degree_test.key = not_tonal_degree.key
						degree_test.degree_number = 1
						if degree_test.quality_with_alter() == "maj" or degree_test.quality_with_alter() == "aug":
							not_tonal_degree.key.scale_name = "major"
						else :
							degree_test.degree_number = 5
							if degree_test.quality_with_alter() == "maj":
								not_tonal_degree.key.scale_name = "harmonic_minor"
							else :
								not_tonal_degree.key.scale_name = "minor"
						
						next_degree = tonalProgressionHelper.get_next_degree(not_tonal_degree,deceptive)
						
						# On rend à next_degree son mode d'origine
						next_degree.key.scale_name = not_tonal_scale_name
					else :
						next_degree = tonalProgressionHelper.get_next_degree(degree_from,deceptive)
					
					match next_degree.kind:
						"N6":next_degree.set_N6()
						"It+6": next_degree.set_aug6_It()
						"Fr+6": next_degree.set_aug6_Fr()
						"Ger+6": next_degree.set_aug6_Ger()
						"It+6inv": next_degree.set_aug6_It_inv()
						"Fr+6inv": next_degree.set_aug6_Fr_inv()
						"Ger+6inv": next_degree.set_aug6_Ger_inv()
					
					
					next_degree.length_beats = degree_from.length_beats
					var new_track:Track = prog_track.extract(0,degree_from_start + degree_from_length)
					var end_track = prog_track.extract(degree_from_start+degree_from_length, prog_track.length_beats)
					
					
					new_track.add_degree(degree_from_start+degree_from_length,next_degree)
					#var new_length = new_track.length_beats
					end_track.shift_time(degree_from_length)
					new_track.merge_track(end_track)
					#new_track.merge_track(pasted_track,insert_pos,true)

					new_track.name = Song.PROGRESSION_TRACK_NAME
					
					update_songTrackView_withSelection()
					myMasterSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myMasterSong.add_track(new_track)
					myPlayingSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myPlayingSong.add_track(new_track)
					songTrackView.song = myPlayingSong
					songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
					
					var new_selected_wrapper = songTrackView._wrappers[index_selected + 1]
					songTrackView.select_only_wrapper(new_selected_wrapper)
					
					update_songTrackView_withSelection()
					play_wrapper(new_selected_wrapper)
					#songTrackView.update_ui()
					
					var fonction = ""
					match next_degree.harmonic_function:
						"T": fonction = "Tonic"
						"PD": fonction = "Pre-dominant"
						"D": fonction = "Dominant"
						
					if deceptive:
						LogBus.info(TAG,">>> Next chord Mode: Deceptive\n")
					else:
						LogBus.info(TAG,">>> Next chord Mode: Conclusive\n")
						
					LogBus.info(TAG,"New "+fonction+" chord added :\n")
					LogBus.info(TAG,next_degree.to_string())
					display_harmonic_function(next_degree)
					
					
					return
								


				
				# COMMAND + -> Tonalite +1
				elif event.scancode == 16777349 :
					if selected_wrappers.size() > 0:
						midi_player.stop()
						var last_wrapper = selected_wrappers[-1]
						add_current_progression_track_to_undo()	
						for w in selected_wrappers:
							var d:Degree = w.get_meta("degree")
							d.key.root_midi = (d.key.root_midi +1) % 12
						LogBus.info(TAG,"Selected chords key upped by 1 semi-tone")
						update_songTrackView_withSelection()	
						play_wrapper(last_wrapper)
						return
						

				# COMMAND - -> Tonalite -1
				if event.scancode == 16777347 :
					if selected_wrappers.size() > 0:
						midi_player.stop()
						var last_wrapper = selected_wrappers[-1]
						add_current_progression_track_to_undo()	
						for w in selected_wrappers:
							var d:Degree = w.get_meta("degree")
							d.key.root_midi = (d.key.root_midi + 11) % 12
						LogBus.info(TAG,"Selected chords key lowered by 1 semi-tone")
						update_songTrackView_withSelection()	
						play_wrapper(last_wrapper)
						return
						

				# Shift POMME Z -> REDO	
				elif event.scancode == 90 and is_displaying_SATB == false  and is_computing_satb == false and event.shift :
					restore_redo_track()
					return
					
				#  POMME Z -> UNDO	
				elif event.scancode == 90 and is_displaying_SATB == false  and is_computing_satb == false  :
					restore_undo_track()
					return
				
		

				#Shift G -> GENERATE	
				elif event.scancode == 71 and is_displaying_SATB == false  and is_computing_satb == false :
					_on_Generate_btn_pressed()

	
	
				# A -> Select All
				elif event.scancode == 65:
					#accept_event()
					if wrappers.size() == 0:
						LogBus.info(TAG,"No chords to select")
						return
					for w in wrappers:
						songTrackView.select_wrapper(w)
						
					update_songTrackView_withSelection()
					display_harmonic_function(null)	
					LogBus.info(TAG,"All chords Selected !")
					return
				# COPY !		
				elif event.scancode == 67:
					#accept_event()
					if wrappers.size() == 0 or selected_wrappers.size() == 0:
						LogBus.info(TAG,"You must select at least one chord to copy in the clipboard")
						return
						
					var last_selected_degree:Degree = selected_wrappers[-1].get_meta("degree")
					var from:float = selected_wrappers[0].get_meta("start")
					var to:float = selected_wrappers[-1].get_meta("start")  + last_selected_degree.length_beats
					track_clip_board = prog_track.extract(from,to,true)
					var nb_chords = selected_wrappers.size()
					if nb_chords == 1:
						LogBus.info(TAG,"One chord pasted to the clipboard")
					else :
						LogBus.info(TAG,str(nb_chords) + " chords pasted to the clipboard")
					return
														
				# CUT
				elif event.scancode == 88:
					#accept_event()
					if selected_wrappers.size() == 0:
						LogBus.info(TAG,"You must select at least one chord to cut")
						return
					add_current_progression_track_to_undo()	
					var last_selected_degree:Degree = selected_wrappers[-1].get_meta("degree")
					var from:float = selected_wrappers[0].get_meta("start")
					var to:float = selected_wrappers[-1].get_meta("start")  + last_selected_degree.length_beats
					track_clip_board = prog_track.extract(from,to,true)
					# On copie le début de la track
					var new_track:Track = prog_track.extract(0,from)
					var end_pos:float = prog_track.length_beats
					var track_after:Track = prog_track.extract(to,end_pos)
					track_after.shift_time(-1 * track_clip_board.length_beats)
					new_track.merge_track(track_after,0,true)
					new_track.name = Song.PROGRESSION_TRACK_NAME
					update_songTrackView_withSelection()
					myMasterSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myMasterSong.add_track(new_track)
					myPlayingSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myPlayingSong.add_track(new_track)
					songTrackView.song = myPlayingSong
					songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
					songTrackView.update_ui()

					var nb_chords = selected_wrappers.size()
					if nb_chords == 1:
						LogBus.info(TAG,"One chord cut and pasted to the clipboard")
					else :
						LogBus.info(TAG,str(nb_chords) + " chords cut and pasted to the clipboard")
					wrappers = songTrackView.get_wrappers()
					
					if wrappers.size() == 0:
						LogBus.info(TAG,"")
						no_chords()
						generate_btn.show()
					return
					
				# PASTE
				elif event.scancode == 86:						
					var insert_pos = 0
					add_current_progression_track_to_undo()	
					# si il y a une selection
					if selected_wrappers.size() > 0:
						var last_wrapper = selected_wrappers[-1]
						insert_pos = last_wrapper.get_meta("start") + last_wrapper.get_meta("degree").length_beats
					elif wrappers.size() > 0 :
						insert_pos = myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME).length_beats
					
					var new_track:Track = Track.new()
					if insert_pos > 0 :
						new_track = prog_track.extract(0,insert_pos)
					var pasted_track = track_clip_board.clone()
					
					new_track.merge_track(pasted_track,insert_pos,true)
					
					
					if insert_pos < myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME).length_beats:
						var end_track = myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME).extract(insert_pos,myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME).length_beats)	
						new_track.merge_track(end_track,track_clip_board.length_beats,true)
					
					new_track.name = Song.PROGRESSION_TRACK_NAME
					
					update_songTrackView_withSelection()
					myMasterSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myMasterSong.add_track(new_track)
					myPlayingSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myPlayingSong.add_track(new_track)
					songTrackView.song = myPlayingSong
					songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
					songTrackView.update_ui()
					var nb_chords = track_clip_board.get_degrees_array().size()
					if nb_chords == 1:
						LogBus.info(TAG,"One chord pasted to the progression")
					else :
						LogBus.info(TAG,str(nb_chords) + " chords pasted to the progression")
					return
				
				# COMMAND- M - MODULATION
				elif event.scancode == 77:						
					
					# on affiche le tab modulation
					center_tab_container.set_current_tab(1)
					
					#on filtre
					if selected_wrappers.size() != 2:
						LogBus.info(TAG,"You must select 2 adjacent chords to compute a modulation")
						return
						
					var d1:Degree = selected_wrappers[0].get_meta("degree")
					var d2:Degree = selected_wrappers[1].get_meta("degree")


					clear_console()
					
					var degrees = get_modulation_degrees(d1,d2)
					
					if degrees.size() == 0:
						LogBus.info(TAG, "No modulation path found")
						LogBus.info(TAG, "\nCheck the filters settings on the Modulation panel")
						return
					
					############ !!!!!!!!!!!!!!!!!!! ##############
					 
					
					
					midi_player.stop()
					playStopBtn.text = "Play"


					add_current_progression_track_to_undo()	


				
					var durations = [d1.length_beats,d2.length_beats]
					
					var modulation_track = Track.new()
					
					var pos = 0
					var chord_number = 0
					for d in degrees:
						
						d.length_beats  = durations[chord_number % 2]

						modulation_track.add_degree(pos,d)
						pos += d.length_beats
						chord_number += 1

					
					
					modulation_track.adjust_track_degree_octaves()
					
					#####
					var new_track:Track = Track.new()
					
										#insert_pos = 2eme accord start time
					var insert_pos = selected_wrappers[0].get_meta("start")

					
					if insert_pos > 0 :
						new_track = prog_track.extract(0,insert_pos)
					#var pasted_track = track_clip_board.clone()

					new_track.merge_track(modulation_track,insert_pos,true)

					insert_pos = selected_wrappers[1].get_meta("start") + d2.length_beats
					var end_track:Track = prog_track.extract(insert_pos,prog_track.length_beats)
					end_track.shift_time(-1 * insert_pos)
					new_track.merge_track(end_track,new_track.length_beats,true)

					new_track.name = Song.PROGRESSION_TRACK_NAME

					update_songTrackView_withSelection()
					myMasterSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myMasterSong.add_track(new_track)
					myPlayingSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myPlayingSong.add_track(new_track)
					songTrackView.song = myPlayingSong
					songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
					songTrackView.update_ui()
					var nb_chords = modulation_track.get_degrees_array().size()
					LogBus.info(TAG,"\n" +str(nb_chords - 2) + " modulation chords added to the progression\n")
					LogBus.info(TAG,"Click on the modulation chords to display modulation report.")
					return
			
			
			# SUPPRIME LES DEGRES SELECTIONNES
				elif event.scancode == KEY_BACKSPACE:
					#accept_event()
					if wrappers.size() == 0 or selected_wrappers.size() == 0 :
						return
						
					add_current_progression_track_to_undo()	
					var last_selected_degree:Degree = selected_wrappers[-1].get_meta("degree")
					var from:float = selected_wrappers[0].get_meta("start")
					var to:float = selected_wrappers[-1].get_meta("start")  + last_selected_degree.length_beats
					#track_clip_board = prog_track.extract(from,to,true)
					# On copie le début de la track
					var new_track:Track = prog_track.extract(0,from)
					var end_pos:float = prog_track.length_beats
					var track_after:Track = prog_track.extract(to,end_pos)
					track_after.shift_time(-1 * (to - from))
					new_track.merge_track(track_after,0,true)
					new_track.name = Song.PROGRESSION_TRACK_NAME
					update_songTrackView_withSelection()
					myMasterSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myMasterSong.add_track(new_track)
					myPlayingSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myPlayingSong.add_track(new_track)
					songTrackView.song = myPlayingSong
					songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
					songTrackView.update_ui()
					var nb_chords = selected_wrappers.size()
					if nb_chords == 1:
						LogBus.info(TAG,"One chord deleted")
					else :
						LogBus.info(TAG,str(nb_chords) + " chords deleted")
					wrappers = songTrackView.get_wrappers()
					if wrappers.size() == 0:
						LogBus.info(TAG,"")
						no_chords()
						generate_btn.show()
					return
					
				
					

				# COMMMAND R - D -> DUPLICATE
				elif event.scancode == KEY_D :	
										
					var selected_indexes = []
					
					if wrappers.size() == 0 :
						LogBus.info(TAG,"No chords to duplicate.")
						return
					
					if selected_wrappers.size() == 0:
						LogBus.info(TAG,"You must select at least one chord to duplicate")
						return
										
					add_current_progression_track_to_undo()	
					var insert_pos = 0
					
					# si il y a une selection
					if selected_wrappers.size() > 0:
						var last_wrapper = selected_wrappers[-1]
						insert_pos = last_wrapper.get_meta("start") + last_wrapper.get_meta("degree").length_beats
						
						for w in selected_wrappers:
							selected_indexes.append(w.get_meta("index"))
						
					# Sinon, on prend tout !
					elif wrappers.size() > 0 :
						for w in wrappers:
							selected_indexes.append(w.get_meta("index"))
						insert_pos = myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME).length_beats
					else :
						LogBus.info(TAG, "No chords to duplicate !")
						return
					
					
					
					
					
					var last_selected_degree:Degree = selected_wrappers[-1].get_meta("degree")
					var from:float = selected_wrappers[0].get_meta("start")
					var to:float = selected_wrappers[-1].get_meta("start")  + last_selected_degree.length_beats
					var track_to_duplicate = prog_track.extract(from,to,true)
					

					var new_track:Track = Track.new()
					new_track = prog_track.extract(0,to)
					var pasted_track = track_to_duplicate.clone()
					
					new_track.merge_track(pasted_track,insert_pos,true)
					
					var end_track = myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME).extract(insert_pos,myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME).length_beats)	
					#end_track.shift_time()
					new_track.merge_track(end_track,pasted_track.length_beats,true)

					
					new_track.name = Song.PROGRESSION_TRACK_NAME
					update_songTrackView_withSelection()
					myMasterSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myMasterSong.add_track(new_track)
					myPlayingSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myPlayingSong.add_track(new_track)
					songTrackView.song = myPlayingSong
					songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
					
					# select duplicated
					for i in selected_indexes:
						wrappers = songTrackView.get_wrappers()
						songTrackView.select_wrapper(wrappers[i + selected_indexes.size()])
					
					#songTrackView.update_ui()
					
					
					
					var nb_chords = pasted_track.get_degrees_array().size()
					if nb_chords == 1:
						LogBus.info(TAG,"One chord has been duplicated")
					else :
						LogBus.info(TAG,str(nb_chords) + " chords have been duplicated")
					return
			

######################################################################################################
######################################################################################################


#				# DOMINANTES SECONDAIRES

				elif [KEY_5,KEY_2,KEY_4,KEY_T,16777355,16777357,16777352,16777354,16777356].has(event.scancode) :
					var keyScan = event.scancode
					if selected_wrappers.size() != 1:
						LogBus.info(TAG,"Secondary Dominants can only be applied to ONE chord !...")
						return
					
					LogBus.info(TAG,"SECONDARY DOMINANT")
					
					var w = selected_wrappers[0]
					var index_selected_to_restore = w.get_meta("index")
					#var index_target_chord = w.get_meta("index")
					var target_degree:Degree = w.get_meta("degree")
					var target_chord_pos = w.get_meta("start")
					#var target_chord_length = target_degree.length_beats
					
					# target_degree must be a minor or major chord
					
					var target_quality
					if ["It+6","Fr+6","Ger+6", "It+6inv","Fr+6inv","Ger+6inv", "N6"].has(target_degree.kind):
						target_quality = "maj"
					elif ["sus2","sus4"].has(target_degree.kind):
						# on cherche la qualité de l'accord sur ce degré
						var degree_test:Degree = Degree.new()
						degree_test.key = target_degree.key
						degree_test._alterations = target_degree._alterations
						degree_test.degree_number  = target_degree.degree_number
						target_quality = degree_test.quality_with_alter()
					else :
						target_quality = target_degree.quality_with_alter()
				
					if target_quality != "min" and target_quality != "maj" :
						LogBus.info(TAG,"The target chord must be minor or major !...")
						return
					else :
						LogBus.info(TAG,"The target chord is okay !...")
						
						
					
					add_current_progression_track_to_undo()	
					var tonalized_target_degree = target_degree.clone()
					tonalized_target_degree.tonalize()
					
					#var borrowed_key = tonalized_target_degree.key
					
					var degre_5 = tonalized_target_degree.clone()
					degre_5.degree_number = 5
					degre_5.realization = [1,3,5,7]
					#degre_5.length_beats = target_chord_length
					var degre_2 = tonalized_target_degree.clone()
					degre_2.degree_number = 2
					#degre_2.length_beats = target_chord_length
					var degre_4 = tonalized_target_degree.clone()
					degre_4.degree_number = 4
					#degre_4.length_beats = target_chord_length
					var degre_6 = tonalized_target_degree.clone()
					degre_6.degree_number = 6
					#degre_6.length_beats = target_chord_length
					var degre_7 = tonalized_target_degree.clone()
					degre_7.degree_number = 7
					#degre_7.length_beats = target_chord_length
					degre_7.realization = [1,3,5,7]
					var degre_cad = tonalized_target_degree.clone()
					degre_cad.set_cad64()
					#degre_cad.length_beats = target_chord_length
					
					var track_dominante:Track = Track.new()
					
					match keyScan:
						# V/x
						KEY_5,16777355:
							LogBus.info(TAG,"V/x !...")
							if event.shift :
								degre_5.key.scale_name = "harmonic_minor"
							else :
								degre_5.key.scale_name = "major"
							track_dominante.add_degree(track_dominante.length_beats,degre_5)
						KEY_7,16777357:
							LogBus.info(TAG,"7/x !...")
							if event.shift :
								degre_7.key.scale_name = "major"
							else:
								degre_7.key.scale_name = "harmonic_minor"
							track_dominante.add_degree(track_dominante.length_beats,degre_7)
						KEY_2,16777352:
							LogBus.info(TAG,"2/x V/x !...")
							if event.shift :
								degre_2.key.scale_name = "harmonic_minor"
								degre_5.key.scale_name = "harmonic_minor"
							else:
								degre_2.key.scale_name = "major"
								degre_5.key.scale_name = "major"
							track_dominante.add_degree(track_dominante.length_beats,degre_2)
							track_dominante.add_degree(track_dominante.length_beats,degre_5)
						KEY_4,16777354:
							LogBus.info(TAG,"4/x V/x !...")
							if event.shift :
								degre_4.key.scale_name = "harmonic_minor"
								degre_5.key.scale_name = "harmonic_minor"
							else:
								degre_4.key.scale_name = "major"
								degre_5.key.scale_name = "major"
							track_dominante.add_degree(track_dominante.length_beats,degre_4)
							track_dominante.add_degree(track_dominante.length_beats,degre_5)
						KEY_6,16777356:
							LogBus.info(TAG,"6/x V/x !...")
							if event.shift :
								degre_6.key.scale_name = "harmonic_minor"
								degre_5.key.scale_name = "harmonic_minor"
							else:
								degre_6.key.scale_name = "major"
								degre_5.key.scale_name = "major"
							track_dominante.add_degree(track_dominante.length_beats,degre_6)
							track_dominante.add_degree(track_dominante.length_beats,degre_5)
						KEY_T:
							LogBus.info(TAG,"TONALIZE !...")
							var mode = "harmonic_minor"
							if tonalized_target_degree.key.scale_name == "major":
								mode = "major"
							degre_2.key.scale_name  = mode
							degre_5.key.scale_name  = mode
							degre_cad.key.scale_name  = mode
							track_dominante.add_degree(track_dominante.length_beats,tonalized_target_degree)
							track_dominante.add_degree(track_dominante.length_beats,degre_2)
							track_dominante.add_degree(track_dominante.length_beats,degre_cad)
							track_dominante.add_degree(track_dominante.length_beats,degre_5)
					

					
					#track progression debut SANS target
					var begin_track = prog_track.extract(0,target_chord_pos)
					#track progression fin AVEC target
					var end_track = prog_track.extract(target_chord_pos,prog_track.length_beats)
					
					end_track.shift_time(track_dominante.length_beats)
					track_dominante.shift_time(begin_track.length_beats)
					begin_track.merge_track(track_dominante)
					begin_track.merge_track(end_track)
					
					begin_track.name = Song.PROGRESSION_TRACK_NAME
					
					
					myMasterSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myMasterSong.add_track(begin_track)
					myPlayingSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myPlayingSong.add_track(begin_track)
					songTrackView.song = myPlayingSong
					songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
					#songTrackView.update_ui()
					songTrackView.select_only_wrapper(songTrackView._wrappers[index_selected_to_restore])
					update_songTrackView_withSelection()
			
				
	
			#############################################################

			
			elif songTrackView._selected.keys().size() > 0 :
				# Chromatize Down
				if event.scancode == 16777347 and event.shift:	
					#accept_event()
					if wrappers.size() == 0 or selected_wrappers.size() == 0 :
						LogBus.info(TAG,"No chord selected !")
						return
					if selected_wrappers.size() != 1 :
						LogBus.info(TAG,"Chromatization can only be applied to ONE chord")
						return
					var d = selected_wrappers[0].get_meta("degree")
					add_current_progression_track_to_undo()	
					d.chromatizeDown()

					if d.comment ==  "chromatized chord":
						update_songTrackView_withSelection()		
						play_wrapper(selected_wrappers[0])
					return
					
				# Chromatize UP
				if event.scancode == 16777349 and event.shift:	
					#accept_event()
					if wrappers.size() == 0 or selected_wrappers.size() == 0 :
						LogBus.info(TAG,"No chord selected !")
						return
					if selected_wrappers.size() != 1 :
						LogBus.info(TAG,"Chromatization can only be applied to ONE chord")
						return
					var d = selected_wrappers[0].get_meta("degree")
					add_current_progression_track_to_undo()	
					d.chromatizeUp()

					if d.comment ==  "chromatized chord":
						update_songTrackView_withSelection()		
						play_wrapper(selected_wrappers[0])
					return					
				
				
				
				
				# chromatize Shift C
				if event.scancode == 67 and event.shift:	
					#accept_event()
					if wrappers.size() == 0 or selected_wrappers.size() == 0 :
						LogBus.info(TAG,"No chord selected !")
						return
					if selected_wrappers.size() != 1 :
						LogBus.info(TAG,"Chromatization can only be applied to ONE chord")
						return
					var d = selected_wrappers[0].get_meta("degree")
					add_current_progression_track_to_undo()	
					d.chromatize()

					if d.comment ==  "chromatized chord":
						update_songTrackView_withSelection()		
						play_wrapper(selected_wrappers[0])
					return
					
				
				# H -> Half-time
				elif event.scancode == 72:	
					#accept_event()
					if wrappers.size() == 0 or selected_wrappers.size() == 0 :
						LogBus.info(TAG,"No chord selected !")
						return
					for w in selected_wrappers:
						if w.get_meta("degree").length_beats < 1:
							LogBus.info(TAG, "Cannot shorten, minimum chord duration is one half-beat")
							return
					
					add_current_progression_track_to_undo()	
					var last_selected_degree:Degree = selected_wrappers[-1].get_meta("degree")
					var from:float = selected_wrappers[0].get_meta("start")
					var to:float = selected_wrappers[-1].get_meta("start")  + last_selected_degree.length_beats
					#track_clip_board = prog_track.extract(from,to,true)
					# On copie le début de la track
					var new_track:Track = prog_track.extract(0,from)
					var mid_track:Track =  prog_track.extract(from,to)
					mid_track.shift_time(-1 * from)
					mid_track.half_time()
					new_track.merge_track(mid_track,from)
						
					var end_pos:float = prog_track.length_beats
					var track_after:Track = prog_track.extract(to,end_pos)
					track_after.shift_time(-1 * (.5 * (to - from)))
					new_track.merge_track(track_after,0,true)
					new_track.name = Song.PROGRESSION_TRACK_NAME
					update_songTrackView_withSelection()
					myMasterSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myMasterSong.add_track(new_track)
					myPlayingSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myPlayingSong.add_track(new_track)
					songTrackView.song = myPlayingSong
					songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
					songTrackView.update_ui()
					#var nb_chords = selected_wrappers.size()
					LogBus.info(TAG,"Selection duration divided by 2")
					wrappers = songTrackView.get_wrappers()
					update_songTrackView_withSelection()
					return

				# D -> Double-time
				elif event.scancode == 68:	
					#accept_event()
					if wrappers.size() == 0 or selected_wrappers.size() == 0 :
						LogBus.info(TAG,"No chord selected !")
						return
					
#					for d in prog_track.get_degrees_array():
#						if d.length_beats < 1:
#							LogBus.info(TAG,"Cannot divide durations: minimum length is half beat ! ")
#							return
						
					add_current_progression_track_to_undo()	
					var last_selected_degree:Degree = selected_wrappers[-1].get_meta("degree")
					var from:float = selected_wrappers[0].get_meta("start")
					var to:float = selected_wrappers[-1].get_meta("start")  + last_selected_degree.length_beats
					#track_clip_board = prog_track.extract(from,to,true)
					# On copie le début de la track
					var new_track:Track = prog_track.extract(0,from)
					var mid_track:Track =  prog_track.extract(from,to)
					mid_track.shift_time(-1 * from)
					mid_track.double_time()
					new_track.merge_track(mid_track,from)
						
					var end_pos:float = prog_track.length_beats
					var track_after:Track = prog_track.extract(to,end_pos)
					track_after.shift_time(to - from)
					new_track.merge_track(track_after,0,true)
					new_track.name = Song.PROGRESSION_TRACK_NAME
					update_songTrackView_withSelection()
					myMasterSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myMasterSong.add_track(new_track)
					myPlayingSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myPlayingSong.add_track(new_track)
					songTrackView.song = myPlayingSong
					songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
					songTrackView.update_ui()
					#var nb_chords = selected_wrappers.size()
					LogBus.info(TAG,"Selection duration multiplied by 2")
					wrappers = songTrackView.get_wrappers()



				
				# Quinte augmentée
				elif  event.shift and (event.scancode == 16777355 or event.scancode == 53):	
					clear_console()
					if selected_wrappers.size() != 1:
						LogBus.info(TAG,"Select ONE chord to apply altered Fifth")
						return
					var selected_wrapper = selected_wrappers[0]
					var d:Degree = selected_wrapper.get_meta("degree")
					
					if d.fifth_distance() == 7 and d.third_distance() == 4:
						# midi de la fondamentale du degré
						var m = d.key.degree_midi(d.degree_number) % 12
						var new_key_root = (m + 9) % 12
						d.key.scale_name = "harmonic_minor"
						d.degree_number = 3
						d.inversion = 1
						d.key.root_midi = new_key_root + 60
						LogBus.info(TAG,"Chord altered to augmented III of harmonic minor key "+ d.key.to_string())
						LogBus.info(TAG,"Magic door: You can [E]nharmonize this chord to a new key (or not)"+ d.key.to_string())
						LogBus.info(TAG,"and then resolve to i of this key..."+ d.key.to_string())
						LogBus.info(TAG,"\n" + d.to_string())
						
						update_songTrackView_withSelection()		
						play_wrapper(selected_wrapper)
						display_harmonic_function(selected_wrapper.get_meta("degree"))
						return
					else :
						LogBus.info(TAG,"You can only apply altered fifth to a major chord ")
						return
				
				if event.scancode == 69 :
					if selected_wrappers.size() != 1:
						LogBus.info(TAG,"Enharmony can only be set to ONE selected chord")
						return
					add_current_progression_track_to_undo()	
					var selected_wrapper = selected_wrappers[0]
					var selected_degree:Degree = selected_wrapper.get_meta("degree")
					# on gere enharmonize dans Degree !
					selected_degree.enharmonize()

					
					update_songTrackView_withSelection()		
					play_wrapper(selected_wrapper)
					LogBus.info(TAG,"Enharmonized: ")
					var deg = selected_wrapper.get_meta("degree")
					LogBus.info(TAG,deg.to_string())
					display_harmonic_function(deg)
					return
					
			
				# / -> SPLIT
				elif event.scancode == 58 or  event.scancode == 16777346 :	

					if wrappers.size() == 0 :
						LogBus.info(TAG,"The chord progression is empty !")
						return
					
					if selected_wrappers.size() == 0:
						LogBus.info(TAG,"You must select one chord to split")
						return
					
					if selected_wrappers.size() > 1:
						LogBus.info(TAG,"You must select only one chord to split")
						return

					
					var selected_degree:Degree = selected_wrappers[0].get_meta("degree")
					
					if selected_degree.length_beats <= 0.5:
						LogBus.info(TAG,"You cannot split a chord with a duration of 1 eighth-note: " + str(selected_degree.length_beats) )
						return 
						
					var first_selected_wrapper_index = selected_wrappers[0].get_meta("index")

					add_current_progression_track_to_undo()	
					var from:float = selected_wrappers[0].get_meta("start")
					var to:float = selected_wrappers[0].get_meta("start")  + selected_degree.length_beats
					
					var new_duration = 0
					
					if selected_degree.length_beats == 3: #si 3 temps -> 2 temps  + 1 temps (valse mood !)
						new_duration = 2
					elif selected_degree.length_beats == 1: #
						new_duration = .5
					else :
						new_duration = floor(selected_degree.length_beats / 2)
						if new_duration == 0:
							LogBus.info(TAG,"You cannot split a chord with a duration of 1 eighth-note")
							return 

					var degree1:Degree = selected_degree.clone()
					degree1.length_beats = new_duration
					var degree2:Degree = selected_degree.clone()
					degree2.length_beats = selected_degree.length_beats - new_duration 
					
					var split_track: Track = Track.new()
					split_track.add_degree(from,degree1 )
					split_track.add_degree(from + new_duration,degree2 )
					
					var new_track:Track = Track.new()
					new_track = prog_track.extract(0,from,true)					
					new_track.merge_track(split_track,0)
					new_track.merge_track(prog_track.extract(to,prog_track.length_beats),0,true)
					
					
					new_track.name = Song.PROGRESSION_TRACK_NAME
					update_songTrackView_withSelection()
					myMasterSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myMasterSong.add_track(new_track)
					myPlayingSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myPlayingSong.add_track(new_track)
					songTrackView.song = myPlayingSong
					songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
					songTrackView.update_ui()
					songTrackView.select_only_wrapper(songTrackView.get_wrappers()[first_selected_wrapper_index])
					var txt =  "Chord " + selected_degree.get_roman_numeral() + " (" + selected_degree.get_jazz_chord() + ") "
					txt += "has been splitted."
					LogBus.info(TAG,txt)
					display_harmonic_function(selected_degree)
					return
			

				# J -> JOIN
				elif event.scancode == 74 :	
					
					
					if wrappers.size() == 0 :
						LogBus.info(TAG,"The chord progression is empty !")
						return
					
					if selected_wrappers.size() < 2:
						LogBus.info(TAG,"You must select at least 2 chords to join")
						return
					add_current_progression_track_to_undo()	
					var first_selected_wrapper_index = selected_wrappers[0].get_meta("index")
					var first_selected_degree:Degree = selected_wrappers[0].get_meta("degree")
					var from:float = selected_wrappers[0].get_meta("start")
					var last_selected_degree:Degree = selected_wrappers[-1].get_meta("degree")
					var to:float = selected_wrappers[-1].get_meta("start")  + last_selected_degree.length_beats
					var new_duration = to - from
					var degree1:Degree = first_selected_degree.clone()
					degree1.length_beats = new_duration
					var joined_track: Track = Track.new()
					joined_track.add_degree(from,degree1 )
					
					var new_track:Track = Track.new()
					new_track = prog_track.extract(0,from,true)					
					new_track.merge_track(joined_track,0)
					new_track.merge_track(prog_track.extract(to,prog_track.length_beats),0,true)
					new_track.name = Song.PROGRESSION_TRACK_NAME
					update_songTrackView_withSelection()
					myMasterSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myMasterSong.add_track(new_track)
					myPlayingSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
					myPlayingSong.add_track(new_track)
					songTrackView.song = myPlayingSong
					songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
					songTrackView.update_ui()
					songTrackView.select_only_wrapper(songTrackView.get_wrappers()[first_selected_wrapper_index])
					var txt =  "Chord " + first_selected_degree.get_roman_numeral() + " (" + first_selected_degree.get_jazz_chord() + ") "
					txt += "has been joined."
					LogBus.info(TAG,txt)
					display_harmonic_function(first_selected_degree)
					return

					
				
				
				###################################################################################
				########### NEW SHORTCUT #############################################################
				###################################################################################
				
	
				# SHIFT SUPPRIME ou BACKSPACE
				elif event.scancode == KEY_BACKSPACE or event.scancode == KEY_DELETE :
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					if selected_wrappers.size() == 0 :
						LogBus.info(TAG,"No selected Degree to reset")
						return
					var last_wrapper
					#var last_idx = last_wrapper.get_meta("index")
					add_current_progression_track_to_undo()	
					for w in wrappers:
						var idx = w.get_meta("index")
						var d:Degree = w.get_meta("degree")

						if d is Degree and w.get_meta("selected"):
							last_wrapper = w
							d.reset()
							d.key = HarmonicKey.new()
							d.key.set_from_string("C major")
							LogBus.info(TAG,"Chord #"+str(idx + 1)+" has been reset")
							clean_secondaries(w)
					update_songTrackView_withSelection()		
					play_wrapper(last_wrapper)
					display_harmonic_function(last_wrapper.get_meta("degree"))
					return
					
				#SHIT T -> Tonalise
				elif event.scancode == 84:
					# si le degre n'est pas 1 et que l'accord et majeur ou mineur
					# il devient le degré 1 de la tonalité correspondante
					if selected_wrappers.size() == 1:
						var selected_wrapper = selected_wrappers[0]
						var selected_degree:Degree = selected_wrapper.get_meta("degree")
						if selected_degree.degree_number != 1:
							add_current_progression_track_to_undo()	
#							var k:HarmonicKey = HarmonicKey.new()
#							k.root_midi = (selected_degree.key.degree_midi(selected_degree.degree_number)) %12
#							if selected_degree.triad_quality() == "min":
#								selected_degree.degree_number = 1
#								k.set_scale_name("minor")
#								selected_degree.key = k
#							elif selected_degree.triad_quality() == "maj":
#								selected_degree.degree_number = 1
#								k.set_scale_name("major")
#								selected_degree.key = k
#							else :
#								LogBus.info(TAG,"You can only tonalize major or minor chords")
#								return
							selected_degree.tonalize()
							update_songTrackView_withSelection()		
							play_wrapper(selected_wrapper)
							var deg = selected_wrapper.get_meta("degree")
							display_harmonic_function(deg)
							LogBus.info(TAG,"Tonalized to: "+deg.to_string())
						else :
							LogBus.info(TAG,"This chord is already the tonic chord")
							return
					else:
						LogBus.info(TAG,"You must select ONE chord to apply Tonalization")
							
								

								
								
				# Shift ">" apply the 1st chord key to the selected chords
				elif event.scancode == 96 :
					if selected_wrappers.size() > 1:
						add_current_progression_track_to_undo()	
						var k = selected_wrappers[0].get_meta("degree").key
						for w in selected_wrappers:
							#var wrapper = w
							var d:Degree = w.get_meta("degree")
							d.key = k.clone()
							d._is_secondary = false
						update_songTrackView_withSelection()
						LogBus.info(TAG,str(selected_wrappers.size()) + " chords have been set to key: "+ k.to_string())		
						return
					else :
						LogBus.info(TAG,"You must select at least 2 chords to apply first chord key to selection")
						return
				
				
#

					
					
				#  1 2 3 4 5 6 7 -> change le numéro de degré du/des degrés selectionnés
				elif event.scancode == 16777351 or event.scancode == 49:

					if selected_wrappers.size() == 0 :
						LogBus.info(TAG,"No selected Degree !")
						return
					var last_wrapper
					#var last_idx = last_wrapper.get_meta("index")
					add_current_progression_track_to_undo()	
					for w in wrappers:
						var idx = w.get_meta("index")
						var d:Degree = w.get_meta("degree")

						if d is Degree and w.get_meta("selected"):
							last_wrapper = w
							var chosen_degree = 1
							if d.degree_number == chosen_degree:
								# on ajoute la septieme
								if d.realization == [1,3,5]:
									d.realization = [1,3,5,7]
								elif d.realization == [1,3,5,7]:
									d.set_add9()
								elif d.kind == "add9":
									d.set_add11()
								elif d.kind == "add11":
									d.reset()
									d.degree_number = chosen_degree
								else :
									d.reset()
									d.degree_number = chosen_degree
							else :
								d.reset()
								d.degree_number = chosen_degree	
								
					
							# si triade diminuée, on met l'accord en premier renversement
							if d.triad_quality() == "dim" and  d.realization == [1,3,5] :
								d.inversion = 1
							LogBus.info(TAG,"Chord #"+str(idx + 1)+" set to degree " + d.get_roman_numeral() +" of key "+d.key.to_string() + " ( " + d.get_jazz_chord()+ " )")
							LogBus.info(TAG,d.to_string())
							display_harmonic_function(d)
							clean_secondaries(w)
					update_songTrackView_withSelection()		
					play_wrapper(last_wrapper)
					return
					


				elif event.scancode == 16777352 or event.scancode == 50:
					#Touche 2
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					if selected_wrappers.size() == 0 :
						LogBus.info(TAG,"No selected Degree !")
						return
					var last_wrapper
					#var last_idx = last_wrapper.get_meta("index")
					add_current_progression_track_to_undo()	
					for w in wrappers:
						var idx = w.get_meta("index")
						var d:Degree = w.get_meta("degree")

						if d is Degree and w.get_meta("selected"):
							last_wrapper = w
							var chosen_degree = 2
							if d.degree_number == chosen_degree and d.kind != "N6":
								# on ajoute la septieme
								if d.realization == [1,3,5]:
									d.realization = [1,3,5,7]
								elif d.realization == [1,3,5,7]:
									d.set_add9()
								elif d.kind == "add9":
									d.set_add11()
								elif d.kind == "add11":
									d.reset()
									d.degree_number = chosen_degree
								else :
									d.reset()
									d.degree_number = chosen_degree
							else :
								d.reset()
								d.degree_number = chosen_degree	
								
					
							# si triade diminuée, on met l'accord en premier renversement
							if d.triad_quality() == "dim" and  d.realization == [1,3,5] :
								d.inversion = 1
							LogBus.info(TAG,"Chord #"+str(idx + 1)+" set to degree " + d.get_roman_numeral() +" of key "+d.key.to_string() + " ( " + d.get_jazz_chord()+ " )")
							LogBus.info(TAG,d.to_string())
							display_harmonic_function(d)
							clean_secondaries(w)
					update_songTrackView_withSelection()		
					play_wrapper(last_wrapper)
					return

				elif event.scancode == 16777353 or event.scancode == 34:
					# Touche 3
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					if selected_wrappers.size() == 0 :
						LogBus.info(TAG,"No selected Degree !")
						return
					var last_wrapper
					#var last_idx = last_wrapper.get_meta("index")
					add_current_progression_track_to_undo()	
					for w in wrappers:
						var idx = w.get_meta("index")
						var d:Degree = w.get_meta("degree")

						if d is Degree and w.get_meta("selected"):
							last_wrapper = w
							var chosen_degree = 3
							if d.degree_number == chosen_degree:
								
#								if Input.is_key_pressed(KEY_ALT):
#									# on altère
#									# func set_chord_alteration(degree:int, alter:int):
#									var alter = d.get_chord_alteration(chosen_degree)
#									d.set_chord_alteration(chosen_degree, alter + 1)		
								# on ajoute la septieme
								if d.realization == [1,3,5]:
									d.realization = [1,3,5,7]
								elif d.realization == [1,3,5,7]:
									d.set_add9()
								elif d.kind == "add9":
									d.set_add11()
								elif d.kind == "add11":
									d.reset()
									d.degree_number = chosen_degree
								else :
									d.reset()
									d.degree_number = chosen_degree
							else :
								d.reset()
								d.degree_number = chosen_degree	
								
					
							# si triade diminuée, on met l'accord en premier renversement
							if d.triad_quality() == "dim" and  d.realization == [1,3,5] :
								d.inversion = 1
							LogBus.info(TAG,"Chord #"+str(idx + 1)+" set to degree " + d.get_roman_numeral() +" of key "+d.key.to_string() + " ( " + d.get_jazz_chord()+ " )")
							LogBus.info(TAG,d.to_string())
							display_harmonic_function(d)
							clean_secondaries(w)
					update_songTrackView_withSelection()		
					play_wrapper(last_wrapper)
					return

				
				elif event.scancode == 16777354 or event.scancode == 39:
					# Touche 4
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					if selected_wrappers.size() == 0 :
						LogBus.info(TAG,"No selected Degree !")
						return
					var last_wrapper
					#var last_idx = last_wrapper.get_meta("index")
					add_current_progression_track_to_undo()	
					for w in wrappers:
						var idx = w.get_meta("index")
						var d:Degree = w.get_meta("degree")

						if d is Degree and w.get_meta("selected"):
							last_wrapper = w
							var chosen_degree = 4
							if d.degree_number == chosen_degree:
								# on ajoute la septieme
								if d.realization == [1,3,5]:
									d.realization = [1,3,5,7]
								elif d.realization == [1,3,5,7]:
									d.set_add9()
								elif d.kind == "add9":
									d.set_add11()
								elif d.kind == "add11":
									d.reset()
									d.degree_number = chosen_degree
								else :
									d.reset()
									d.degree_number = chosen_degree
							else :
								d.reset()
								d.degree_number = chosen_degree	
								
					
							# si triade diminuée, on met l'accord en premier renversement
							if d.triad_quality() == "dim" and  d.realization == [1,3,5] :
								d.inversion = 1
							LogBus.info(TAG,"Chord #"+str(idx + 1)+" set to degree " + d.get_roman_numeral() +" of key "+d.key.to_string() + " ( " + d.get_jazz_chord()+ " )")
							LogBus.info(TAG,d.to_string())
							display_harmonic_function(d)
							clean_secondaries(w)
					update_songTrackView_withSelection()		
					play_wrapper(last_wrapper)
					return
			
				elif event.scancode == 16777355 or event.scancode == 53:
					#Touche 5
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					if selected_wrappers.size() == 0 :
						LogBus.info(TAG,"No selected Degree !")
						return
					var last_wrapper
					#var last_idx = last_wrapper.get_meta("index")
					add_current_progression_track_to_undo()	
					for w in wrappers:
						var idx = w.get_meta("index")
						var d:Degree = w.get_meta("degree")

						if d is Degree and w.get_meta("selected"):
							last_wrapper = w
							var chosen_degree = 5
							if d.degree_number == chosen_degree:	
								# on ajoute la septieme
								if d.realization == [1,3,5]:
									d.realization = [1,3,5,7]
								elif d.realization == [1,3,5,7]:
									d.set_add9()
								elif d.kind == "add9":
									d.set_add11()
								elif d.kind == "add11":
									d.reset()
									d.degree_number = chosen_degree
								else :
									d.reset()
									d.degree_number = chosen_degree
							else :
								d.reset()
								d.degree_number = chosen_degree	
								
					
							# si triade diminuée, on met l'accord en premier renversement
							if d.triad_quality() == "dim" and  d.realization == [1,3,5] :
								d.inversion = 1
							LogBus.info(TAG,"Chord #"+str(idx + 1)+" set to degree " + d.get_roman_numeral() +" of key "+d.key.to_string() + " ( " + d.get_jazz_chord()+ " )")
							LogBus.info(TAG,d.to_string())
							display_harmonic_function(d)
							if d.key.scale_name == "minor":
								LogBus.info(TAG,"minor v -> Press [M] if you wish to set a dominant V")
							clean_secondaries(w)
					update_songTrackView_withSelection()		
					play_wrapper(last_wrapper)
					return

				elif event.scancode == 16777356 or event.scancode == 54:
					#Touche 6
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					if selected_wrappers.size() == 0 :
						LogBus.info(TAG,"No selected Degree !")
						return
					var last_wrapper
					#var last_idx = last_wrapper.get_meta("index")
					add_current_progression_track_to_undo()	
					for w in wrappers:
						var idx = w.get_meta("index")
						var d:Degree = w.get_meta("degree")

						if d is Degree and w.get_meta("selected"):
							last_wrapper = w
							var chosen_degree = 6
							if d.degree_number == chosen_degree:
								# on ajoute la septieme
								if d.realization == [1,3,5]:
									d.realization = [1,3,5,7]
								elif d.realization == [1,3,5,7]:
									d.set_add9()
								elif d.kind == "add9":
									d.set_add11()
								elif d.kind == "add11":
									d.reset()
									d.degree_number = chosen_degree
								else :
									d.reset()
									d.degree_number = chosen_degree
							else :
								d.reset()
								d.degree_number = chosen_degree	
								
					
							# si triade diminuée, on met l'accord en premier renversement
							if d.triad_quality() == "dim" and  d.realization == [1,3,5] :
								d.inversion = 1
							LogBus.info(TAG,"Chord #"+str(idx + 1)+" set to degree " + d.get_roman_numeral() +" of key "+d.key.to_string() + " ( " + d.get_jazz_chord()+ " )")
							LogBus.info(TAG,d.to_string())
							display_harmonic_function(d)
							clean_secondaries(w)
					update_songTrackView_withSelection()		
					play_wrapper(last_wrapper)
					return


				elif event.scancode == 16777357 or event.scancode == 55:
					#Touche 7
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					if selected_wrappers.size() == 0 :
						LogBus.info(TAG,"No selected Degree !")
						return
					var last_wrapper
					#var last_idx = last_wrapper.get_meta("index")
					add_current_progression_track_to_undo()	
					for w in wrappers:
						var idx = w.get_meta("index")
						var d:Degree = w.get_meta("degree")

						if d is Degree and w.get_meta("selected"):
							last_wrapper = w
							var chosen_degree = 7
							if d.degree_number == chosen_degree:
								# on ajoute la septieme
								if d.realization == [1,3,5]:
									d.realization = [1,3,5,7]
								elif d.realization == [1,3,5,7]:
									d.set_add9()
								elif d.kind == "add9":
									d.set_add11()
								elif d.kind == "add11":
									d.reset()
									d.degree_number = chosen_degree
								else :
									d.reset()
									d.degree_number = chosen_degree
							else :
								d.reset()
								d.degree_number = chosen_degree	
								
					
							# si triade diminuée, on met l'accord en premier renversement
							if d.triad_quality() == "dim" and  d.realization == [1,3,5] :
								d.inversion = 1
							LogBus.info(TAG,"Chord #"+str(idx + 1)+" set to degree " + d.get_roman_numeral() +" of key "+d.key.to_string() + " ( " + d.get_jazz_chord()+ " )")
							LogBus.info(TAG,d.to_string())
							display_harmonic_function(d)
							clean_secondaries(w)
					update_songTrackView_withSelection()		
					play_wrapper(last_wrapper)
					return


				###################################################################################
				###################################################################################
				###################################################################################
				
				# sus2 et sus4
				elif event.scancode == 83:
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					var last_selected_wrapper = null
					add_current_progression_track_to_undo()	
					for w in wrappers:
						if w.get_meta("selected"):
							if w.get_meta("degree")== null or (w.get_meta("degree") is Degree) == false:
								LogBus.error(TAG,'Reduit extension extension: get_meta("degree")== null')
								return
							var d = w.get_meta("degree")
							last_selected_wrapper = w
							var txt_info
							if d is Degree:
								if d.kind == "sus4":
									if d.realization == [1,4,5] and d.key.seventh_quality(d.degree_number) == "7":
										d.realization =[1,4,5,7]
										txt_info = "Degree set to sus4 with 7th"
									else: 
										d.set_sus2()
										txt_info = "Degree set to sus2"
									LogBus.info(TAG,txt_info + " -> " + d.get_jazz_chord())	
									play_wrapper(last_selected_wrapper)
									songTrackView.select_only_wrapper(last_selected_wrapper)
									var deg = last_selected_wrapper.get_meta("degree")
									LogBus.info(TAG,deg.to_string())
									display_harmonic_function(deg)
									
								elif d.kind == "sus2":
									if d.realization == [1,2,5] and d.key.seventh_quality(d.degree_number) == "7":
										d.realization =[1,2,5,7]
										txt_info = "Degree set to sus2 with 7th"
									else: 
										d.set_sus4()
										txt_info = "Degree set to sus4"

									LogBus.info(TAG,txt_info + " -> " + d.get_jazz_chord())	
									play_wrapper(last_selected_wrapper)
									songTrackView.select_only_wrapper(last_selected_wrapper)
									var deg = last_selected_wrapper.get_meta("degree")
									LogBus.info(TAG,deg.to_string())
								else:
									d.set_sus4()
									txt_info = "Degree set to sus4"
									LogBus.info(TAG,txt_info + " -> " + d.get_jazz_chord())	
									play_wrapper(last_selected_wrapper)
									songTrackView.select_only_wrapper(last_selected_wrapper)
									var deg = last_selected_wrapper.get_meta("degree")
									LogBus.info(TAG,deg.to_string())
									display_harmonic_function(deg)
								clean_secondaries(w)
							
					update_songTrackView_withSelection()
					return
					
					
				# FLECHES GAUCHE ET DROITE
				elif event.scancode == 16777231 or event.scancode == 16777233:
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					# on cherche les wrappers sélectionnés
					if selected_wrappers.size() > 0:
						var w = selected_wrappers[-1]
						var idx = w.get_meta("index")
						var new_wrapper
						if event.scancode == 16777231:
							new_wrapper = wrappers[(wrappers.size()+idx-1)%wrappers.size()]
						else :
							new_wrapper = wrappers[(idx+1)%wrappers.size()]
						#play_wrapper(new_wrapper)
#						var d = w.get_meta("degree")
#						if d and d is Degree:
#
#							var info_txt = "Chord #" + str(1 + (w.get_meta("index"))) + " :"
#							info_txt += get_info_degree_txt(d)
#							LogBus.info(TAG,info_txt)
							
						songTrackView.select_only_wrapper(new_wrapper)
						play_wrapper(new_wrapper)
						var deg = new_wrapper.get_meta("degree")
						LogBus.info(TAG,deg.to_string())
						display_harmonic_function(deg)
						#songTrackView.update_ui()
					return
				# + -> Octave UP
				elif event.scancode == 16777232 :
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					var last_selected_wrapper = null
					add_current_progression_track_to_undo()	
					for w in wrappers:
						if w.get_meta("selected"):
							var el = w.get_meta("degree")
							# regarder ce que ca donne avec N6 et les aug6 !
							if el is Degree:
								last_selected_wrapper = w
								if el._octave < 5:
									el._octave += 1
									LogBus.info(TAG,"Degree octave upped => " + str(el._octave))
								else:
									LogBus.info(TAG,"octave = +5 (reached the maximum value) ")	
					play_wrapper(last_selected_wrapper)
					songTrackView.select_only_wrapper(last_selected_wrapper)
					var deg = last_selected_wrapper.get_meta("degree")
					LogBus.info(TAG,deg.to_string())
					display_harmonic_function(deg)
					update_songTrackView_withSelection()
					return
				# - -> Octave down
				elif event.scancode == 16777234 :
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					var last_selected_wrapper = null
					add_current_progression_track_to_undo()	
					for w in wrappers:
						if w.get_meta("selected"):
							var el =w.get_meta("degree")
							# regarder ce que ca donne avec N6 et les aug6 !
							if el is Degree:
								last_selected_wrapper = w
								if el._octave > -5:
									el._octave += -1
									LogBus.info(TAG,"Degree octave lowered => " + str(el._octave))
								else:
									LogBus.info(TAG,"octave = -5 (reached the minimum value) ")	
					play_wrapper(last_selected_wrapper)
					songTrackView.select_only_wrapper(last_selected_wrapper)
					var deg = last_selected_wrapper.get_meta("degree")
					LogBus.info(TAG,deg.to_string())
					display_harmonic_function(deg)
					update_songTrackView_withSelection()
					return

				# 8 -> Renverse down
				elif event.scancode == 16777347 :
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					var last_selected_wrapper = null
					add_current_progression_track_to_undo()	
					for w in wrappers:
						if w.get_meta("selected"):
							if w.get_meta("degree") == null or w.get_meta("degree") is Degree == false:
								LogBus.error(TAG,'Renverse UP -> w.get_meta("degree") == null')
								return
							var el = w.get_meta("degree") 
							# regarder ce que ca donne avec N6 et les aug6 !
							if el is Degree:
								last_selected_wrapper = w
								if el.inversion == -1 :
									el.inversion = 0 #<- renversement alétoire (indéfini)
								el.renverse_down()
								var idx = w.get_meta("index")
								LogBus.info(TAG,"chord#" + str(idx+1) + " reversed down")
							
							
					play_wrapper(last_selected_wrapper)
					songTrackView.select_only_wrapper(last_selected_wrapper)
					var deg = last_selected_wrapper.get_meta("degree")
					display_harmonic_function(deg)
					LogBus.info(TAG,deg.to_string())
					update_songTrackView_withSelection()
					return
					
				# 9 -> Renverse UP  
				elif event.scancode == 16777349 :
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					var last_selected_wrapper = null
					add_current_progression_track_to_undo()	
					for w in wrappers:
						if w.get_meta("selected"):
							if w.get_meta("degree") == null or w.get_meta("degree") is Degree == false:
								LogBus.error(TAG,'Renverse UP -> w.get_meta("degree") == null')
								return
							var el = w.get_meta("degree") 
							# regarder ce que ca donne avec N6 et les aug6 !
							if el is Degree:
								last_selected_wrapper = w
								if el.inversion == -1 :
									el.inversion = 0
								el.renverse_up()
								var idx = w.get_meta("index")
								LogBus.info(TAG,"chord#" + str(idx+1) + " reversed up")

					play_wrapper(last_selected_wrapper)
					songTrackView.select_only_wrapper(last_selected_wrapper)
					var deg = last_selected_wrapper.get_meta("degree")
					LogBus.info(TAG,deg.to_string())
					display_harmonic_function(deg)
					update_songTrackView_withSelection()
					return
				
				# * RENSERSEMENT ALEATOIRE
				elif event.scancode == 16777345 :
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					
					if selected_wrappers.size() == 0:
						LogBus.info(TAG,"No chord selected")
						return
					
					add_current_progression_track_to_undo()	
					var last_selected_wrapper
					for w in selected_wrappers:
						last_selected_wrapper = w
						var d = w.get_meta("degree") 
						# regarder ce que ca donne avec N6 et les aug6 !
						if d is Degree and d.kind == "diatonic" :
							d.inversion = -1
							var idx = w.get_meta("index")
							LogBus.info(TAG,"chord#" + str(idx+1) + " set to random inversion")
					play_wrapper(last_selected_wrapper)
					songTrackView.select_only_wrapper(last_selected_wrapper)
					var deg = last_selected_wrapper.get_meta("degree")
					LogBus.info(TAG,deg.to_string())
					display_harmonic_function(deg)
					update_songTrackView_withSelection()
					return
				
				

				# C-> Cad64
				elif event.scancode == 67 :
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					if selected_wrappers.size() == 0:
						LogBus.info(TAG,"You must select at least one chord !")
						return
					
					var last_selected_wrapper = null
					add_current_progression_track_to_undo()	
					for w in wrappers:
						if w.get_meta("selected"):
							var el:Degree = w.get_meta("degree")
							# regarder ce que ca donne avec N6 et les aug6 !
							if el is Degree:
								last_selected_wrapper = w
								el.set_cad64()
								var idx = w.get_meta("index")
								LogBus.info(TAG,"Chord #"+ str(idx)+ "set to Cad64 -> Cadential 64")
								clean_secondaries(w)
					play_wrapper(last_selected_wrapper)
					songTrackView.select_only_wrapper(last_selected_wrapper)
					var deg = last_selected_wrapper.get_meta("degree")
					LogBus.info(TAG,deg.to_string())	
					display_harmonic_function(deg)		
					update_songTrackView_withSelection()
					return



				# I -> It+6
				elif event.scancode == 73 :
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					if selected_wrappers.size() != 1 :
						LogBus.info(TAG,"you must select ONE chord to apply an augmented Sixth ")
						return
					add_current_progression_track_to_undo()	
					var w = selected_wrappers[0]
					var idx = w.get_meta("index")
					var current_degree:Degree = w.get_meta("degree")
					var stringInversed = ""
					if event.shift:
						current_degree.set_aug6_It_inv()
						stringInversed = "inversed "
					else:
						current_degree.set_aug6_It()

						
					LogBus.info(TAG,"Chord #"+ str(idx) +  " set to "+ current_degree.kind +" -> Italian "+ stringInversed +"Augmented Sixth")

					play_wrapper(w)
					songTrackView.select_only_wrapper(w)
					var deg = w.get_meta("degree")
					LogBus.info(TAG,deg.to_string())	
					display_harmonic_function(deg)		
					update_songTrackView_withSelection()
					return
				
				# F -> Fr+6
				elif event.scancode == 70 :
					if selected_wrappers.size() != 1 :
						LogBus.info(TAG,"you must select ONE chord to apply an augmented Sixth ")
						return
					add_current_progression_track_to_undo()	
					var w = selected_wrappers[0]
					var idx = w.get_meta("index")
					var current_degree:Degree = w.get_meta("degree")
					var stringInversed = ""
					if  event.shift :
						current_degree.set_aug6_Fr_inv()
						stringInversed = "inversed "
					else:
						current_degree.set_aug6_Fr()
#
					LogBus.info(TAG,"Chord #"+ str(idx) +  " set to "+ current_degree.kind +" -> French "+ stringInversed +"Augmented Sixth")

					play_wrapper(w)
					songTrackView.select_only_wrapper(w)
					var deg = w.get_meta("degree")
					LogBus.info(TAG,deg.to_string())	
					display_harmonic_function(deg)		
					update_songTrackView_withSelection()
					return
					
					
					
				# G -> Ger+6
				elif event.scancode == 71 :
					if selected_wrappers.size() != 1 :
						LogBus.info(TAG,"you must select ONE chord to apply an augmented Sixth ")
						return
					add_current_progression_track_to_undo()	
					var w = selected_wrappers[0]
					var idx = w.get_meta("index")
					var current_degree:Degree = w.get_meta("degree")
					var stringInversed = ""
					if  event.shift :
						current_degree.set_aug6_Ger_inv()
						stringInversed = "inversed "
					else:
						current_degree.set_aug6_Ger()

						
					LogBus.info(TAG,"Chord #"+ str(idx) +  " set to "+ current_degree.kind +" -> German "+ stringInversed +"Augmented Sixth")
					play_wrapper(w)
					songTrackView.select_only_wrapper(w)
					var deg = w.get_meta("degree")
					LogBus.info(TAG,deg.to_string())	
					LogBus.info(TAG,"Ger6+ must be followed by a cadential 64 (keyboard shortcut: [C] ) before the V dominant chord.")
					LogBus.info(TAG,"Notice that you can enharmonize this chord ( keyboard shortcut: [E] ) into a V7 to modulate...")
				
					display_harmonic_function(deg)		
					update_songTrackView_withSelection()
					return
					
					
					
					
				# N -> N6
				elif event.scancode == 78 :
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					var last_selected_wrapper = null
					add_current_progression_track_to_undo()	
					for w in wrappers:
						if w.get_meta("selected"):
							var d:Degree = w.get_meta("degree")
							# regarder ce que ca donne avec N6 et les aug6 !
							var scale_name = d.key.scale_name
							if TONAL_KEYS.has(scale_name):
								last_selected_wrapper = w
								d.set_N6()
								var idx = w.get_meta("index")
								LogBus.info(TAG,"Chord #" + str(idx)+ " set to N6 -> Neapolitan Sixth ")	
								clean_secondaries(w)
								play_wrapper(last_selected_wrapper)
								songTrackView.select_only_wrapper(last_selected_wrapper)
								var deg = last_selected_wrapper.get_meta("degree")
								LogBus.info(TAG,deg.to_string())	
								display_harmonic_function(deg)		
							else:
								LogBus.info(TAG,"The key must be tonal " + str(TONAL_KEYS)+" to set a Napolitan Sixth N6 ")
					
					update_songTrackView_withSelection()
					return
				
				
				
				# K -> K -> SCALE
				elif event.scancode == 75 :
					clear_console()
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					var last_scale_wrapper = null
					add_current_progression_track_to_undo()	
					for w in wrappers:
						if w.get_meta("selected"):
							var d = songTrackView._wrapper_to_model.get(w, null) 
							# regarder ce que ca donne avec N6 et les aug6 !
							if true:
								last_scale_wrapper = w
								var scale = null
								var sc = ScaleHelper.new()
								var scales = sc.list_scales()
								var found = scales.find(d.key.get_scale_name())
								if found > -1 :
									if event.shift :
										scale = scales[(scales.size() + found - 1) % scales.size()]
									else :
										scale = scales[(found + 1) % scales.size()]
									
								var k:HarmonicKey = HarmonicKey.new()
								var old_root = d.key.get_root_string()
								var old_rn = d.get_roman_numeral()
								k.set_from_string(old_root + " " + scale)
								d.key = k
								d.update_kind()
								var idx = w.get_meta("index")
								LogBus.info(TAG,"Chord #" + str(idx + 1) + " Scale -> "+ old_rn+ " set to " + d.get_roman_numeral() + " in " + d.key.to_string() )	
								clean_secondaries(w)
								
								
							else:
								var idx = w.get_meta("index")
								LogBus.info(TAG,"Degree #" + str(idx + 1)+   " -> Exotic scales can only be applied to diatonic degrees !")	
								return	
					var last_degree = last_scale_wrapper.get_meta("degree")
					var k = last_degree.key									
					LogBus.info(TAG,"\n" + scale_preview_string(k))
					play_wrapper(last_scale_wrapper)
					#songTrackView.select_only_wrapper(last_scale_wrapper)
					#var deg = last_scale_wrapper.get_meta("degree")
					#LogBus.info(TAG,deg.to_string())	
					display_harmonic_function(null)		
					update_songTrackView_withSelection()
					return
			
													
					
				# M -> Mixture extended
				elif event.scancode == 77 and event.shift:
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					var last_mixture_wrapper = null
					add_current_progression_track_to_undo()	
					for w in wrappers:
						if w.get_meta("selected"):
							var d:Degree = w.get_meta("degree")
							# regarder ce que ca donne avec N6 et les aug6 !
							var scale_name= d.key.scale_name
							if true :
								last_mixture_wrapper = w
								var scale = null
								match scale_name :
									"minor":
										scale = "harmonic_minor"
									"phrygian":
										scale = "minor"
									"lydian":
										scale = "phrygian"
									"dorian":
										scale = "mixolydian"
									"mixolydian":
										scale = "major"
									"major":
										scale = "lydian"
									"harmonic_minor":
										scale = "dorian"
									_:
										scale = "major"

								var k:HarmonicKey = HarmonicKey.new()
								var old_root = d.key.get_root_string()
								var old_rn = d.get_roman_numeral()
								k.set_from_string(old_root + " " + scale)
								
								d.key = k
								d.update_kind()
								var idx = w.get_meta("index")
								LogBus.info(TAG,"Chord #" + str(idx + 1) + " ->  Mixture: "+ old_rn+ " set to " + d.get_roman_numeral() + " in " + d.key.to_string() )	
								clean_secondaries(w)
								play_wrapper(last_mixture_wrapper)
								#songTrackView.select_only_wrapper(last_mixture_wrapper)
#								var deg = last_mixture_wrapper.get_meta("degree")
#								LogBus.info(TAG,deg.to_string())	
								display_harmonic_function(null)		
							else :
								var idx = w.get_meta("index")
								LogBus.info(TAG,"Chord #" + str(idx + 1) + " -> Mixture can only be applied to diatonic degrees !")	
								return

					update_songTrackView_withSelection()
					return					
				
				
				# Mixture basic (major / minor)
				elif event.scancode == 77:
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					var last_mixture_wrapper = null
					add_current_progression_track_to_undo()	
					for w in wrappers:
						if w.get_meta("selected"):
							var d:Degree = w.get_meta("degree")
							# regarder ce que ca donne avec N6 et les aug6 !
							var scale_name= d.key.scale_name
							if true :
								last_mixture_wrapper = w
								
								var scale = null
								match scale_name :
									"minor":
										if d._comment == "harmonic degree III+ set III in minor" and d.degree_number == 3 :
											scale = "minor"
											d._comment = ""
										else :
											scale = "major"
									"harmonic_minor":
										scale = "minor"
										
									"major":
										if d.degree_number != 3:
											scale = "harmonic_minor"
										else :
											scale = "minor"
											d._comment = "harmonic degree III+ set III in minor"
									_:
										scale = "major"

								var k:HarmonicKey = HarmonicKey.new()
								var old_root = d.key.get_root_string()
								var old_rn = d.get_roman_numeral()
								k.set_from_string(old_root + " " + scale)
								d.key = k
								###########
								d.update_kind()
								
								
								
								###########
								
								
								
								var idx = w.get_meta("index")
								LogBus.info(TAG,"Chord #" + str(idx + 1) + " ->  Mixture: "+ old_rn+ " set to " + d.get_roman_numeral() + " in " + d.key.to_string() )	
								clean_secondaries(w)

							else :
								var idx = w.get_meta("index")
								LogBus.info(TAG,"Chord #" + str(idx + 1) + " -> Mixture can only be applied to diatonic degrees !")	
								return
					play_wrapper(last_mixture_wrapper)
					#songTrackView.select_only_wrapper(last_mixture_wrapper)
					#var deg = last_mixture_wrapper.get_meta("degree")
					#LogBus.info(TAG,deg.to_string())	
					display_harmonic_function(null)	
					update_songTrackView_withSelection()
					return		
				
				# Upper et Lower key
				elif event.scancode == 76 or event.scancode == 85:
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					# 76 -> L et 85 -> U
					if selected_wrappers.size() == 0 :
						LogBus.info(TAG,"No selected Degree !")
						return
					var last_wrapper = selected_wrappers[-1]
					add_current_progression_track_to_undo()	
					for w in wrappers:
						if w.get_meta("selected"):
							var el = w.get_meta("degree")
							# regarder ce que ca donne avec N6 et les aug6 !
							if el is Degree:
								#var d = el.clone()
								var old_key = el.key
								var new_key:HarmonicKey =  old_key.clone()
								
								
								if event.scancode == 85 :
									#upper key
									new_key.root_midi = 60 + (old_key.root_midi + 7) % 12
									if event.shift:
										el.degree_number = 1 + (el.degree_number + 2) % 7
								else:
									#lower key
									new_key.root_midi = 48 + (old_key.root_midi +5 ) % 12
									if event.shift:
										el.degree_number = 1 + (el.degree_number + 3) % 7
								el.key = new_key
								if event.scancode == 85 :
									LogBus.info(TAG,"Upper key: "+ old_key.to_string() + " -> "+el.key.to_string())
									clean_secondaries(w)
								else :
									LogBus.info(TAG,"Lower key: "+ old_key.to_string() + " -> "+el.key.to_string())
									clean_secondaries(w)
					play_wrapper(last_wrapper)
					songTrackView.select_only_wrapper(last_wrapper)
					var deg = last_wrapper.get_meta("degree")
					LogBus.info(TAG,deg.to_string())	
					display_harmonic_function(deg)	
					update_songTrackView_withSelection()
					return


				# R -> Relative key
				elif event.scancode == 82:
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					if selected_wrappers.size() == 0 :
						LogBus.info(TAG,"No selected Degree !")
						return
					var last_wrapper = selected_wrappers[-1]
					add_current_progression_track_to_undo()	
					for w in wrappers:
						if w.get_meta("selected"):
							var el = w.get_meta("degree")
							var idx = w.get_meta("index")
							# regarder ce que ca donne avec N6 et les aug6 !
							if el is Degree:
								var scale_name = el.key.scale_name
								if ["major","minor","melodic_minor","harmonic_minor"].has(scale_name) == false:
									LogBus.info(TAG,"Relative key is only available for major or minor keys")
									return
								#var d = el.clone()
								var old_key = el.key
								#var new_degree:Degree = Degree.new()
								var new_key:HarmonicKey =  old_key.clone()
								if old_key.scale_name == "major":
									new_key.scale_name = "minor"
									new_key.root_midi = (old_key.root_midi + 9) % 12
									el.key = new_key
									if  ["It+6","Fr+6","Ger+6", "It+6inv","Fr+6inv","Ger+6inv", "N6"].has(el.kind):
										match el.kind:
											"it+6": el.set_aug6_It()
											"Fr+6": el.set_aug6_Fr()
											"Ger+6": el.set_aug6_Ger()			
											"it+6Inv": el.set_aug6_It_inv()
											"Fr+6Inv": el.set_aug6_Fr_inv()
											"Ger+6Inv": el.set_aug6_Ger_inv()
									el.degree_number = 1+ (el.degree_number + 1) % 7
									if el.degree_number == 5 or  el.degree_number == 7 :
										el.key.scale_name = "harmonic_minor"
								else:
									new_key.scale_name = "major"
									new_key.root_midi = (old_key.root_midi + 3) % 12
									el.key = new_key
									el.degree_number = 1 +(el.degree_number + 4) % 7
									
									

								LogBus.info(TAG,"Chord #"+str(idx)+" Relative key: "+ old_key.to_string() + " -> "+el.key.to_string())
								clean_secondaries(w)
					play_wrapper(last_wrapper)
					songTrackView.select_only_wrapper(last_wrapper)
					var deg = last_wrapper.get_meta("degree")
					LogBus.info(TAG,deg.to_string())	
					display_harmonic_function(deg)	
					update_songTrackView_withSelection()
					return


				
			else :
				if event.scancode == 16777231 or event.scancode == 16777233:
					#accept_event() # Empêche l'événement de se propager à d'autres nœuds
					# on cherche les wrappers sélectionnés
					if wrappers.size() > 0:
						songTrackView.select_only_wrapper(wrappers[0])
						songTrackView.update()
						var w = wrappers[0]
						play_wrapper(w)
						songTrackView.select_only_wrapper(w)
						var deg = w.get_meta("degree")
						LogBus.info(TAG,deg.to_string())	
						display_harmonic_function(deg)	
						update_songTrackView_withSelection()
						#songTrackView.update_ui()
					return
				
				
				return	
					
		

#





func _on_help_btn_pressed():
	var txt = "KEYBOARD SHORTCUTS:\n\n"
	txt += "Transport:\n"
	txt += " > SPACE to play/stop\n"
	txt += " > [shift] . (numeric pad): Set the starting position marker \n"
	txt += " > [0] (numeric pad) -> Rewind and reset starting position marker\n"
	txt += "Use your mousewheel over the timeline to scroll and set the playhead position.\n\n"
	txt += "[F1] [F2] [F3] [F4]: track display -> Midi / jazz chord / roman numeral / keyboard\n"
	txt += "[F5] [F6]: increase/decrease the track zoom factor\n"
	txt += "\n"	
	txt += "[Command] G: Generate a chord progression\n"
	txt += "[Command] A: select all chords of the timeline\n"
	txt += "[Command] X / C / V to cut / copy / paste the selected chords\n"
	txt += "Clipboard chords will be inserted after your selection.\n"
	txt += "[Command][Backspace]: Delete the selected chords\n"
	txt += "[Command] R or D: Repeat the selected chords\n"
	txt += "[D] / [H]: double / half length applied to the selected chords\n"
	txt += "[Command] Z : Undo\n"
	txt += "[Shift][Command] Y : Redo\n"
	
	txt += "\n"
	txt += "[<-] and [->] : select the previous and next chord\n"
	txt += "[1]...[7] : set the selected chord(s) to degree number to 1...7\n"
	txt += "-> Press the number key again to add Seventh / Ninth / Eleventh\n"
	txt += "[+] or [-] :  chord inversion up / down\n"
	txt += "(diatonic triads cannot be set in second inversion)\n"
	txt += "[Up] and [Down] arrow : octave + / -\n"
	txt += "[I] / [F] / [G] : -> Augmented 6th (It6+ / Fr6+/ Ger+\n"
	txt += "Like secondary chords, augmented sixth target the selection next chord\n"
	txt += "[ALT][I] / [ALT][F] / [ALT][G] : -> Inverse Augmented 6th\n"
	txt += "[C] : -> Cadential 64\n"
	txt += "[N] : -> Neapolitan Sixth N6\n"
	txt += "[U] / [L] : Modulation -> Selected chords(s) are set to Upper / Lower key\n" 
	txt += "-> use [Alt] U / L to transpose the chord degree and compensate the key transposition\n" 
	txt += "[R] : set the chord to its relative scale (major/minor)\n" 
	txt += "[K]: Sweep Scales on selected chords (exotic scales included)\n" 
	txt += "[M] : Mixture, change the selected chords key to their parallel key:\n" 
	txt += "major -> minor or harmonic_minor -> major..."
	txt += "[Shift][M] : Extended Mixture, major, minor and modes...:\n" 
	txt += "[Command][M] : Compute a random modulation path between 2 chords tonality:\n" 
	txt += '(Use the "Modulation" panel to set the modulation techniques applied)'
	txt += "[Alt][3] : set a third alteration to the selected chord\n"
	txt += "[Alt][5] : set a fifth alteration to the selected chord\n"
	txt += "[Backspace]: Reset the chord to the first diatonic degree of key C Major\n" 
	txt += "[T]: Tonalize the current chord -> set the key so the chord is the tonic of the new key\n" 
	txt += "[E] : Enharmonize the selected chord: The magic door of the harmonic trans-dimensional modulation*\n" 
	
	
	
	
	txt += "[>] : apply the key of the 1st selected chord to all the selection\n" 

	txt += "\nSecondary chords\n"	
	txt += "The target chord is the next chord after to your selection\n"	
	txt += "[Command] 5:  Secondary Dominant V/ of the next chord\n" 
	txt += "[Command] 7 : Secondary Half-Diminished Seventh viiø/ of the next chord\n" 
	txt += "[Command] 7 twice : Secondary full-Diminished Seventh vii°/ of the next chord\n" 
	txt += "ii/ and IV/ secondary chords must be set before a dominant V chord to target the right chord\n" 
	txt += "[Command] 2:  Secondary ii/\n" 
	txt += "[Command] 4: Secondary IV/\n" 
	txt += "\n\nScroll this page to display all the available comamnds and their keyboard shortcuts" 
	clear_console()
	console.text = txt


func add_current_progression_track_to_undo():
	#clear_console()
	_redo_tracks = []
	var track_name:String = songTrackView.trackName
	var song:Song = songTrackView.song
	var track:Track = song.get_track_by_name(track_name).clone()
	_undo_tracks.append(track)
	if _undo_tracks.size() > _max_undo_levels:
		var _trash = _undo_tracks.pop_front()
		
		

func restore_redo_track():
	if _redo_tracks.size() > 0:

		midi_player.stop()
		playStopBtn.text = "Play"
		var current_song = songTrackView.song
		var current_track_name = songTrackView.trackName
		var current_track = current_song.get_track_by_name(current_track_name)
		_undo_tracks.append(current_track.clone())
		var restored_track:Track = _redo_tracks.pop_back().clone()


		restored_track.name = Song.PROGRESSION_TRACK_NAME
		myMasterSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
		myMasterSong.add_track(restored_track)
		myPlayingSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
		myPlayingSong.add_track(restored_track)
		songTrackView.song = myPlayingSong
		songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
		#songTrackView._update_all()
		songTrackView.update_ui()
		LogBus.info(TAG,"Redo !")
		if songTrackView.get_wrappers().size() == 0 :
			LogBus.info(TAG,"")
			no_chords()
			generate_btn.show()
		return
	else:
		LogBus.info(TAG, "There's no redo track to restore.")
		return


func restore_undo_track():
	if _undo_tracks.size() > 0:
		

		midi_player.stop()
		playStopBtn.text = "Play"

		
		var current_song = songTrackView.song
		var current_track_name = songTrackView.trackName
		var current_track = current_song.get_track_by_name(current_track_name)
		_redo_tracks.append(current_track.clone())
		
		var restored_track:Track = _undo_tracks.pop_back()

		restored_track.name = Song.PROGRESSION_TRACK_NAME
		myMasterSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
		myMasterSong.add_track(restored_track)
		myPlayingSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
		myPlayingSong.add_track(restored_track)
		songTrackView.song = myPlayingSong
		songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
		#songTrackView._update_all()
		songTrackView.update_ui()
		LogBus.info(TAG,"Undo !")
		if songTrackView.get_wrappers().size() == 0 :
			LogBus.info(TAG,"")
			no_chords()
			generate_btn.show()
		return
	else:
		LogBus.info(TAG, "There's no undo track to restore.")
		return


func update_songTrackView_withSelection():
	#add_current_progression_track_to_undo()
	var sel = songTrackView._get_selected_indices()
	songTrackView.update_ui()
	var wrappers = songTrackView.get_wrappers()
	for i in sel:
		songTrackView.select_wrapper(wrappers[i])



func _on_SongTrackView_element_right_clicked(_element,wrapper):
	# on joue l'accord cliqué
	var d:Degree = wrapper.get_meta("degree")
	
	
	var g_chords = d.guitar_chords()
	if g_chords == null or g_chords.size() == 0:
		LogBus.info(TAG,"No guitar Chord found")
		return
	clear_console()
	LogBus.info(TAG, str(g_chords.size()) + " voicings found\n")
	var idx = rng.randi() % g_chords.size()
	var c = g_chords[idx]
	
	LogBus.info(TAG,"Guitar Chord: " + c.get_ascii_tab())
	var current_chord_midi_notes = c.midiNotes()
	midi_player.stop()
	var guitar_chord_song= Song.new()
	var chord_track = Track.new()
	var chord_pc = ProgramChange.new()
	chord_pc.set_channel(0)
	chord_pc.set_program(9)
	
	chord_track.set_program_change(chord_pc)
	#print("chord_program: " + str(chord_program_ob.get_program()))
	#chord_track.adopt_program_channel = true
	#chord_track.set_program_change()
	var delta_notes = .2
	var pos = 0
	for m in current_chord_midi_notes:
		var n:Note = Note.new()
		#n.velocity = int(chord_vol_sl.value)
		n.length_beats = 4
		n.midi = m
		chord_track.add_note(pos,n)
		pos += delta_notes
	guitar_chord_song.add_track(chord_track)
	midi_player.load_from_bytes(guitar_chord_song.get_midi_bytes_type1())
	anim_songTrack_view = false
	midi_player.play()
	
	
func _on_SongTrackView_element_clicked(element,_index,wrapper):
	clear_console()
	if songTrackView._selected.keys().size() == 0 :
		LogBus.info(TAG,"no selection")
	elif songTrackView._selected.keys().size() == 1 :
		if element is Degree :
			LogBus.info(TAG, element.to_string())
			display_harmonic_function(element)
			play_wrapper(wrapper)			
		else :
			LogBus.error(TAG,"_on_SongTrackView_element_clicked() -> element is not a Degree !")
	else: 
		var ws = songTrackView.get_wrappers()
		var wsel  = []
		for w in ws :
			if w.get_meta("selected") :
				wsel.append(w.get_meta("index"))
		var selected = songTrackView.get_selected_wrappers()
		display_harmonic_function(null)
		LogBus.info(TAG,str(selected.size())+ " chord(s) selected")
				



	

func get_info_degree_txt(d:Degree) -> String:
	var txt = d.get_jazz_chord() + " => Degree [" + d.get_roman_numeral() + "] in key " + d.key.to_string() + " \n"
	

	txt += "kind: " + d.kind
	if d._is_secondary: 
		if d.degree_number == 5 or d.degree_number == 7:
			txt += " (Secondary chord) -> must resolve to the next Degree"
		elif d.degree_number == 2 or d.degree_number == 4: 
			txt += ' (Secondary Chord) -> must be followed by a secondary Dominant chord "V/" '
	elif d.kind == "N6":
		txt += " (Neapolitan Sixth) -> must be followed by a Dominant V chord"
	txt += "\n"
	
	# inversion
	var txt_position
	if d.realization.size() == 3:
		match d.inversion:
			0:
				txt_position = "root"
			1:
				txt_position = "First inversion [6]"
			2:
				txt_position = "Second inversion [64]"
	elif d.realization.size() == 4:
		match d.inversion:
			0:
				txt_position = "root [7]"
			1:
				txt_position = "First inversion [65]"
			2:
				txt_position = "second inversion [43]"
			3:
				txt_position = "Third inversion [43]"
	else:
		LogBus.error(TAG,"get_info_degree_txt() -> bad realization: "+str(d.realization))
	
	if txt_position:
		txt += "Position: " + txt_position + ",  "
	
	var func_txt
	match d.harmonic_function:
		"T":
			func_txt = "Tonic"
		"PD":
			func_txt = "Pre-dominant"
		"D":
			func_txt = "Dominant"
	if func_txt:
		txt += "Function: "+func_txt
	
	var notes_txt = []
	for m in d.get_chord_midi():
		notes_txt.append(NoteParser.midipitch2String(m))
	txt += "\n -> "+str(notes_txt) + "\n\n"
	
	txt += d.to_string()+"\n\n"
	
	#txt += Dico.get_blabla(d)
	
	
	#txt += "\n\n"+ d.to_string()
	
	return txt

func play_wrapper(w):
	if w != null and w.has_meta("degree"):
		var e = w.get_meta("degree")
		if e is Degree :
			midi_player.stop()
			#song_playing_ended = true
			#rewind()
			var s:Song = Song.new()
			var tr:Track = Track.new()
			var d:Degree = e.clone()
			d.length_beats = .5
			tr.add_degree(0,d)
			var PC:ProgramChange = ProgramChange.new()
			PC.set_program($program_number/program_number_ob.selected) 
			tr.set_program_change(PC)
			s.add_track(tr)
			

			anim_songTrack_view = false
			var bytes = s.get_midi_bytes_type1()
			midi_player.load_from_bytes(bytes)
			midi_player.play()
			playStopBtn.text = "Play"

func play_notes(notes:Array):

	if notes != null:
		midi_player.stop()
		#song_playing_ended = true
		#rewind()
		var s:Song = Song.new()
		var tr:Track = Track.new()
		for n in notes:
			var note:Note = Note.new()
			note.midi = n
			note.length_beats = .5
			tr.add_note(0,note)
		s.add_track(tr)

		anim_songTrack_view = false
		var bytes = s.get_midi_bytes_type1()
		midi_player.load_from_bytes(bytes)
		midi_player.play()
		playStopBtn.text = "Play"

func get_previous_wrapper(w) -> Panel:
	var indice:int = w.get_meta("index")
	if indice != null :
		var wrappers = songTrackView.get_wrappers()
		if wrappers.size() > 1 :
			return wrappers[(indice + wrappers.size() - 1 )% wrappers.size()]
		else :
			return w
	else :
		LogBus.error(TAG,"ERROR: previous wrapper has no indice !")
		return w
		
func get_next_wrapper(w) -> Panel:
	var indice:int = w.get_meta("index")
	if indice != null :
		var wrappers = songTrackView.get_wrappers()
		if wrappers.size() > 1 :
			return wrappers[(indice + 1 )% wrappers.size()]
		else :
			return w
	else :
		LogBus.error(TAG,"ERROR: next wrapper has no indice !")
		return w	
	
		
func clean_secondaries(w):
	var previous_wrapper = get_previous_wrapper(w)
	if previous_wrapper.get_meta("degree"):
		var previous_degree:Degree =  previous_wrapper.get_meta("degree")
		if previous_degree._is_secondary :
			previous_degree._is_secondary = false
			clean_secondaries(previous_wrapper)
		else :
			return
		
			
	
	
	
func get_pos(dic: Dictionary, k: String) -> int:
	var keys = dic.keys()
	for i in range(keys.size()):
		if keys[i] == k:
			return i
	return -1
	
func get_key_by_index(dic: Dictionary, index: int) -> String:
	var keys = dic.keys()
	if index >= 0 and index < keys.size():
		return keys[index]
	return ""


func _on_song_time_num_sb_value_changed(value):
	myPlayingSong.time_num = value

func _on_song_time_den_sb_value_changed(value):
	myPlayingSong.time_den = value

##################################################################
##################################################################
##################################################################

	
func _ask_progression_satbs():
	clear_console()
	
	var wrappers = songTrackView.get_wrappers()
	if wrappers.size() == 0 :
		LogBus.info(TAG,"you must generate a progression before !")
		return
	
	var progression:Array = []
	
	var tr = myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME)



	var events = tr.events
	var degrees_events:Array = []
	for e in events:
		if e.has("degree"):
			degrees_events.append(e)
			

	
	for i in range(0,degrees_events.size()):
		var request:Dictionary = {}
		
		request["index"] = i
		request["pos"] = degrees_events[i]["start"]
		var d:Degree = degrees_events[i]["degree"]
		request["length_beats"] = d.length_beats
		request["key_midi_root"] = d.key.root_midi % 12
		request["key_scale_name"] = d.key.get_scale_name()
		var short_scale_array = []
		var long_scale_array = d.key.get_scale_array()
		# bug harmonicKey -> key.get_scale_array fait 8 notes (et pas 7)
		for j in range(0,7):
			short_scale_array.append(long_scale_array[j])
		request["scale_array"] = short_scale_array
		#************************************************
		request["key_alterations"] = d._get_alterations()
		#************************************************
		request["degree_number"] = d.degree_number
		request["kind"] = d.kind
		request["chord_notes"] = d.get_chord_midi()
		request["center_target"] = int(center_target_SL.value)
		request["best_distance"] = int(best_distance_SL.value)
		request["distance_scoring_factor"] = distance_scoring_SL.value * -1
		request["center_scoring_factor"] = center_scoring_SL.value * -1
		if free_inversion_cb.pressed == false and d.inversion != -1:
			request["inversion"] = d.inversion
		progression.append(request)
		


	var request_data = {
	"n_solutions": 100,
	"temperature": int(temperature_SL.value),
	"temperature_apply_probability": temperature_proba_SL.value,
	"seed" : -1,
	"chords": progression,

	"weights": {

		"parallel_fifths_penalty": parallel_Fifths_penalty_SL.value * -1.0,
		"parallel_octaves_penalty": parallel_octave_penalty_SL.value * -1.0,
		"leap_penalty_SL": leap_penalty_SL.value * -1.0,
		"total movement factor": total_movement_factor_SL.value * -1.0,
		"voicing repetition penalty_SL": voicing_repetition_penalty_SL.value * -1.0,
		
		"common_note_bonus": common_note_bonus_SL.value,
		"contrary_motion_bonus": contrary_motion_bonus_SL.value,
		"leading_tone_resolution_bonus": Leading_tone_resolution_bonus_SL.value,
		"conjunct_motion_bonus": total_movement_factor_SL.value,
		"bass_conjunct_bonus": bass_conjunct_bonus_SL.value,  
		"soprano_conjunct_bonus": soprano_conjunct_bonus_SL.value,
		
	},
	"anti_bach": false,
	"allow_voicing_repetition":  (allow_repetition_cb.pressed == true)
}

	

	clear_console()
	LogBus.info(TAG,"Computing SATB transitions\n")
	LogBus.info(TAG,"Waiting for SATB solutions...\n")
	
	#LogBus.info(TAG,"temperature: "+str(temperature_SL.value))
	#LogBus.info(TAG,"temperature_apply_probability: "+str(temperature_proba_SL.value))
	#for k in request_data["weights"].keys():
	#	LogBus.info(TAG,k +": "+ str(request_data["weights"][k]))
	
	myMasterSong.satb_request_data = request_data
	satb_client.call_api("/solve-satb-transitions", request_data, {"method":"solve-satb-transitions"})
	#LogBus.info(TAG,"SATB request sent..." )
	
	# on masque le bouton
	compute_satb_btn.hide()



# recupère Tous les SATB de degrés de la progression en cours
func _on_debug_SATB_pressed():
	clear_console()
	
	if is_displaying_SATB:
		LogBus.info(TAG,"you must be in Edit mode to compute positions !")
	
	if songTrackView == null :
		return
	var wrappers = songTrackView.get_wrappers()
	if wrappers.size() == 0 :
		LogBus.info(TAG,"you must generate a progression before !")
		return
	


	
	var progression:Array = []
	for w in wrappers:
		var request:Dictionary = {}
		
		request["index"] = w.get_meta("index")
		request["pos"] = w.get_meta("start")
		var d:Degree = w.get_meta("degree")
		request["length_beats"] = d.length_beats
		request["key_midi_root"] = d.key.root_midi % 12
		request["key_scale_name"] = d.key.get_scale_name()
		var short_scale_array = []
		var long_scale_array = d.key.get_scale_array()
		#************************************************
		request["key_alterations"] = d._get_alterations()
		#************************************************
		# bug harmonicKey -> key.get_scale_array fait 8 notes (et pas 7)
		for i in range(0,7):
			short_scale_array.append(long_scale_array[i])
		request["scale_array"] = short_scale_array
		request["degree_number"] = d.degree_number
		request["kind"] = d.kind
		request["chord_notes"] = d.get_chord_midi()
		if free_inversion_cb.pressed == false and d.inversion != -1:
			request["inversion"] = d.inversion
		request["center_target"] = int(center_target_SL.value)
		request["best_distance"] = int(best_distance_SL.value)
		request["distance_scoring_factor"] = -1 * distance_scoring_SL.value
		request["center_scoring_factor"] = -1 * center_scoring_SL.value
		

		progression.append(request)




	# Solve progression renvoie les positions SATB  des degrés de la progressin en cours
	clear_console()
	satb_client.call_api("/solve-progression", progression, {"method":"solve-progression"})
	LogBus.info(TAG,"SATB positions request sent...\n" )
	LogBus.info(TAG, "request[center_target] = " + str(center_target_SL.value))
	LogBus.info(TAG, "request[best_distance] = " + str(best_distance_SL.value))	



func _on_web_api_mode_checkButton_toggled(button_pressed):
	#clear_console()
	pass

	if button_pressed:
		if OS.get_name() == "HTML5":
			LogBus.info(TAG,"mode HTML5")
			base_url = "https://www.theparselmouth.com/musiclab/api/"
		else :
			LogBus.info(TAG,"API Editor mode local")
			base_url = "http://127.0.0.1:8000"

	else :
		if OS.get_name() == "HTML5":
			LogBus.info(TAG,"mode HTML5")
			base_url = "https://www.theparselmouth.com/musiclab/api/"
		else :
			LogBus.info(TAG,"API Editor mode WEB")
			base_url = "https://www.theparselmouth.com/musiclab/api/"	


	satb_client.api_url  = base_url	
	#satb_client.api_url = "https://www.theparselmouth.com/musiclab/api/"	
	LogBus.info(TAG,"SATB Solver set to "+ satb_client.api_url )
	LogBus.info(TAG,"Testing connection..." )
	satb_client.test_connection()


func _on_SATBClient_api_response(response:Dictionary, context:Dictionary):

	if context.has("test"):
		#retour test
		if context["test"] == true :
			LogBus.info(TAG,"Connection to "+satb_client.api_url + " Successful !")
			LogBus.info(TAG,"SATB Server Version: " + response["version"])
			#LogBus.info(TAG,str(response))
			
			#LogBus.info(TAG,"\nClick Generate to create a chord progression...\n")
			#LogBus.info(TAG,"context "+ str(context))
			
		else:
			LogBus.info(TAG,"connection to "+satb_client.api_url + " failed...")

	# SATB TRANSITIONS		
	elif context.has("method") and context["method"] =="solve-satb-transitions":
		_on_export_console_btn_pressed()
		store_SATBS(response)
		
		
	# STAB POSITIONS -> TOUS LES SATB DE LA PROGRESSION pour chaque Degré de la progression
	elif context.has("method") and context["method"] == "solve-progression" :
		


		LogBus.info(TAG,"\nSATB positions reveived.")
		LogBus.info(TAG,"Right click on chords to sweep positions...")
		_process_debug_SATB(response,context)
	else :
		LogBus.error(TAG,"_on_SATBClient_api_response: response: " + str(response))
		LogBus.error(TAG,"context: " + str(context))

func _on_SATBClient_api_error(_error_code, _context):
	#LogBus.error(TAG,"_on_SATBClient_api_response: error_code: " + str(error_code))
	#LogBus.error(TAG,"context: " + str(context))
	LogBus.info(TAG,"\nSATB engine reconnected to https://www.theparselmouth.com")
	base_url = "https://www.theparselmouth.com/musiclab/api/"
	satb_client.api_url  = base_url	
	satb_client.test_connection()
	
	

func _process_debug_SATB(response,_context):
	var wrappers = songTrackView.get_wrappers()
	var r = response
	var satb_arrays = r["satb_arrays"]
	var nb_satb_arrays = satb_arrays.size()
	for i in range(0,nb_satb_arrays):
		
		var d:Degree = wrappers[i].get_meta("degree")		
		
		var satb_objects_array = satb_arrays[i]["satb_objects"]

		
		d.satb_dictionary = satb_arrays[i]
		d.satb_objects = satb_objects_array
		d.satb_index = 0
	

	

func _on_Edit_Progression_Btn_pressed():
	
	
	clear_console()
	LogBus.info(TAG,"Edit mode")
	midi_player.stop()
	playStopBtn.text = "Play"
	
	# on detruit les pistes SATB
	myMasterSong.remove_track_by_name(Song.SATB_TRACK_NAME)
	myMasterSong.remove_track_by_name(Song.SATB_SOPRANO)
	myMasterSong.remove_track_by_name(Song.SATB_ALTO)	
	myMasterSong.remove_track_by_name(Song.SATB_TENOR)
	myMasterSong.remove_track_by_name(Song.SATB_BASS)
	myMasterSong.satb_solutions_array = []
	myMasterSong.satb_solutions_index = 0
	
	myPlayingSong = Song.new()
	myPlayingSong.tempo_bpm = myMasterSong.tempo_bpm
	myPlayingSong.time_num = myMasterSong.time_num
	myPlayingSong.time_den = myMasterSong.time_den
	
	myPlayingSong.add_track(myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME))
	songTrackView.song = myPlayingSong
	songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
	songTrackView._update_all()
	midi_player.load_from_bytes(myPlayingSong.get_midi_bytes_type1())
	compute_satb_btn.text = "Compute SATB"
	#satb_solution_selector_knob.hide()
	satb_solution_Slider.hide()
	is_displaying_SATB = false
	is_computing_satb = false
	songTrackView_view_display_mode_option.show()
	generate_btn.show()
	edit_progression_btn.hide()
	menu_btn.hide()
	rewind()# Replace with function body.

	


func _on_compute_SATB_pressed():
	clear_console()
	if songTrackView.get_wrappers().size() == 0:
		LogBus.info(TAG,"Cannot compute SATB transitions, the chord progression is empty.")
		return
	center_tab_container.set_current_tab(0)
	$SongViewContainer/computing_label/AnimationPlayer.play("anim")
	midi_player.stop()
	playStopBtn.text = "Play"
	compute_satb_btn.hide()
	compute_satb_btn.hide()
	edit_progression_btn.hide()
	generate_btn.hide()
	playStopBtn.hide()
	rewindBtn.hide()
	export_midi_btn.hide()
	songTrackView.hide()
	_ask_progression_satbs()
	is_computing_satb = true
	
func display_SATB(satb_index:int):
	$SongViewContainer/computing_label/AnimationPlayer.stop()
	clear_console()
	

	
	is_displaying_SATB = true
	is_computing_satb = false
	LogBus.info(TAG,"SATB solution: "+str(satb_index + 1) + " / "+ str(satb_solutions_array.size()))
	
	if satb_solutions_array.size() == 0:
		LogBus.error(TAG, "You must compute SATB Before !")
		return
		

	
	var mySatbTrack:Track = Track.new()
	mySatbTrack.name = Song.SATB_TRACK_NAME
	var mySopranoTrack:Track = Track.new()
	mySopranoTrack.name = Song.SATB_SOPRANO
	var myAltoTrack:Track = Track.new()
	myAltoTrack.name = Song.SATB_ALTO
	var myTenorTrack:Track = Track.new()
	myTenorTrack.name = Song.SATB_TENOR
	var myBassTrack:Track = Track.new()
	myBassTrack.name = Song.SATB_BASS

	var check_SATB_array = []
	
	
	var satb_line = satb_solutions_array[satb_index]
	var best_progression = satb_line["best_progression"]
	#for chords in r["best_progression"]:
	for chords in best_progression:
		#var index:int = chords["index"]
		var pos:float = chords["pos"]
		var length_beats:float = chords["length_beats"]
		#var inversion:int = chords["inversion"]
		var satb_notes_midi = chords["satb_notes_midi"]
		#var score:int = chords["score"]
		#var tension:float = chords["tension"]
	

		# on contruit les notes
		var S_note:Note = Note.new()
		var A_note:Note = Note.new()
		var T_note:Note = Note.new()
		var B_note:Note = Note.new()

		var SATB_Notes:Array = [S_note,A_note,T_note,B_note]

		for n in SATB_Notes:
			n.length_beats = length_beats

		S_note.midi = satb_notes_midi[0]
		A_note.midi = satb_notes_midi[1]
		T_note.midi = satb_notes_midi[2]
		B_note.midi = satb_notes_midi[3]

		mySatbTrack.add_note(pos, S_note)
		mySatbTrack.add_note(pos, A_note)
		mySatbTrack.add_note(pos, T_note)
		mySatbTrack.add_note(pos, B_note)	

		mySopranoTrack.add_note(pos, S_note)
		myAltoTrack.add_note(pos, A_note)
		myTenorTrack.add_note(pos, T_note)
		myBassTrack.add_note(pos, B_note)

		check_SATB_array.append(satb_notes_midi)


	var total_score = satb_line["total_score"]
	var violations_count:int = satb_line["violations_count"]
	var voice_leading_score:int = satb_line["voice_leading_score"]
	var total_movement:int = satb_line["total_movement"]
	#var total_movement:int = r["total_movement"]
	var report = satb_line["report"]
	
	LogBus.info(TAG,"\nTotal Score: " + str(total_score))
	LogBus.info(TAG,"violations_count : " + str(violations_count))
	LogBus.info(TAG,"voice_leading_score: " + str(voice_leading_score))	
	LogBus.info(TAG,"total_movement: " + str(total_movement))
	if report.size() > 0:
		for str_report in report: 
			LogBus.info(TAG,"report: " + str_report + "\n")	

	# check parallel
	var PC = ParallelChecker.new()
	var result = PC.analyze_progression(check_SATB_array)
	#LogBus.info(TAG,"analyze_progression: "+str(result))
	if result["total_parallel_fifths"] > 0:
		LogBus.info(TAG,"WARNING: total_parallel_fifths: " + str(result["total_parallel_fifths"]))
	if result["total_parallel_octaves"] > 0:	
		LogBus.info(TAG,"total_parallel_octaves: " + str(result["total_parallel_octaves"]))
	if result["total_parallel_octaves"] == 0 and result["total_parallel_octaves"] == 0:
		LogBus.info(TAG,"No parallel fifth, no parallel octave detected.")
	
	
	myMasterSong.remove_track_by_name(Song.SATB_TRACK_NAME)
	myMasterSong.remove_track_by_name(Song.SATB_SOPRANO)
	myMasterSong.remove_track_by_name(Song.SATB_ALTO)
	myMasterSong.remove_track_by_name(Song.SATB_TENOR)
	myMasterSong.remove_track_by_name(Song.SATB_BASS)
	
	
	myMasterSong.add_track(mySatbTrack)
	myMasterSong.add_track(mySopranoTrack)
	myMasterSong.add_track(myAltoTrack)
	myMasterSong.add_track(myTenorTrack)
	myMasterSong.add_track(myBassTrack)

	
	
	MusicLabGlobals.set_song(myMasterSong)
	#MusicLabGlobals.print_globals()
	
	myPlayingSong = Song.new()
	myPlayingSong.title = myMasterSong.title
	myPlayingSong.time_den = myMasterSong.time_den
	myPlayingSong.time_num = myMasterSong.time_num
	myPlayingSong.tempo_bpm = myMasterSong.tempo_bpm
	
	var myPlayingTrack = myMasterSong.get_track_by_name(Song.SATB_TRACK_NAME).clone()
	var midiCC_reverb:MidiCC= MidiCC.new()
	midiCC_reverb.set_controller(91)
	midiCC_reverb.set_value(15)
	myPlayingTrack.add_midiCC(0,midiCC_reverb)
	myPlayingSong.add_track(myPlayingTrack)
	songTrackView.song = myPlayingSong
	songTrackView.trackName = Song.SATB_TRACK_NAME
	songTrackView._update_all()


	#save_midi_file_from_bytes("legato_satb",legatoMidiBytes)
	
	#midi_player.load_from_bytes(legatoMidiBytes)

	#midi_player.load_from_bytes(myPlayingSong.get_midi_bytes_type1())
	
	
	#satb_solution_selector_knob.show()
	satb_solution_Slider.show()
	edit_progression_btn.show()
	compute_satb_btn.show()
	playStopBtn.show()
	rewindBtn.hide()
	menu_btn.show()
	export_midi_btn.show()
	songTrackView.show()
	rewind()	
	
func store_SATBS(r):

	
	var number_of_solutions:int = r["solutions"].size()
	LogBus.info(TAG,"Number of SATB solutions: "+ str(number_of_solutions))
	if number_of_solutions > 0 :

#		satb_solution_selector_knob.max_value = number_of_solutions
#		satb_solution_selector_knob.min_value = 1
#		satb_solution_selector_knob.value = 0
		
		satb_solution_Slider.max_value = number_of_solutions
		satb_solution_Slider.min_value = 1
		satb_solution_Slider.value = 1

	else:
		LogBus.error(TAG, "SATB number_of_solutions = 0 !")
		return
	
	
	#on vide le tableau des solutions
	satb_solutions_array = []
	
	#Et on le remplit:
	for solution in r["solutions"]:
		satb_solutions_array.append(solution)
	
	# on stocke dans MusicLabGlobals
	myMasterSong.satb_solutions_array = satb_solutions_array
	myMasterSong.satb_solutions_index = 0
	MusicLabGlobals.set_song(myMasterSong)
	MusicLabGlobals.print_globals()
	display_SATB(0)
#
#


##################################################################################################
##################################################################################################
##################################################################################################



#func _on_satb_solution_selector_knob_value_changed(value):
#	if satb_solution_selector_knob != null:
#		myMasterSong.satb_solutions_index = value
#		display_SATB(satb_solution_selector_knob.get_value()-1)
#
#


func _on_SATB_request_value_changed(_value):
	rewind()
	clear_console()
	LogBus.info(TAG,"SATB Scoring parameters\n")
	LogBus.info(TAG,"parallel fifths penalty: " + str(-1 * parallel_Fifths_penalty_SL.value) )
	LogBus.info(TAG,"parallel octave penalty: " + str(-1 * parallel_octave_penalty_SL.value))
	LogBus.info(TAG,"total movement factor: " + str(-1 * total_movement_factor_SL.value))
	LogBus.info(TAG,"leap_penalty: " + str(-1 * leap_penalty_SL.value))
	LogBus.info(TAG,"voicing_repetition_penalty: " + str(-1 * voicing_repetition_penalty_SL.value))
	LogBus.info(TAG,"common note bonus: " + str(common_note_bonus_SL.value))
	LogBus.info(TAG,"contrary motion bonus: " + str(contrary_motion_bonus_SL.value))
	LogBus.info(TAG,"leading tone resolution bonus: " + str(Leading_tone_resolution_bonus_SL.value))
	LogBus.info(TAG,"conjunct motion bonus: " + str(conjunct_motion_bonus_SL.value))
	LogBus.info(TAG,"bass conjunct bonus: " + str(bass_conjunct_bonus_SL.value))
	LogBus.info(TAG,"soprano conjunct bonus: " + str(soprano_conjunct_bonus_SL.value))
	




func _on_SATB_Position_tab_value_changed(_value):
	rewind()
	clear_console()
	LogBus.info(TAG,"SATB Global Settings:\n")
	LogBus.info(TAG,"Temperature: " + str(temperature_SL.value))
	LogBus.info(TAG,"Factor: " + str(temperature_proba_SL.value))
	LogBus.info(TAG,"center target: " + str(center_target_SL.value))
	LogBus.info(TAG,"center scoring: " + str(center_scoring_SL.value))
	LogBus.info(TAG,"Best_distance: " + str(best_distance_SL.value))
	LogBus.info(TAG,"distance scoring: " + str(distance_scoring_SL.value))



#
#static func save_midi_file_from_bytes(filename: String = "", bytes:PoolByteArray = []) -> bool:
#
#	# Gestion du nom du fichier
#	# si filename est "", on utilise Song.title
#	var path:String = ""
#
#	path = "user://"+filename+".mid"
#
#	#var bytes = bytes
#	var f = File.new()
#	var err = f.open(path, File.WRITE)
#	if err != OK:
#		push_error("Song.save_midi_type1: can't open " + path + " (err " + String(err) + ")")
#		return false
#	f.store_buffer(bytes)
#	f.close()
#	return true

func scale_preview_string(key:HarmonicKey) -> String:
	var d:Degree = Degree.new()
	d.key = key
	var preview_txt = "---------------------- Scale Degrees ----------------------\n"
	for i in range(0,7):
		d.degree_number = i + 1
		preview_txt +=  str(i+1) + ": " + d.triad_string_with_alter()  + "\n"	
	return preview_txt


func _on_menu_btn_pressed():
	
	# progression vide
	if myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME).get_degrees_array().size() == 0:
		MusicLabGlobals.set_song(MusicLabGlobals.get_init_song())
		get_tree().get_root().get_node("Main").change_scene_preloaded("menu")
		return
	# on nettoie satb_array
	var satb_array = myMasterSong.satb_solutions_array
	var saved_satb = satb_array[myMasterSong.satb_solutions_index]
	var One_satb_array:Array = [saved_satb.duplicate(true)]
	myMasterSong.satb_solutions_array = One_satb_array
	myMasterSong.satb_solutions_index = 0
	myMasterSong.title = $Song_panel/title_line_edit.text
	
	MusicLabGlobals.set_song(myMasterSong)
	MusicLabGlobals.save_current_song_autosave()
	midi_player.stop()
	get_tree().get_root().get_node("Main").change_scene_preloaded("menu")




func _on_debug_btn_pressed():
	
	var patternGen = GuitarPatternGenerator.new()
	var pat:Dictionary = patternGen.generate("bossa")
	LogBus.debug(TAG,"pattern: "+ JSON.print(pat,"\t"))
	
	


func _on_program_number_ob_program_changed(_program):
	if midi_player :
		midi_player.stop()
		rewind()
		clear_console()
		var program_name = $program_number/program_number_ob.get_program_name()
		LogBus.info(TAG,"Sound set to "+program_name)



func _on_legato_midi_file_cb_toggled(_button_pressed):
	if midi_player:
		rewind()



func _on_capture_seed_Click_button_pressed():
	var new_seed = rng.randi()
	$Song_panel/seed_sb.value = new_seed
	LogBus.info(TAG,"New random seed set to " + str(new_seed))
	
func display_harmonic_function(d):
	var label = $harmonic_function_label
	
	if (d is Degree == false):
		label.text = ""
		return
	
	match d.harmonic_function :
		"T":label.text = "Tonic"
		"PD":label.text = "Predominant"
		"D":label.text = "Dominant"
		_:label.text = "?"
		
func no_chords():
	compute_satb_btn.hide()
	var txt = "Click Generate ([Command][G]) or [Command][->] to create chords..."
	LogBus.info(TAG,txt)
	display_harmonic_function(null)

func replace_progression_track_with_track(new_track:Track):
			var selected_indexes= []
			for w in songTrackView._wrappers:
				if w.get_meta("selected") == true:
					selected_indexes.append(w.get_meta("index"))
					
			new_track.name = Song.PROGRESSION_TRACK_NAME
			#update_songTrackView_withSelection()
			myMasterSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
			myMasterSong.add_track(new_track)
			myPlayingSong.remove_track_by_name(Song.PROGRESSION_TRACK_NAME)
			myPlayingSong.add_track(new_track)
			songTrackView.song = myPlayingSong
			songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
			var wrappers = songTrackView._wrappers
			for idx in selected_indexes:
				songTrackView.select_wrapper(wrappers[idx])
			#songTrackView.update_ui()


func _on_guitar_robot_pressed():
	# progression vide
	if myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME).get_degrees_array().size() == 0:
		MusicLabGlobals.set_song(MusicLabGlobals.get_init_song())
		get_tree().get_root().get_node("Main").change_scene_preloaded("menu")
		return
	# on nettoie satb_array
	var satb_array = myMasterSong.satb_solutions_array
	var saved_satb = satb_array[myMasterSong.satb_solutions_index]
	var One_satb_array:Array = [saved_satb.duplicate(true)]
	myMasterSong.satb_solutions_array = One_satb_array
	myMasterSong.satb_solutions_index = 0
	myMasterSong.title = $Song_panel/title_line_edit.text
	
	MusicLabGlobals.set_song(myMasterSong)
	MusicLabGlobals.save_current_song_autosave()
	midi_player.stop()
	get_tree().get_root().get_node("Main").change_scene_preloaded("guitar_player_scene")

