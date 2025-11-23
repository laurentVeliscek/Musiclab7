extends Node

# --- Scène courante
var current_scene: Node = null

# --- Scènes préchargées
var preload_paths = {
	"welcome": "res://Scenes/welcome.tscn",
	"bass_catcher": "res://Scenes/bass_catcher.tscn",
	"progression_editor": "res://Scenes/progression_editor.tscn",
	"menu": "res://Scenes/menu.tscn",
	"guitar_player_scene": "res://Scenes/guitar_player_scene.tscn",
	"SATB_fractalizer":"res://Scenes/SATB_fractalizer_scene.tscn"
}

var preloaded_scenes = {} # Dictionnaire : clé -> PackedScene
var preload_done = false

# --- UI de fade / loading
onready var fade_rect = $FadeRect
onready var fade_tween = $FadeTween
onready var loading_label = $FadeRect/LoadingLabel

func _ready():
	print("Main prêt")
	yield(_fade_out(), "completed")
	yield(preload_all_scenes(), "completed")
	yield(_fade_in(), "completed")
	change_scene_preloaded("welcome")


# --------------------------------------------------
# --- Préchargement asynchrone
# --------------------------------------------------

func preload_all_scenes():
	print("Préchargement des scènes...")
	loading_label.visible = true
	for key in preload_paths.keys():
		var path = preload_paths[key]
		print("→", key, path)
		var loader = ResourceLoader.load_interactive(path)
		if not loader:
			push_error("Échec du loader pour " + path)
			continue

		while true:
			var err = loader.poll()
			if err == ERR_FILE_EOF:
				break
			elif err != OK:
				push_error("Erreur de chargement sur " + path)
				break
			yield(get_tree(), "idle_frame")

		var packed_scene = loader.get_resource()
		if packed_scene:
			preloaded_scenes[key] = packed_scene
			print("✅ Préchargé :", key)
		else:
			push_error("Erreur : " + path + " non chargé")

	preload_done = true
	#loading_label.visible = false
	print("✅ Toutes les scènes sont préchargées.")


# --------------------------------------------------
# --- Changement via scènes déjà préchargées
# --------------------------------------------------

func change_scene_preloaded(key: String):
	if not preloaded_scenes.has(key):
		push_error("Scène non préchargée : " + key)
		return

	yield(_fade_out(), "completed")

	if current_scene:
		current_scene.queue_free()
		current_scene = null
		yield(get_tree(), "idle_frame")

	var packed_scene = preloaded_scenes[key]
	current_scene = packed_scene.instance()
	add_child(current_scene)
	current_scene.owner = self

	yield(_fade_in(), "completed")
	_set_focus_to_scene(current_scene)
	print("✅ Scène affichée :", key)


# --------------------------------------------------
# --- Fondu
# --------------------------------------------------

func _fade_out():
	#loading_label.visible = true
	fade_tween.stop_all()
	fade_rect.raise()
	fade_tween.interpolate_property(
		fade_rect, "modulate:a",
		fade_rect.modulate.a, 1.0,
		0.4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	#loading_label.visible = false
	fade_tween.start()
	yield(fade_tween, "tween_all_completed")
	#loading_label.visible = true

func _fade_in():
	#loading_label.visible = false
	fade_tween.stop_all()
	fade_rect.raise()
	fade_tween.interpolate_property(
		fade_rect, "modulate:a",
		fade_rect.modulate.a, 0.0,
		0.4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	#loading_label.visible = false
	fade_tween.start()
	yield(fade_tween, "tween_all_completed")
	#loading_label.visible = false

# --------------------------------------------------
# --- Focus clavier
# --------------------------------------------------

func _set_focus_to_scene(scene: Node):
	if not scene:
		return
	var focusable = scene.find_node("focus_target", true, false)
	if focusable and focusable.has_method("grab_focus"):
		focusable.grab_focus()
