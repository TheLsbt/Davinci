extends ColorRect


var global = null

func _ready() -> void:
	global = get_node("/root/Global")
	update_rect()


func update_rect() -> void:
	rect_size = global.current_project.size
	material.set_shader_param("size", global.checker_size)
	material.set_shader_param("color1", global.checker_color_1)
	material.set_shader_param("color2", global.checker_color_2)
	material.set_shader_param("follow_movement", global.checker_follow_movement)
	material.set_shader_param("follow_scale", global.checker_follow_scale)


func update_offset(offset: Vector2, scale: Vector2) -> void:
	material.set_shader_param("offset", offset)
	material.set_shader_param("scale", scale)


func _on_TransparentChecker_resized() -> void:
	material.set_shader_param("rect_size", rect_size)


#func fit_rect(rect: Rect2) -> void:
#	rect_position = rect.position
#	rect_size = rect.size


#func update_transparency(value: float) -> void:
#	# Change the transparency status of the parent viewport and the root viewport
#	if value == 1.0:
#		get_parent().transparent_bg = false
#		get_tree().get_root().transparent_bg = false
#	else:
#		get_parent().transparent_bg = true
#		get_tree().get_root().transparent_bg = true
#
#	# Set a minimum amount for the fade so the canvas won't disappear
#	material.set("shader_param/alpha", clamp(value, 0.1, 1))
