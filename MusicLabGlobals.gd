extends Node
#class_name MusicLabGlobals

const AUTOSAVE_SONG_PATH = "user://autosave.mlab"
const DEFAULT_DOCUMENTS_SUBDIR := "MusicLab"
const SONG_EXTENSION := ".mlab"
const MIDI_EXTENSION := ".mid"
const TEXT_EXTENSION := ".txt"
const LAST_SONG_DIR_KEY := "last_song_dir"
const LAST_MIDI_DIR_KEY := "last_midi_dir"
const LAST_TEXT_DIR_KEY := "last_text_dir"
const GLOBALS_SAVE_PATH := "user://musiclab_globals.json"

# -------------------------------------------------------------------
#	GLOBAL STATE SINGLETON POUR MUSICLIB
# -------------------------------------------------------------------

# Objet Song courant (peut être assigné dynamiquement)
var current_song = Song.new()
var rng = RandomNumberGenerator.new()
# Paramètres utilisateur (persistants si possible)
var user_settings = {}

# Mode debug global
var debug_mode = false

var TAG = "MusicLabGlobals"
var GuitarBase = GuitarChordDatabase.new()
var modulationDatabase 


var midi_player
# -------------------------------------------------------------------
#	INITIALISATION
# -------------------------------------------------------------------

func _ready():
	LogBus.info(TAG,"[MusicLabGlobals] Initialisé")
	_load_globals()
	GuitarBase.load_from_json("res://addons/musiclib/guitar/guitar.json")
	modulationDatabase = ModulationDatabase.new()
	modulationDatabase.load_database()
	
	current_song = load_autosaved_song()
	rng.randomize()
#	print("current_song -> " + str(current_song))
#
#	if current_song == null :
#		current_song = Song.new()
#		current_song.title =  "Empty song"
#		var progression_track : Track = Track.new()
#		progression_track.name =  Song.PROGRESSION_TRACK_NAME
#		var degres = [1,4,2,5]
#		for i in range(0,degres.size()):
#			var d:Degree = Degree.new()
#			d.degree_number = degres[i]
#			d.length_beats = 2
#			progression_track.add_degree(i*2,d)
#			current_song.add_track(progression_track)
		



# -------------------------------------------------------------------
#	SONG MANAGEMENT
# -------------------------------------------------------------------

func setup_midi_player():
	musiclibMidiPlayer.setupMidiPlayer()
	midi_player = musiclibMidiPlayer.midiPlayer

func set_song(song):
	if song == null:
		pass
		#LogBus.info(TAG,"[MusicLabGlobals] set_song(null) !")
	else:
		pass
		#LogBus.info(TAG,"[MusicLabGlobals] set_song() -> " + str(song))
	current_song = song


func get_song():
	return current_song


func clear_song():
	#LogBus.info(TAG,"[MusicLabGlobals] clear_song()")
	current_song = null

# -------------------------------------------------------------------
#	SONG PERSISTENCE (JSON dans user://)
# -------------------------------------------------------------------

func save_current_song_autosave() -> bool:
	# Sauvegarde la Song courante dans AUTOSAVE_SONG_PATH
	return save_current_song_to_file(AUTOSAVE_SONG_PATH)


func load_autosaved_song() -> Song:
	# Charge la Song depuis AUTOSAVE_SONG_PATH (si le fichier existe)
	return load_song_from_file(AUTOSAVE_SONG_PATH)

func save_current_song_to_file(path:String, compressed:bool = false) -> bool:
	if current_song == null or not (current_song is Song):
		LogBus.error(TAG, "save_current_song_to_file(): no current_song to save")
		return false

	var data:Dictionary = current_song.to_dict()
	var f := File.new()
	var err = OK

	var base_dir := path.get_base_dir()
	if base_dir != "":
		_ensure_directory(base_dir)

	if compressed:
		err = f.open_compressed(path, File.WRITE, File.COMPRESSION_DEFLATE)
	else:
		err = f.open(path, File.WRITE)

	if err != OK:
		LogBus.error(TAG, "save_current_song_to_file(): can't open " + path + " (err " + str(err) + ")")
		return false

	if compressed:
		# On stocke directement le Dictionary (var) compressé
		f.store_var(data, true)
	else:
		# Ancien format lisible en JSON
		var json:String = JSON.print(data, "	")
		f.store_string(json)

	f.close()
	#LogBus.info(TAG, "Song saved to " + path + " (compressed=" + str(compressed) + ")")
	return true
	
	
func save_text_html5(text:String, filename:String = "export.txt") -> void:
        # Garde-fou : nom par défaut
        var fname:String = filename
        if fname == "":
                fname = "export" + TEXT_EXTENSION

        if not fname.ends_with(TEXT_EXTENSION):
                fname += TEXT_EXTENSION
	
	# Si on est en HTML5 + JavaScript dispo : vrai download navigateur
        if OS.has_feature("HTML5") and Engine.has_singleton("JavaScript"):
                var b64:String = Marshalls.utf8_to_base64(text)
                var url:String = "data:text/plain;base64," + b64
		
		# Attention : ici on suppose un filename sans quotes ni caractères bizarres
		var js:String = ""
		js += "var a=document.createElement('a');"
		js += "a.href='" + url + "';"
		js += "a.download='" + fname + "';"
		js += "document.body.appendChild(a);"
		js += "a.click();"
		js += "document.body.removeChild(a);"
		
		JavaScript.eval(js, true)
		LogBus.info(TAG, "download_text_html5(): HTML5 download triggered (" + fname + ")")
	
        else:
                # Fallback hors HTML5 : on enregistre dans le dossier utilisateur
                var path:String = get_text_export_path(fname)
                var ok:bool = save_text_to_file(path, text)
                if ok:
                        _remember_dir(LAST_TEXT_DIR_KEY, path)
                        LogBus.info(TAG, "download_text_html5(): not HTML5, saved to " + path + " instead")
                else:
                        LogBus.error(TAG, "download_text_html5(): fallback save failed")

