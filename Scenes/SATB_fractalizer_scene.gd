extends Control

const TAG = "SATB_Fractalizer_Scene"


var myMasterSong:Song
var myPlayingSong:Song
var midi_player

onready var console = $Console_Node/Console
onready var songTrackView:SongTrackView = $SongViewContainer/SongTrackView
#onready var songTrackView_scale_option = $SongViewContainer/trackViewScale_sl
onready var window_length = $params/Window_length
onready var voice_pattern = $params/voice_pattern
onready var Triolet = $params/Triolet
onready var strategy = $params/strategy
onready var minimum_duration = $params/minimum_duration

onready var playStopBtn:Button = $Transport/playStop_btn
onready var menu_btn:Button = $Transport/menu_btn
#onready var rewindBtn:Button = $Transport/rewind_btn
onready var playHead:ColorRect = $SongViewContainer/play_head_cr

onready var export_midi_btn:Button = $Transport/Export_midi_btn

onready var fractalize = $Commands/fractalize_btn

var song_playing_ended:bool = true
var posInTicks :int = 0
var started_playing_pos = 0
var marker_starting_pos_in_ticks:int = -1
var anim_songTrack_view = false

var results_history_array = []


func _ready():
		
	myMasterSong = MusicLabGlobals.get_song()
		# Connection LogBus à la console 
	LogBus.connect("log_entry", self, "_on_log_entry")
	LogBus._verbose = true
	# midi_player
	MusicLabGlobals.setup_midi_player()
	midi_player= MusicLabGlobals.midi_player	
	

	myMasterSong = MusicLabGlobals.get_song()	
	songTrackView.set_song(myMasterSong)
	songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
	songTrackView.set_degree_display("roman")
	
	# je génére le chord array depuis la song courante
	var chords_array = setup_Source_SATB_to_chords_array()
	LogBus.debug(TAG,"----------- CHORDS ARRAY -------------")
	LogBus.debug(TAG,JSON.print(chords_array,"\t"))
	
	# le resultat source est stocké dans results_history_array
	var result_0:Dictionary = {"chords":chords_array, "params":{}}
	results_history_array.append(result_0)
	

	var fractal_track =	result_to_track(result_0)
	fractal_track.name = Song.FRACTAL_TRACK
	# on l'ajoute à myMasterSong
	myMasterSong.add_track(fractal_track)
	
	# Fractal track de myMasterSong est la seule piste de myPlayingSong 
	# C'est elle qu'on écoutera
	myPlayingSong = Song.new()
	myPlayingSong.add_track(myMasterSong.get_track_by_name(Song.FRACTAL_TRACK))

	return


# Convert chords from result to a a Track of notes
func result_to_track(r:Dictionary)->Track:
	var track:Track = Track.new()
	track.name = Song.FRACTAL_TRACK
	for c in r["chords"]:
		var pos = float(c["pos"])
		var length_beats = float(c["length_beats"])
		var notes = []
		notes.append(c["Soprano"])
		notes.append(c["Alto"])
		notes.append(c["Tenor"])
		notes.append(c["Bass"])
		
		for n in notes:
			var note:Note = Note.new()
			note.length_beats = length_beats
			note.midi = n
			track.add_note(pos,note)
		#LogBus.debug(TAG,track.to_string())
	return track




func setup_Source_SATB_to_chords_array()-> Array:
	
	var song = MusicLabGlobals.get_song()
	
	var request_array = song.get_satb_request_data()
	var satb_array = song.get_satb()
	
	var req_chords = request_array["chords"]
	var satb_chords = satb_array["best_progression"]
	#LogBus.debug(TAG,"nb Request Chords: " + str(req_chords.size()))
	#LogBus.debug(TAG,"nb satb Chords: " + str(satb_chords.size()))
	
	var chords = []
	for i in range (0,satb_chords.size()):
		var satb = {}
		satb["index"] = i
		satb["pos"] = satb_chords[i]["pos"]
		satb["length_beats"] = satb_chords[i]["length_beats"]
		satb["key_midi_root"] = req_chords[i]["key_midi_root"]
		satb["scale_array"] = req_chords[i]["scale_array"]
		satb["key_alterations"] = req_chords[i]["key_alterations"]
		satb["key_scale_name"] = req_chords[i]["key_scale_name"]
		satb["kind"] = req_chords[i]["kind"]
		satb["Soprano"] = satb_chords[i]["satb_notes_midi"][0]
		satb["Alto"] = satb_chords[i]["satb_notes_midi"][1]
		satb["Tenor"] = satb_chords[i]["satb_notes_midi"][2]
		satb["Bass"] = satb_chords[i]["satb_notes_midi"][3]
		
#		satb["degree_number"] = req_chords[i]["degree_number"]
#		satb["inversion"] = req_chords[i]["inversion"]
#		satb["satb_chord_degrees"] = satb_chords[i]["satb_chord_degrees"]
#		satb["satb_key_degrees"] = satb_chords[i]["satb_key_degrees"]
		chords.append(satb)
	return chords
		




func _process(_delta):
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
func rewind() :
	songTrackView.trackName = Song.PROGRESSION_TRACK_NAME

	songTrackView.set_degree_display("roman")	
	songTrackView._update_all()
	marker_starting_pos_in_ticks = -1
	midi_player.stop()
	playStopBtn.text = "Play"
	songTrackView.scroll_to_pos(0,.5)
	songTrackView.update_ui()
	#rewindBtn.hide()



#
		
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


func _on_SongTrackView_element_clicked(element, index, wrapper):
	$Commands/selection_label.update_text()





func _on_menu_btn_pressed():
	#MusicLabGlobals.set_song(myMasterSong)
	#MusicLabGlobals.save_current_song_autosave()
	midi_player.stop()
	get_tree().get_root().get_node("Main").change_scene_preloaded("menu")


func _on_playStop_btn_pressed():

	song_playing_ended = false
	#rewindBtn.show()
	if midi_player.playing :
		rewind()
		#stop !

		#stop !
		song_playing_ended = true
		midi_player.stop()
		playStopBtn.text = "Play"
	else :
		# play !
		started_playing_pos = songTrackView._playing_pos_ticks
		midi_player.stop()
		var bytes = myPlayingSong.get_midi_bytes_type1()
		midi_player.load_from_bytes(bytes)
		if marker_starting_pos_in_ticks > -1 :
			posInTicks = marker_starting_pos_in_ticks
		else:
			posInTicks = 480 * (songTrackView.get_scroll_beats())
		#songTrackView.song = myPlayingSong
		songTrackView.trackName = Song.FRACTAL_TRACK
		songTrackView._update_all()
		anim_songTrack_view = true
		playStopBtn.text = "Stop"
		midi_player.play(posInTicks)	
		


func _on_rewind_btn_pressed():
	rewind()

#func save_midi_bytes_to_midi_file(bytes: PoolByteArray,filename:String)->String:
func _on_Export_midi_btn_pressed():
	var bytes = myPlayingSong.get_midi_bytes_type1()
	MusicLabGlobals.save_midi_bytes_to_midi_file(bytes,myMasterSong.title+"[fractal]")

