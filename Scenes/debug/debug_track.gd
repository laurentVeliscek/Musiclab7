extends Control

const TAG = "debug_track"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	LogBus.connect("log_entry", self, "_on_log_entry")
	LogBus._verbose = true
	
	var key:HarmonicKey = HarmonicKey.new()
	key.set_from_string("C major")
	
	var track:Track =  Track.new()
	var d1:Degree = Degree.new()
	d1.degree_number = 1
	d1.length_beats = 1
	d1.key = key
	
	var d2:Degree = d1.clone()
	d2.degree_number = 3
	var d3:Degree = d1.clone()
	d3.degree_number = 3
	
	var d4:Degree = d1.clone()
	d4.degree_number = 1
	
	track.add_degree(0,d1)
	track.add_degree(1,d2)
	track.add_degree(2,d3)
	track.add_degree(3,d4)

	#########
	var song:Song = Song.new()
	track.name = Song.PROGRESSION_TRACK_NAME
	song.add_track(track)
	
	var songMidiBytes = song.get_midi_bytes_type1()
	
	save_midi_file_from_bytes("no_legato", songMidiBytes)
	var MFT = MidiFileTools.new()
	var txt = MFT.analyse_midi_file(songMidiBytes)
	print(txt)
	
	print("-------- LEGATO SONG")	
	var legatoSongBytes = MFT.same_pitch_legato(songMidiBytes,1)
	txt = MFT.analyse_midi_file(legatoSongBytes)
	print(txt)
	save_midi_file_from_bytes("test_legato", legatoSongBytes)
	
	
		

func _on_log_entry(e):
	print(str(e))
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


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
