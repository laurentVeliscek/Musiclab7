tool
extends Panel

# BOUTON AVEC AFFICHAGE NUMERIQUE
# accès par get_value() et set_value()

class_name Numeric_Knob

const TAG = "Numeric_Knob"

signal value_changed(value)	# émis à chaque modif

export var title:String = ""


export  var value:float = 50 setget set_value, get_value
export  var max_value:float =100 setget set_max_value, get_max_value
export  var min_value:float  = 0 setget set_min_value, get_min_value
export  var decimal_pad:int = 0


export(String, MULTILINE) var tooltip:String = ""
export(DynamicFontData) var title_font_data 
export(int, 8, 256) var title_font_size = 18 
export(Color) var title_font_color = Color(.5, .5, .5, 1)

export(DynamicFontData) var value_font_data 
export(int, 8, 256) var value_font_size = 30 
export(Color) var value_font_color = Color(.5, .5, .5, 1)
export var alpha_dim = .8

export(Color) var panel_bg_color = Color(1, 1,1, 1)
export(Color) var panel_border_color = Color(.5, .5,.5, 1)
export(int) var panel_border_width = 0
export(int) var panel_border_radius = 4
export(bool) var hide_panel_on_mouse_exit =  true

var sb:StyleBox = StyleBoxFlat.new()
var sb_exit:StyleBox = StyleBoxFlat.new()

onready var knob = $Knob

func set_max_value(v):
	max_value = v
	_update()

func get_max_value() -> float:
	return max_value


func set_min_value(v):
	min_value = v
	_update()
		
func get_min_value() -> float:
	return min_value


	
func _update():
	if knob:
		print("_update")
		var delta:float = max_value - min_value
		var displayed_value:float  = ((1 - knob.value) * delta) + min_value
		var pw = pow(10,decimal_pad)
		displayed_value = int(displayed_value * pw) / pw
		$value_label.text = str(displayed_value)
	
	

# Called when the node enters the scene tree for the first time.
func _ready():
	#$Panel.add_color_override()
	knob.rect_size = self.rect_size
	knob.modulate.a = 0
	knob.value = value
	#set_value(init_value)
	
	$title_label.text = title
	$title_label.font_data = title_font_data
	$title_label.font_size = title_font_size
	$title_label.font_color = title_font_color
	
	$value_label.font_data = value_font_data
	$value_label.font_size = value_font_size
	$value_label.font_color = value_font_color
	$value_label.modulate.a = 1
	
	knob.hint_tooltip = tooltip
	$value_label.rect_size = rect_size
	$title_label.rect_size.x = 3 * rect_size.x
	$title_label.rect_position.x = -1 * rect_size.x
	
	
	sb.bg_color = panel_bg_color
	sb.border_color = panel_border_color
	sb.border_width_bottom = panel_border_width
	sb.border_width_top = panel_border_width
	sb.border_width_right = panel_border_width
	sb.border_width_left = panel_border_width
	sb.corner_radius_bottom_left = panel_border_radius
	sb.corner_radius_bottom_right = panel_border_radius
	sb.corner_radius_top_left = panel_border_radius
	sb.corner_radius_top_right = panel_border_radius
	
	sb_exit.bg_color = panel_bg_color
	sb_exit.border_color = panel_border_color
	sb_exit.border_width_bottom = panel_border_width
	sb_exit.border_width_top = panel_border_width
	sb_exit.border_width_right = panel_border_width
	sb_exit.border_width_left = panel_border_width
	sb_exit.corner_radius_bottom_left = panel_border_radius
	sb_exit.corner_radius_bottom_right = panel_border_radius
	sb_exit.corner_radius_top_left = panel_border_radius
	sb_exit.corner_radius_top_right = panel_border_radius
	
	if hide_panel_on_mouse_exit :
		sb_exit.border_width_bottom = 0
		sb_exit.border_width_top = 0
		sb_exit.border_width_right = 0
		sb_exit.border_width_left = 0
	

	
	
	self.add_stylebox_override("panel",sb_exit)	
	
func set_value(v):
	if knob :
		var delta:float = max_value - min_value
		if delta == 0:
			LogBus.error(TAG,"min_value = max-value !")
			return
		print("set_value: " + str(1 - ((v - min_value) / delta)))
		var k_value = 1 - ((v - min_value) / delta)
		knob.value = k_value
	
	
func get_value()-> float:
	var delta:float = max_value - min_value
	if delta == 0:
		LogBus.error(TAG,"min_value = max-value !")
		return max_value
	else:
		if  knob.value != null :
			return ((1 - knob.value) * delta) + min_value
		else :
			return value



func _on_Knob_mouse_entered():
	#$title_label.modulate.a = 2
	$value_label.modulate.a = 1
	self.add_stylebox_override("panel",sb)	

func _on_Knob_mouse_exited():
	$title_label.modulate.a = alpha_dim
	$value_label.modulate.a = alpha_dim
	self.add_stylebox_override("panel",sb_exit)	

func _on_Knob_value_changed(v):
	#$AnimatedSprite.set_frame(50 - $Knob.value/2)
	print("_on_Knob_value_changed:  "+ str(v))
	var delta = max_value - min_value
	var displayed_value:float  = ((1 - knob.value) * delta) + min_value
	var pw = pow(10,decimal_pad)
	displayed_value = int(displayed_value * pw) / pw
	$value_label.text = str(displayed_value)
	emit_signal("value_changed",displayed_value)

#
#func set_min_max_step_values(_min, _max, _step,_val):
#
#	max_value - _max
#	$Knob.min_value = max_value - _min
#	$Knob.step = _step
#	$Knob.value = max_value - _val
#	LogBus.debug(TAG,"knob min / max: " + str($Knob.min_value) + " / " + str($Knob.max_value) )
