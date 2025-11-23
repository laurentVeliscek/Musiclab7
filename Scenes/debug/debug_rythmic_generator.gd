# test_rhythmic_generator.gd
extends Node


onready var midi_player:MidiPlayer
onready var frame_size_sl = $Dashboard/manettes/frame_size/HBoxContainer/frame_size_sl
onready var n_notes_sl = $Dashboard/manettes/n_notes/HBoxContainer/n_notes_sl
onready var density_sl = $Dashboard/manettes/density/HBoxContainer/density_sl
onready var syncopation_sl = $Dashboard/manettes/syncopation/HBoxContainer/syncopation_sl
onready var triple_feel_sl = $Dashboard/manettes/triple_feel/HBoxContainer/triple_feel_sl
onready var repetition_sl = $Dashboard/manettes/repetition/HBoxContainer/repetition_sl
onready var ending_strength_bonus_sl = $Dashboard/manettes/ending_strength_bonus/HBoxContainer/ending_strength_bonus_sl

onready var seed_sl = $Dashboard/manettes/seed/HBoxContainer/seed_sl
onready var position_sl = $Dashboard/manettes/position/HBoxContainer/position_sl
onready var console = $console_rtl
onready var generate_btn = $generate_btn


onready var songTrackView:SongTrackView = $SongViewContainer/SongTrackView
onready var playStopBtn:Button = $playStop_btn

onready var rewindBtn:Button = $rewind_btn
onready var playHead:ColorRect = $SongViewContainer/play_head_cr


var myMasterSong:Song = Song.new()
var myPlayingSong:Song = Song.new()

var song_playing_ended:bool = true
var posInTicks :int = 0
var started_playing_pos = 0
var marker_starting_pos_in_ticks:int = -1
var anim_songTrack_view = false

var TAG = "debug rhythmic generator"

func _ready():
	
	
	LogBus.connect("log_entry", self, "_on_log_entry")
	LogBus._verbose = true
	
	# midi_player
	musiclibMidiPlayer.setupMidiPlayer()
	midi_player = musiclibMidiPlayer.midiPlayer
	


func compute_motif():	
	#print("=== Test Générateur de Motifs Rythmiques ===\n")
	clear_console()
	var generator = RhythmicMotifGenerator.new()
	
	# Test 1 : Motif simple
	#print("--- Test 1 : Motif simple ---")
	var params1 = {
		"frame_size": frame_size_sl.value,
		"n_notes": n_notes_sl.value,
		"density": density_sl.value,
		"density_tolerance": 0.1,
		"syncopation": syncopation_sl.value,
		"triplet_feel": triple_feel_sl.value,
		"repetition_factor": repetition_sl.value,
		"ending_strength_bonus": ending_strength_bonus_sl.value, 
		
		"position": position_sl.value ,
		"seed": seed_sl.value
	}
	
	LogBus.debug(TAG,str(params1))
	
	var motif = generator.generate_motif(params1)
	_print_motif(motif, "Motif")
	
	
	# on crée la song
	myPlayingSong = Song.new()
	
	#click_track
	var myClick_Track:Track = Track.new()
	var nb_temps = int(frame_size_sl.value)
	for i in range(0,nb_temps):
		var n:Note = Note.new()
		n.length_beats = 1
		n.midi = 60
		n.velocity = 60
		myClick_Track.add_note(i,n)
	
	var myRythmTrack:Track = Track.new()
	myRythmTrack.name = "rythm"
	
	for i in range(motif.size()):
		var note_motif = motif[i]
		var note: Note = Note.new()
		note.length_beats = note_motif["length_beats"]
		note.midi = 72+i
		myRythmTrack.add_note( note_motif["start"],note)
	
	
	myClick_Track.merge_track(myClick_Track,myClick_Track.length_beats,true)
	myClick_Track.merge_track(myClick_Track,myClick_Track.length_beats,true)
	
	myRythmTrack.merge_track(myRythmTrack,frame_size_sl.value,true)
	myRythmTrack.merge_track(myRythmTrack,2 * frame_size_sl.value,true)
	myPlayingSong.add_track(myRythmTrack)
	myPlayingSong.add_track(myClick_Track)
	
	
	songTrackView.song = myPlayingSong
	songTrackView.name = "rythm"
	songTrackView.update()
	
	midi_player.stop()
	var bytes = myPlayingSong.get_midi_bytes_type1()
	midi_player.load_from_bytes(bytes)
	#midi_player.play()
	
	

func _print_motif(motif: Array, title: String) -> void:

	LogBus.info(TAG,title + ": " + "  Nombre de notes: " + str(motif.size()))
	
	var total_duration = 0.0
#	for note in motif:
#		total_duration += note["length_beats"]
#	print("  Durée totale: ", stepify(total_duration, 0.01), " beats")
#
#	print("  Détail:")
	for i in range(motif.size()):
		var note = motif[i]
		
		var txt_note = str(i+1)
		txt_note += " Start: " + str(note["start"])
		txt_note += " Dur: " + str(note["length_beats"])
		txt_note += " Brick: " + str(note["brick_id"])
		txt_note += " Strength: " + str(note["beat_strength"])
#		print("    Note ", i + 1, ": start=", stepify(note["start"], 0.01), 
#			" dur=", stepify(note["length_beats"], 0.01), 
#			" brick=", note["brick_id"])
		LogBus.info(TAG,txt_note)

func _process(_delta):
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

func rewind() :
	marker_starting_pos_in_ticks = -1
	midi_player.stop()
	playStopBtn.text = "Play"
	songTrackView.scroll_to_pos(0,.5)
	songTrackView.update_ui()
	rewindBtn.hide()

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


func _on_generate_btn_pressed():
	compute_motif()



func _on_playStop_btn_pressed():
	
	song_playing_ended = false
	rewindBtn.show()
	if midi_player.playing :
		song_playing_ended = true
		midi_player.stop()
		playStopBtn.text = "Play"
	else :
		started_playing_pos = songTrackView._playing_pos_ticks
		midi_player.stop()
		var bytes = myPlayingSong.get_midi_bytes_type1()
		midi_player.load_from_bytes(bytes)
		if marker_starting_pos_in_ticks > -1 :
			posInTicks = marker_starting_pos_in_ticks
		else:
			posInTicks = 960 * (songTrackView.get_scroll_beats() * 60 /  myPlayingSong.tempo_bpm)
		anim_songTrack_view = true
		playStopBtn.text = "Stop"
		midi_player.play(posInTicks)	
		
func _on_trackViewScale_sl_value_changed(value):
	songTrackView.set_scale(value)


func _on_rewind_btn_pressed():
	rewind()
