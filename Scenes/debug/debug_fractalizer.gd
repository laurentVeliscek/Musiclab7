extends Control

const TAG = "debug"

onready var console = $console
# Called when the node enters the scene tree for the first time.
func _ready():
	LogBus.connect("log_entry", self, "_on_log_entry")
	LogBus._verbose = true
	LogBus.info(TAG,"\nTest Fractalizer\n")
	
	$test.run()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_log_entry(entry):
	#entry = {time_str, msec, level, tag, message}
	var level = entry["level"]
	var tag = entry["tag"]
	var message = entry["message"]
	
	if level == "INFO":
		#console.text += level + "|"  + tag + "|" + message + "\n"
		console.text +=  message + "\n"
	else :
		console.text += level + "|"  + tag + "|" + message + "\n"



func _on_export_console_btn_pressed():
	_save_text_to_disk(console.text, "console.txt")
	LogBus.info("ConsoleNode",'Console.txt exported to "user://console.txt"')



func _on_clear_console_btn_pressed():
	console.text = ""


func _save_text_to_disk(content: String, filename: String) -> void:
	# Écrit dans user:// (persistance locale; en HTML5 = IndexedDB)
	var path = "user://" + filename
	var f = File.new()
	var err = f.open(path, File.WRITE)
	if err == OK:
		f.store_string(content)
		f.close()
