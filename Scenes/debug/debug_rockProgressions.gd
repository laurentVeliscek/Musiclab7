extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var RP:RockProgressionGenerator = RockProgressionGenerator.new()
	#func generate( key_root:int = -1,scale:String = "", chord_duration:float= 1.0,_seed:int = -1) -> Track:
	
	var track = RP.generate(-1,"",.5,-1)
	print(track.to_string())
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
