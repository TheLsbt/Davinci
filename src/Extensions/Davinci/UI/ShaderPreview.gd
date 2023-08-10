# This scripts only purpose is to add syntax highlighting

extends TextEdit

export var pixelorama_reserved_color : Color
export var davinci_override_color : Color


func _ready() -> void:
	add_keyword_color("uniform", Color.lightcoral)
	add_keyword_color("bool", Color.lightcoral)
	add_keyword_color("float", Color.lightcoral)
	add_keyword_color("vec2", Color.lightcoral)
	add_keyword_color("vec3", Color.lightcoral)
	add_keyword_color("vec4", Color.lightcoral)
	
	# Davinci customs
	add_color_region("--", "", davinci_override_color)
	
	add_color_region("//", "", Color(0.290083, 0.286224, 0.324219))
	
	# Pixelorama Reserved
	add_keyword_color("selection", pixelorama_reserved_color)
