# This scripts only purpose is to add syntax highlighting

extends TextEdit


func _ready() -> void:
	add_keyword_color("uniform", Color.lightcoral)
	add_keyword_color("bool", Color.lightcoral)
	add_keyword_color("float", Color.lightcoral)
	add_keyword_color("vec2", Color.lightcoral)
	add_keyword_color("vec3", Color.lightcoral)
	add_keyword_color("vec4", Color.lightcoral)
	
	add_color_region("//", "", Color.lightgray)
