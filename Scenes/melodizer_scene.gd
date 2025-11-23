extends Control

var TAG = "Melodyzer Scene"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var myMasterSong:Song = Song.new()

onready var melodyse_btn:Button = $melodyze_btn
onready var edit_progression_btn:Button = $edit_progression_btn
onready var console:RichTextLabel = $console_rtl


# Called when the node enters the scene tree for the first time.
func _ready():
	# Connection LogBus à la console 
	LogBus.connect("log_entry", self, "_on_log_entry")
	LogBus._verbose = true
		
func load_master_song():
	clear_console()
	myMasterSong = MusicLabGlobals.get_song()
	LogBus.info(TAG,"song loaded: " + myMasterSong.title)
	
	

#--------------------------------------------------------------------------------
# OUTILS
#--------------------------------------------------------------------------------

func _real_frames() -> Array:

	
	var prog_track:Track = myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME)
	var soprano_notes:Array = myMasterSong.get_track_by_name(Song.SATB_SOPRANO).get_notes_array()
	var alto_notes:Array = myMasterSong.get_track_by_name(Song.SATB_ALTO).get_notes_array()
	var tenor_notes:Array = myMasterSong.get_track_by_name(Song.SATB_TENOR).get_notes_array()
	var bass_notes:Array = myMasterSong.get_track_by_name(Song.SATB_BASS).get_notes_array()
	
	var events = prog_track.events
	var frames = []
	
	for i in range(0,events.size()):
		var event = events[i]
		var pos = event["start"]
		if event["degree"] == null:
			LogBus.error(TAG,'event["degree"] == null')
			return []
		var d:Degree = event["degree"]
		
		#LogBus.debug(TAG,"degree: " + d.to_string())
		LogBus.debug(TAG,"triade: " + d.triad_string_with_alter())
		var long_scale_array = d.key.get_scale_array()
		# bug harmonicKey -> key.get_scale_array fait 8 notes (et pas 7)
		var short_scale_array = []
		for j in range(0,7):
			short_scale_array.append(long_scale_array[j])
		#request["scale_array"] = short_scale_array
		LogBus.debug(TAG,"scale: " + str(short_scale_array))
		var midi_S = soprano_notes[i].midi
		var midi_A = alto_notes[i].midi
		var midi_T = tenor_notes[i].midi
		var midi_B = bass_notes[i].midi
		LogBus.debug(TAG,"S: " + str(midi_S))
		LogBus.debug(TAG,"A: " + str(midi_A))
		LogBus.debug(TAG,"T: " + str(midi_T))
		LogBus.debug(TAG,"B: " + str(midi_B))
		
		var hf = {
			"id": i,
			"time_in": pos,
			"time_out": pos + d.length_beats,
			"chord_context": {
				"symbol": d.triad_string_with_alter(),
				"degrees": d.realization,
				"available_tensions": [],
				"free_space": []
				},
			"scale_context": {
				"pitch_set": short_scale_array
			},
			"satb_snapshot": {
				"S": midi_S, "A": midi_A, "T": midi_T, "B": midi_B
			},
			"register_window": Vector2(60,80)
		}
		frames.append(hf)
		

		
	
	LogBus.debug(TAG,"frames: " + str(frames) )
	return frames

func _fake_frames() -> Array:
	var frames = []
	var chords = ["I", "V", "vi", "IV"]
	var base_time = 0.0
	var dur = 2.0

	var i = 0
	while i < chords.size():
		var hf = {
			"id": i,
			"time_in": base_time,
			"time_out": base_time + dur,
			"chord_context": {
				"symbol": chords[i],
				"degrees": [1,3,5],
				"available_tensions": [9],
				"free_space": [],
			},
			"scale_context": {
				"pitch_set": [0,2,4,5,7,9,11]
			},
			"satb_snapshot": {
				"S": 72, "A": 67, "T": 60, "B": 52
			},
			"register_window": Vector2(60,80)
		}
		frames.append(hf)
		base_time += dur
		i += 1
	return frames



const ContourGeneratorC		= preload("res://addons/musiclib/melodizer/ContourGenerator.gd")
const AnchorPlacerC			= preload("res://addons/musiclib/melodizer/AnchorPlacer.gd")
const SegmentBuilderC		= preload("res://addons/musiclib/melodizer/SegmentBuilder.gd")
const CandidatePoolBuilderC	= preload("res://addons/musiclib/melodizer/CandidatePoolBuilder.gd")
const CandidateFilterC		= preload("res://addons/musiclib/melodizer/CandidateFilter.gd")
const NoteChooserC			= preload("res://addons/musiclib/melodizer/NoteChooser.gd")
const MelodyAssemblerC		= preload("res://addons/musiclib/melodizer/MelodyAssembler.gd")
const PostprocessOrnamentsC	= preload("res://addons/musiclib/melodizer/PostprocessOrnaments.gd")

