tool
extends Label
class_name LabelFontAA

# Réglages visibles dans l'inspecteur
export(int, 8, 256) var font_size = 18 setget _set_font_size
export(DynamicFontData) var font_data setget _set_font_data
export(bool) var use_filter = true setget _set_use_filter
export(bool) var use_mipmaps = true setget _set_use_mipmaps
export(int, 0, 2) var hinting = 1 setget _set_hinting	# 0=None, 1=Light, 2=Normal
export(Color) var font_color = Color(0, 0, 0, 1) setget _set_font_color

var _dyn_font: DynamicFont = null
var _dyn_data: DynamicFontData = null

func _ready() -> void:
	_apply_font()

func _set_font_size(v: int) -> void:
	font_size = v
	_apply_font()

func _set_font_data(v: DynamicFontData) -> void:
	font_data = v
	_apply_font()

func _set_use_filter(v: bool) -> void:
	use_filter = v
	_apply_font()

func _set_use_mipmaps(v: bool) -> void:
	use_mipmaps = v
	_apply_font()

func _set_hinting(v: int) -> void:
	hinting = v
	_apply_font()

func _set_font_color(c: Color) -> void:
	font_color = c
	add_color_override("font_color", font_color)
	update()

func _apply_font() -> void:
	if font_data == null:
		return

	# Duplique la ressource pour ne pas modifier l'originale
	_dyn_data = font_data.duplicate()
	_dyn_data.hinting = hinting

	if _dyn_font == null:
		_dyn_font = DynamicFont.new()

	_dyn_font.font_data = _dyn_data
	_dyn_font.size = font_size
	_dyn_font.use_filter = use_filter
	_dyn_font.use_mipmaps = use_mipmaps

	add_font_override("font", _dyn_font)
	add_color_override("font_color", font_color)

	minimum_size_changed()
	update()
