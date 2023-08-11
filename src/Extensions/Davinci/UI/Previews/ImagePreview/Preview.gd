extends VBoxContainer

onready var camera: Camera2D = $HBoxContainer/MarginContainer/ViewportContainer/Viewport/Camera
onready var zoom_label: Label = $HBoxContainer/MarginContainer/Control/ZoomLabel
onready var transparent_checker: ColorRect = $HBoxContainer/MarginContainer/ViewportContainer/Viewport/TransparentChecker

var max_zoom := 5.0
var min_zoom := 0.1

func _on_ZoomSlider_value_changed(value: float) -> void:
	var percent = value / max_zoom * 100.0
	zoom_label.text = str(percent) + "% zoomed out"
	
	camera.zoom = Vector2(value, value)


func _on_viewport_container_gui_input_event(event: InputEvent) -> void:
	print(event)


# Can change when the preview texture changes
func _on_ImagePreview_item_rect_changed() -> void:
	transparent_checker.update_rect()
	transparent_checker.rect_position = -transparent_checker.rect_size / 2
