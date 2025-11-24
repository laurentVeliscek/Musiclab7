extends Control

const TAG = "SATB_Fractalizer_Scene"


var myMasterSong:Song
var myPlayingSong:Song

onready var console = $Console_Node/Console
onready var songTrackView:SongTrackView = $SongViewContainer/SongTrackView
onready var songTrackView_scale_option = $SongViewContainer/trackViewScale_sl


func _ready():
	myMasterSong = MusicLabGlobals.get_song()
		# Connection LogBus à la console 
	LogBus.connect("log_entry", self, "_on_log_entry")
	LogBus._verbose = true
	
	
	
	var myGlobalSong= MusicLabGlobals.get_song()
	#on initialise myMasterSong
	if  myGlobalSong != null and myGlobalSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME) != null:
		
		myMasterSong = MusicLabGlobals.get_song()
		myPlayingSong = Song.new()
		myPlayingSong.add_track(myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME))
		
	else :
		var my_empty_progression_track = Track.new()
		my_empty_progression_track.name = Song.PROGRESSION_TRACK_NAME
		myMasterSong = Song.new()
		myMasterSong.add_track(my_empty_progression_track)
	
	songTrackView.song = myMasterSong
	songTrackView.trackName = Song.PROGRESSION_TRACK_NAME
	songTrackView.set_degree_display("roman")
	
		
func setup_SATB():
	#JSON.print(d, "\t")
	var request_array = myMasterSong.get_satb_request_data()
	var satb_array = myMasterSong.get_satb()


	var req_chords = request_array["chords"]
	var satb_chords = satb_array["best_progression"]
	LogBus.debug(TAG,"nb Request Chords: " + str(req_chords.size()))
	LogBus.debug(TAG,"nb satb Chords: " + str(satb_chords.size()))
	
	var chords = []
	for i in range (0,satb_chords.size()):
		var satb = {}
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
		
		
		
	LogBus.debug(TAG,str(chords))	
	LogBus.debug(TAG,"********************************\n")
	LogBus.debug(TAG,"chords: ")
	LogBus.debug(TAG,JSON.print(chords,"\t"))	
		
		
		
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




func _on_fractalize_btn_pressed():
	var technique_weights:Dictionary = $techniques.technique_weights()
	LogBus.debug(TAG,str(technique_weights))
