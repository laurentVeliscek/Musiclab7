extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(Color) var baseColor = Color(1, 0, 0, 1)
# Called when the node enters the scene tree for the first time.
func _ready():
	var array_notes = []
	for i in range(0,10):
		var n:Note = Note.new()
		n.length_beats = 2
		n.midi = 30 + i*4
		var v = n.get_midi_view(2,baseColor)
		$ColorRect.add_child(v)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
