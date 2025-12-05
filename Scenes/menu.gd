extends Control

const TAG = "Menu"
onready var fade = FadeUtils.new()
onready var console = $console
onready var myMasterSong:Song
onready var import_dialog = $ImportSongDialog
onready var save_dialog = $SaveSongDialog
onready var song_title = ""

func _ready():
	MusicLabGlobals.connect("browser_song_loaded", self, "_on_song_loaded")
	MusicLabGlobals.connect("browser_song_load_failed", self, "_on_song_failed")

	import_dialog.mode = FileDialog.MODE_OPEN_FILE
	import_dialog.access = FileDialog.ACCESS_FILESYSTEM
	import_dialog.clear_filters()
	import_dialog.add_filter("*.mlab ; MusicLab Song")
	if not import_dialog.is_connected("file_selected", self, "_on_ImportSongDialog_file_selected"):
			import_dialog.connect("file_selected", self, "_on_ImportSongDialog_file_selected")

	save_dialog.mode = FileDialog.MODE_SAVE_FILE
	save_dialog.access = FileDialog.ACCESS_FILESYSTEM
	save_dialog.clear_filters()
	save_dialog.add_filter("*.mlab ; MusicLab Song")
	if not save_dialog.is_connected("file_selected", self, "_on_SaveSongDialog_file_selected"):
			save_dialog.connect("file_selected", self, "_on_SaveSongDialog_file_selected")

	var song_dir = MusicLabGlobals.get_song_directory()
	import_dialog.current_dir = song_dir
	save_dialog.current_dir = song_dir

	MusicLabGlobals.setup_midi_player()

	# Connection LogBus à la console
	LogBus.connect("log_entry", self, "_on_log_entry")
	LogBus._verbose = true
	
	add_child(fade) # utile si pas en autoload
	$pony.modulate.a = 0
	$musiclab.modulate.a = 0
	$GuitarRobot.modulate.a = 0
	$SatbFractalizerMenu.modulate.a = 0
	

	clear_console()
	myMasterSong = MusicLabGlobals.get_song()
	if myMasterSong == null:
		myMasterSong = Song.new()
	
	var prog_track = myMasterSong.get_track_by_name(Song.PROGRESSION_TRACK_NAME)
	if prog_track != null and prog_track.get_degrees_array().size() > 0:
		$ColorRect/VBoxContainer/guitar_player_btn.show()
	else :
		$ColorRect/VBoxContainer/guitar_player_btn.hide()
	
	$ColorRect/VBoxContainer/SATB_fractalizer_btn.hide()
	
	if myMasterSong.get_track_by_name(Song.SATB_TRACK_NAME) == null :	
		$ColorRect/VBoxContainer/guitar_player_btn.hide()
		
	
	song_title = myMasterSong.title
	if song_title == "Untitled Song":
		$ColorRect/VBoxContainer/progression_editor_btn.text = "Create Song"
		$file_panel/file_container/new_song.hide()
		$file_panel/file_container/save_song_btn.hide()
		LogBus.info(TAG,"Welcome to MusicLab©")
		
	else:
		LogBus.info(TAG,"Current song:\n" + myMasterSong.title)
			
func clear_console():
	console.text = ""
		
func _on_progression_editor_btn_mouse_entered():
	fade.fade_in($musiclab,.5)
	clear_console()
	if song_title == "Untitled Song":
		LogBus.info(TAG,"Create a new song\nGroovy !...")
	else:	
		LogBus.info(TAG,"Edit your song: \n"+ song_title + "\nGroovy !...")

func _on_bass_catcher_btn_mouse_entered():
	fade.fade_in($pony,.5)
	clear_console()
	LogBus.info(TAG,"Ear training quizz:\nfind the bass note of a chord.\nFunky !")


func _on_progression_editor_btn_mouse_exited():
	fade.fade_out($musiclab,.5)

func _on_bass_catcher_btn_mouse_exited():
	fade.fade_out($pony,.5)


func _on_guitar_player_btn_mouse_entered():
	fade.fade_in($GuitarRobot,.5)
	clear_console()
	LogBus.info(TAG,"Robot guitar player.\nTasty !...")

func _on_guitar_player_btn_mouse_exited():
	fade.fade_out($GuitarRobot,.5)


func _on_SATB_fractalizer_btn_mouse_entered():
	fade.fade_in($SatbFractalizerMenu,.5)
	clear_console()
	LogBus.info(TAG,"Revolutionary Non Chord\nTones generator\nSexy !")

func _on_SATB_fractalizer_btn_mouse_exited():
	fade.fade_out($SatbFractalizerMenu,.5)
	

func _on_bass_catcher_btn_pressed():
	get_tree().get_root().get_node("Main").change_scene_preloaded("bass_catcher")


func _on_progression_editor_btn_pressed():
	get_tree().get_root().get_node("Main").change_scene_preloaded("progression_editor")

