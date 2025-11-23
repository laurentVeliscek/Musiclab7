extends Control

const mySoundFontPath = "res://soundfonts/Aspirin-Stereo.sf2"
onready var midi_player:MidiPlayer

var myCurrent_song:Song = Song.new()

onready var songTrackView:SongTrackView = $SongViewContainer/SongTrackView
var rng = RandomNumberGenerator.new()

func _ready():
	#connection à la console 
	LogBus.connect("log_entry", self, "_on_log_entry")
	LogBus._verbose = true
	
	#test TPFTables
	var tp = $tpfl
	print("TPFTables: " + str(tp))
	tp._load_all()
	
	musiclibMidiPlayer.setupMidiPlayer()
	midi_player = musiclibMidiPlayer.midiPlayer
	run()
	
func _on_log_entry(entry):
	#entry = {time_str, msec, level, tag, message}
	var level = entry["level"]
	var tag = entry["tag"]
	var message = entry["message"]
	$logBusConsole_rtl.text += level + "|"  + tag + "|" + message + "\n"

func run():
	var k:HarmonicKey = HarmonicKey.new()
	k.set_from_string("C harmonic_minor")
	
	var tr:Track = Track.new()
	tr.name = "test track"
	
	# generation des degres

	var d:= Degree.new()
	d.key = k
	d.degree_number = 1
	d.length_beats = 2
	d.set_aug6_It()
	
	LogBus.info("Debug",d.to_string())
	d.set_aug6_Fr()
	LogBus.info("Debug",d.to_string())
	d.set_aug6_Ger()
	LogBus.info("Debug",d.to_string())
	tr.add_degree(0,d,true,true)
	
	

	
	#t.save_midi_type0()
	
	var mySong:Song = Song.new()
	randomize()
	
	

	var my_random_number = rng.randi_range(1, 10000000)
	mySong.title = $titleGenerator.generate_title(my_random_number)
	LogBus.info("Debug","Title generated -> " + mySong.title)
	mySong.add_track(tr)
	myCurrent_song = mySong
	myCurrent_song.save_midi_type1()
	songTrackView.set_song(myCurrent_song)

#


func _on_trackDisplayMode_item_selected(index):
	if index == 0 :
		songTrackView.set_degree_display("midi")
	elif index == 1 :
		songTrackView.set_degree_display("jazzchord")
	elif index == 2 :
		songTrackView.set_degree_display("roman")
	elif index == 3 :
		songTrackView.set_degree_display("keyboard")
	songTrackView.update()


func _on_trackViewScale_sl_value_changed(value):
	songTrackView.set_scale(value)
