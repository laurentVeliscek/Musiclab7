extends Node
#class_name MusicLabGlobals

# -------------------------------------------------------------------
#	GLOBAL STATE SINGLETON POUR MUSICLIB
# -------------------------------------------------------------------

# Objet Song courant (peut être assigné dynamiquement)
var current_song = null
var rng = RandomNumberGenerator.new()
# Paramètres utilisateur (persistants si possible)
var user_settings = {}

# Mode debug global
var debug_mode = false

var TAG = "MusicLabGlobals"
var GuitarBase = GuitarChordDatabase.new()
var modulationDatabase 
# -------------------------------------------------------------------
#	INITIALISATION
# -------------------------------------------------------------------

func _ready():
	LogBus.info(TAG,"[MusicLabGlobals] Initialisé")
	_load_globals()
	GuitarBase.load_from_json("res://addons/musiclib/guitar/guitar.json")
	modulationDatabase = ModulationDatabase.new()
	modulationDatabase.load_database()


# -------------------------------------------------------------------
#	SONG MANAGEMENT
# -------------------------------------------------------------------

func set_song(song):
	if song == null:
		LogBus.info(TAG,"[MusicLabGlobals] set_song(null) !")
	else:
		LogBus.info(TAG,"[MusicLabGlobals] set_song() -> " + str(song))
	current_song = song


func get_song():
	return current_song


func clear_song():
	LogBus.info(TAG,"[MusicLabGlobals] clear_song()")
	current_song = null


# -------------------------------------------------------------------
#	DEBUG / INFO
# -------------------------------------------------------------------

func print_globals():
	LogBus.info(TAG,"---- MusicLabGlobals ----")
	LogBus.info(TAG,"debug_mode:" + str(debug_mode))
	LogBus.info(TAG,"user_settings: " + str(user_settings))
	if current_song != null and current_song is Song:
		LogBus.info(TAG,"current_song: " +  current_song.to_string())
	else:
		LogBus.info(TAG,"current_song: <none>")
	LogBus.info(TAG,"-------------------------")


# -------------------------------------------------------------------
#	USER SETTINGS (HTML5-SAFE)
# -------------------------------------------------------------------

func set_user_setting(key, value):
	if not user_settings.has(key):
		# print_verbose("[MusicLabGlobals] new setting '%s'" % key)
		LogBus.info(TAG, str(key) + " --> " + str(value))
	user_settings[key] = value
	_save_globals()


func get_user_setting(key, default_value = null):
	if user_settings.has(key):
		return user_settings[key]
	else:
		return default_value


func clear_user_settings():
	# print_verbose("[MusicLabGlobals] clear_user_settings()")
	LogBus.info(TAG, "MusicLabGlobals settings cleared")
	user_settings = {}
	_save_globals()


# -------------------------------------------------------------------
#	PERSISTENCE HTML5 (localStorage)
# -------------------------------------------------------------------

func _save_globals():
	if OS.has_feature("HTML5") and Engine.has_singleton("JavaScript"):
		var js = Engine.get_singleton("JavaScript")
		var json_data = to_json(user_settings)
		js.eval("localStorage.setItem('musiclab_globals', JSON.stringify(%s))" % json_data)
		#print_verbose("[MusicLabGlobals] Globals sauvegardés dans localStorage")
		LogBus.info(TAG,"MusicLab Globals saved in localStorage")
	else:
		#print_verbose("[MusicLabGlobals] Pas de support HTML5 → sauvegarde ignorée")
		LogBus.info(TAG,"no HTML5 -> cannot save MusicLab Globals ")


func _load_globals():
	if OS.has_feature("HTML5") and Engine.has_singleton("JavaScript"):
		var js = Engine.get_singleton("JavaScript")
		var data = js.eval("localStorage.getItem('musiclab_globals')")
		if data and typeof(data) == TYPE_STRING and data != "":
			var parsed = parse_json(data)
			if typeof(parsed) == TYPE_DICTIONARY:
				user_settings = parsed
				#print_verbose("[MusicLabGlobals] Globals rechargés depuis localStorage")
				LogBus.info(TAG,"MusicLab Globals loaded from localStorage")
				
			else:
				#print_verbose("[MusicLabGlobals] Erreur parse_json (data non-dict)")
				LogBus.error(TAG,"MusicLab Globals Error parse_json (data non-dict)")
		else:
			#print_verbose("[MusicLabGlobals] Aucune donnée locale à charger")
			LogBus.info(TAG,"MusicLab Globals no data to load")
	else:
		#print_verbose("[MusicLabGlobals] Pas de support HTML5 → chargement ignoré")
		LogBus.info(TAG,"no HTML5 -> cannot load MusicLab Globals ")


# -------------------------------------------------------------------
#	RESET COMPLET
# -------------------------------------------------------------------

func reset_all():
	#print_verbose("[MusicLabGlobals] reset_all()")
	LogBus.info(TAG,"MusicLab Globals -> Reset all()")
	current_song = null
	user_settings = {}
	_save_globals()
