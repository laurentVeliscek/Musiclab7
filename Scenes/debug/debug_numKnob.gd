extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(_delta):
	$process_monitor.text = str($numKnob.value)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_numKnob_value_changed(value):
	$monitor.text = "on_numKnob_value_changed(value): " + str(value)


func _on_VSlider_value_changed(value):
	$numKnob.value = value


func _on_set_min_value_changed(value):
	print("set_min: "+str(value))
	$min_lbl.text = str(value)
	$numKnob.min_value = value


func _on_set_max_value_changed(value):
	print("set_max: "+str(value))
	$max_lbl.text = str(value)
	$numKnob.max_value = value


	
