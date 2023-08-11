extends VBoxContainer

onready var zoom_slider: VSlider = $HBoxContainer/Zoom
onready var camera: Camera2D = $HBoxContainer/ViewportContainer/Viewport/Camera

func _on_zoom_slider_value_changed(new_zoom: float) -> void:
	camera.zoom = Vector2(new_zoom, new_zoom)
