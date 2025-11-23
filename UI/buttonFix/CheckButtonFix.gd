extends CheckButton

func _ready():
	add_constant_override("hseparation", 10)
	var flat = StyleBoxFlat.new()
	flat.bg_color = Color(0, 0, 0, 0)
	flat.set_content_margin_all(0)
	add_stylebox_override("normal", flat)
	add_stylebox_override("hover", flat)
	add_stylebox_override("pressed", flat)