#--------------------------------------------------------------------------------
# SIMULATION DE TEST
#--------------------------------------------------------------------------------
func compute_melody() -> void:
	clear_console()
	print("\n=== TEST MELODIZER PIPELINE ===")

	# Simule 4 HarmonicFrames avec des durées simples
	var harmonic_frames = _real_frames()

	# Profil de style minimal
	var style_profile = {
		"target_density": 0.5,
		"climax_at": 0.6
	}

	# Étape 1 : registre global
	var contour_gen = ContourGeneratorC.new()
	var contour = contour_gen.generate_contour(harmonic_frames.size(), style_profile, Vector2(60,80), "arch")

	# Étape 2 : ancrages
	var placer = AnchorPlacerC.new()
	var anchors = placer.place_anchors(harmonic_frames, contour, style_profile)

	# Étape 3 : segments
	var seg_builder = SegmentBuilderC.new()
	var segments = seg_builder.build_segments(anchors, harmonic_frames, {})

	# Étape 4 : pools candidats
	var pool_builder = CandidatePoolBuilderC.new()
	for hf in harmonic_frames:
		hf.chord_context.free_space = pool_builder.build_pool_for_frame(hf)

	# Étape 5 : choix de notes par segment
	var note_chooser = NoteChooserC.new()
	var seg_results = []
	for seg in segments:
		var before = _frame_by_id(harmonic_frames, seg.start_anchor.frame_id)
		var after = _frame_by_id(harmonic_frames, seg.end_anchor.frame_id)
		var melody = note_chooser.choose_for_segment(seg, before, after, style_profile.target_density)
		seg_results.append(melody)

	# Étape 6 : assemblage
	var assembler = MelodyAssemblerC.new()
	var melody_full = assembler.assemble_melody(seg_results, harmonic_frames)

	print("\n--- Mélodie avant ornements ---")
	_print_melody(melody_full)
	LogBus.debug(TAG,"Mélodie avant ornements: " + str(melody_full))

	# Étape 7 : post-process (ornements)
	var post = PostprocessOrnamentsC.new()
	var melody_final = post.process(melody_full, harmonic_frames)

	print("\n--- Mélodie après ornements ---")
	_print_melody(melody_final)
	LogBus.debug(TAG,"Mélodie après ornements: " + str(melody_full))

	print("\n✅ Pipeline de test terminé.")
	LogBus.debug(TAG,"\n✅ Pipeline de test terminé.")
	var report_txt = "Frames:" +  str(harmonic_frames.size()) + "  Anchors:" +  str(anchors.size())
	report_txt += " Segments:" +  str(segments.size()) +  " Notes:"  + str(melody_final.size())
	LogBus.debug(TAG, report_txt)
	
	var track_melody:Track = Track.new()
	
	for note in melody_final:
		var pitch = int(note["pitch"])
		var tin = float(note["time_in"])
		var tout = float(note["time_out"])
		var dur = tout - tin
		var n:Note = Note.new()
		n.midi = pitch
		n.length_beats = dur
		track_melody.add_note(tin,n) 
	
	var playingSong:Song = Song.new()
	playingSong.add_track(myMasterSong.get_track_by_name(Song.SATB_TRACK_NAME))
	playingSong.add_track(track_melody)
	save_midi_file_from_bytes(myMasterSong.title + "_melody", playingSong.get_midi_bytes_type1())
	
	
func _frame_by_id(frames, fid):
	for f in frames:
		if f["id"] == fid:
			return f
	return null

func _print_melody(mel: Array) -> void:
	var i = 0
	while i < mel.size():
		var n = mel[i]
		var pitch = int(n["pitch"])
		var tin = float(n["time_in"])
		var tout = float(n["time_out"])
		var dur = tout - tin
		LogBus.debug(TAG, "  •" + str(pitch) +  " (" +  str(tin) +  "→" +  str(tout) +  ", dur:" +  str(dur) + ")")
		i += 1


func _on_melodyze_btn_pressed():
	compute_melody()

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

func clear_console():
	console.text = ""

#func _on_melodizer_btn_pressed():


func _on_edit_progression_btn_pressed():
	var main = get_parent().get_parent()
	main.display_progression_editor()


static func save_midi_file_from_bytes(filename: String = "", bytes:PoolByteArray = []) -> bool:
	
	# Gestion du nom du fichier
	# si filename est "", on utilise Song.title
	var path:String = ""

	path = "user://"+filename+".mid"
		
	#var bytes = bytes
	var f = File.new()
	var err = f.open(path, File.WRITE)
	if err != OK:
		push_error("Song.save_midi_type1: can't open " + path + " (err " + String(err) + ")")
		return false
	f.store_buffer(bytes)
	f.close()
	return true

func _save_text_to_disk(content: String, filename: String) -> void:
	# Écrit dans user:// (persistance locale; en HTML5 = IndexedDB)
	var path = "user://" + filename
	var f = File.new()
	var err = f.open(path, File.WRITE)
	if err == OK:
		f.store_string(content)
		f.close()


func _on_export_console_text_btn_pressed():
	_save_text_to_disk(console.text, "console.txt")
	LogBus.info(TAG,'Console.txt exported to "user://console.txt"')
