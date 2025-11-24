extends Control
class_name  WedgeKnob

signal value_changed(value)	# émis à chaque modif

export var title:String = ""
export var init_value = .5 
export(String, MULTILINE) var tooltip:String = ""
export(DynamicFontData) var font_data 
export(int, 8, 256) var font_size = 18 
export(Color) var font_color = Color(.5, .5, .5, 1)

var is_knob:bool = true

onready var value:float setget set_value,get_value
# Called when the node enters the scene tree for the first time.
func _ready():
	$Knob.modulate.a = 0
	set_value(init_value)
	$title_label.text = title
	$title_label.font_data = font_data
	$title_label.font_size = font_size
	$title_label.font_color = font_color
	$Knob.hint_tooltip = tooltip

func set_value(v):
	$Knob.value = (1-v) * 100
	
func get_value():
	return 1 - ($Knob.value / 100)

func _on_Knob_value_changed(value):
	$AnimatedSprite.set_frame(50 - $Knob.value/2)
	emit_signal("value_changed",0.01 * (100 - value))


