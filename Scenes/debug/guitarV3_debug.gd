extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#var guitarBase = MusicLabGlobals.GuitarBase
	var key = HarmonicKey.new()
	var d:Degree =  Degree.new()
	d.key = key
	d.realization = [1,3,5,7]
	var sh = ScaleHelper.new()
	
	var scales = sh.list_scales()
	print(str(scales))

	var nochord_degrees = []
	for root in range(0,12):
		print("root: " + str(root))
		#yield(VisualServer, 'frame_pre_draw')

		key.root_midi = 60+root
		for s in scales:
			key.scale_name = s 
			#print(key.to_string())
			#yield(VisualServer, 'frame_pre_draw')

			for d_number in range(1,8):
				d.degree_number = d_number
				var guitarchords = d.guitar_chords()
				
				if guitarchords == null or guitarchords.size() == 0:
					#yield(VisualServer, 'frame_pre_draw')
					nochord_degrees.append(d.clone())
					#print(d.to_string())
				
				
				
	print("nochord_degrees.size()" + str(nochord_degrees.size()))
	for deg in nochord_degrees:
		print(deg.to_string())
				
	 

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
