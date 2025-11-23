extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var fade = FadeUtils.new()

func _ready():
	add_child(fade) # utile si pas en autoload
	$pony.modulate.a = 0
	$musiclab.modulate.a = 0
	$GuitarRobot.modulate.a = 0
	$SatbFractalizerMenu.modulate.a = 0
	
	if MusicLabGlobals.get_song() == null:
		$ColorRect/VBoxContainer/SATB_fractalizer_btn.hide()
	else:
		if  MusicLabGlobals.get_song().get_track_by_name(Song.SATB_TRACK_NAME) == null :
			$ColorRect/VBoxContainer/SATB_fractalizer_btn.hide()
	
		
	var myMasterSong:Song = MusicLabGlobals.get_song()
#	if myMasterSong == null :
#		var satb_track = myMasterSong.
#		if satb_track == null:
			
		
func _on_progression_editor_btn_mouse_entered():
	fade.fade_in($musiclab,.5)

func _on_bass_catcher_btn_mouse_entered():
	fade.fade_in($pony,.5)

func _on_progression_editor_btn_mouse_exited():
	fade.fade_out($musiclab,.5)

func _on_bass_catcher_btn_mouse_exited():
	fade.fade_out($pony,.5)


func _on_guitar_player_btn_mouse_entered():
	fade.fade_in($GuitarRobot,.5)

func _on_guitar_player_btn_mouse_exited():
	fade.fade_out($GuitarRobot,.5)


func _on_SATB_fractalizer_btn_mouse_entered():
	fade.fade_in($SatbFractalizerMenu,.5)


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
