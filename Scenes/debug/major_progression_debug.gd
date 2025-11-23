extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var gen = MajorProgressionGenerator.new()
	var p = gen.generate_major_progression()
	print(str(p))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
