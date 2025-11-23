extends Control

const mySoundFontPath = "res://soundfonts/Aspirin-Stereo.sf2"
onready var midi_player:MidiPlayer

const TAG = "[debug.gd]"
var myCurrent_song:Song = Song.new()



var _sig_to_ids = {}  # "K..|I..|T3..|T5..|T7.." -> Array d'ids
onready var vldb_reader = $vldb_reader

onready var songTrackView:SongTrackView = $SongViewContainer/SongTrackView



func run_test_vldb():
	vldb_reader.load_default()
	var src = vldb_reader.find_voicing(0, 0, 3, 4, 0, PoolIntArray([0,0,0]))	# triade maj inv0 rel 0
	print("src -> " + str(src))

	var edges = vldb_reader.get_edges(src, 7, 50)	# dt = 7 (quinte au-dessus), limite 50
	print("EDGES -> " + str(edges))

func _ready():
	#connection à la console 
	LogBus.connect("log_entry", self, "_on_log_entry")
	LogBus._verbose = true
	run_test_vldb()
	
	
	
	
	
	
	
	
	
	
	#connection à la console 
	LogBus.connect("log_entry", self, "_on_log_entry")
	LogBus._verbose = true

	musiclibMidiPlayer.setupMidiPlayer()
	midi_player = musiclibMidiPlayer.midiPlayer
	#run()
	
func _on_log_entry(entry):
	#entry = {time_str, msec, level, tag, message}
	var level = entry["level"]
	var tag = entry["tag"]
	var message = entry["message"]
	$logBusConsole_rtl.text += level + "|"  + tag + "|" + message + "\n"

func run():
	var k:HarmonicKey = HarmonicKey.new()
	k.set_from_string("C major")
	
	k.root_midi = 3
	LogBus.info(TAG,"new key with root= " + str(k.root_midi) + " -> " + k.to_string())
	
	#static func spelling_table_in_key(hk, locale: String = "en", use_unicode_accidentals: bool = false) -> Array:
	var arr = NoteParser.spelling_table_in_key(k)
	LogBus.debug(TAG,"NoteParser.spelling_table_in_key(k) -> " + str(arr))
	
	
	var tr:Track = Track.new()
	tr.name = "mixture track"
	
	# generation des degres
	
	var d:= Degree.new()
	d.key = k
	d.degree_number = 1
	d.length_beats = 2
	d.set_aug6_It()
	
	LogBus.info("Debug",d.to_string())
	tr.add_degree(0,d,true,true)
	
	

	
	#t.save_midi_type0()
	
	var mySong:Song = Song.new()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var mySeed = rng.randi()
	mySong.title = $titleGenerator.generate_title(mySeed)
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



	
	