func _on_guitar_player_btn_pressed():
	get_tree().get_root().get_node("Main").change_scene_preloaded("guitar_player_scene")


func _on_SATB_fractalizer_btn_pressed():
	get_tree().get_root().get_node("Main").change_scene_preloaded("SATB_fractalizer")

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




func _on_load_song_btn_mouse_entered():
	clear_console()
	LogBus.info(TAG,"Load a Song...\n")




func _on_save_song_btn_mouse_entered():
	clear_console()
	LogBus.info(TAG,"Save your song:\n" + myMasterSong.title)


func _on_new_song_mouse_entered():
	clear_console()
	LogBus.info(TAG,"Reset the current song")


func _on_load_song_btn_pressed():
#	if OS.get_name() == "HTML5":
#		MusicLabGlobals.load_song_from_browser_picker()
#	else:
	import_dialog.current_dir = MusicLabGlobals.get_song_directory()
	import_dialog.popup_centered_ratio(0.8)
	#
	


func _on_ImportSongDialog_file_selected(path:String) -> void:
	
	clear_console()
	#LogBus.debug(TAG,"importing a song from path: "+ path)
	var song:Song = MusicLabGlobals.import_song_from_json_file(path)
	if song == null:
		clear_console()
		LogBus.info(TAG,"Not a valid Song file")
		return
	else :
		$ColorRect/VBoxContainer/progression_editor_btn.text = "Edit Song"
		$file_panel/file_container/new_song.show()
		$file_panel/file_container/save_song_btn.show()
		var prog_track = song.get_track_by_name(Song.PROGRESSION_TRACK_NAME)
		if prog_track.get_degrees_array().size() > 0:
			$ColorRect/VBoxContainer/guitar_player_btn.show()
		
		
		#LogBus.debug(TAG,"Valid Song File")
		MusicLabGlobals.set_song(song)
		myMasterSong = MusicLabGlobals.get_song()
		MusicLabGlobals.set_user_setting(MusicLabGlobals.LAST_SONG_DIR_KEY, path.get_base_dir())
	if myMasterSong == null:
		myMasterSong = MusicLabGlobals.get_init_song()
	
	song_title = myMasterSong.title
	
	if myMasterSong.get_track_by_name(Song.SATB_TRACK_NAME) == null :
		$ColorRect/VBoxContainer/SATB_fractalizer_btn.hide()
		
	if myMasterSong.title == "Untitled Song":
		$ColorRect/VBoxContainer/progression_editor_btn.text = "Create Song"
		$file_panel/file_container/new_song.hide()
		$file_panel/file_container/save_song_btn.hide()
		LogBus.info(TAG,"Welcome to MusicLab©")
	else:
		LogBus.clear_console()
		#LogBus.info(TAG,"Current song:\n" + myMasterSong.title)
	# Ici tu peux rafraîchir l’UI si nécessaire, par ex :
	# update_song_view(song)


func _on_save_song_btn_pressed():
	clear_console()
	var filename = myMasterSong.title + MusicLabGlobals.SONG_EXTENSION
	save_dialog.current_dir = MusicLabGlobals.get_song_directory()
	save_dialog.current_file = filename
	save_dialog.popup_centered_ratio(0.8)


func _on_SaveSongDialog_file_selected(path: String) -> void:
	clear_console()
	if not path.ends_with(MusicLabGlobals.SONG_EXTENSION):
		path += MusicLabGlobals.SONG_EXTENSION
	var success = MusicLabGlobals.save_current_song_to_file(path)
	if success:
		LogBus.info(TAG,"Song saved to " + path)
		MusicLabGlobals.set_user_setting(MusicLabGlobals.LAST_SONG_DIR_KEY, path.get_base_dir())
	else:
		LogBus.info(TAG,"Error: Song couldn't be saved")


func _on_new_song_pressed():
	MusicLabGlobals.clear_song()
	myMasterSong = MusicLabGlobals.get_song()
	if myMasterSong == null:
		myMasterSong = MusicLabGlobals.get_init_song()
		song_title = myMasterSong.title
	if myMasterSong.get_track_by_name(Song.SATB_TRACK_NAME) == null :
		$ColorRect/VBoxContainer/SATB_fractalizer_btn.hide()
		$ColorRect/VBoxContainer/guitar_player_btn.hide()
		$file_panel/file_container/new_song.hide()
		$file_panel/file_container/save_song_btn.hide()
		$ColorRect/VBoxContainer/progression_editor_btn.text = "Create Song"
	#LogBus.info(TAG,"Current song:\n" + myMasterSong.title)
	

func _on_song_loaded(song: Song) -> void:
	# La Song est chargée et déjà définie comme current_song
	print("Song chargée : %s" % song.title)

func _on_song_failed(message: String) -> void:
	print("Échec du chargement : %s" % message)
