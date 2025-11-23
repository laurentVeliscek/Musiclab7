extends Resource
class_name Event

var time: float

func _init(time: float = 0.0):
	self.time = time

func _to_string():
	var s = "Event -> Time:"+str(time)
	return s

