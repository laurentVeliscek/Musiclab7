extends Node
class_name FadeUtils

# Fondu d'apparition / disparition générique pour Sprite, Control, etc.
# Compatible Godot 3.x / HTML5
# Utilise Tween interne et ajuste la visibilité selon alpha.

export(float) var default_duration = 0.5

# -------------------------------------------------------------------
# Fait apparaître le node en fondu (alpha 0 → 1)
func fade_in(node: Node, duration: float = -1.0):
	if duration < 0:
		duration = default_duration
	_prepare_tween(node)
	var tween = node.get_meta("fade_tween")

	#node.show()
	node.modulate.a = 0.0

	tween.stop_all()
	tween.interpolate_property(
		node, "modulate:a",
		0.0, 1.0,
		duration,
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	tween.start()


# -------------------------------------------------------------------
# Fait disparaître le node en fondu (alpha 1 → 0)
func fade_out(node: Node, duration: float = -1.0):
	if duration < 0:
		duration = default_duration
	_prepare_tween(node)
	var tween = node.get_meta("fade_tween")

	tween.stop_all()
	tween.interpolate_property(
		node, "modulate:a",
		node.modulate.a, 0.0,
		duration,
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	tween.start()
	yield(tween, "tween_completed")
	#node.hide()


# -------------------------------------------------------------------
# Méthode interne : prépare le Tween (créé s’il n’existe pas déjà)
func _prepare_tween(node: Node):
	if not node.has_meta("fade_tween"):
		var t = Tween.new()
		node.add_child(t)
		node.set_meta("fade_tween", t)
	else:
		var t = node.get_meta("fade_tween")
		if t == null or not is_instance_valid(t):
			t = Tween.new()
			node.add_child(t)
			node.set_meta("fade_tween", t)
	
	var tween = node.get_meta("fade_tween")
	tween.stop_all()
