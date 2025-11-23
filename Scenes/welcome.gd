extends Control




#var melodyzer = preload("res://Scenes/melodizer.tscn").instance()



func _ready():
	pass




func _on_Enter_btn_pressed():
	get_tree().get_root().get_node("Main").change_scene_preloaded("menu")
	
