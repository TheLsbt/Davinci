extends MarginContainer

onready var camera: Camera2D = $ViewportContainer/Viewport/Camera
onready var zoom_label: Label = $Control/ZoomLabel
onready var transparent_checker: ColorRect = $ViewportContainer/Viewport/TransparentChecker
onready var viewport_container: ViewportContainer = $ViewportContainer


const max_zoom := Vector2(5.0, 5.0)
const min_zoom := Vector2(0.1, 0.1)

var mouse_pos := Vector2.ZERO
var dragging := false
var global : Node = null

func _ready() -> void:
	global = get_node("/root/Global")
	transparent_checker.call_deferred("update_rect")


func _on_viewport_container_gui_input_event(event: InputEvent) -> void:
	mouse_pos = viewport_container.get_local_mouse_position()
	
	if event.is_action_pressed("zoom_in", false, true):  # Wheel Up Event
		zoom_camera(-1)
	if event.is_action_pressed("zoom_out", false, true):  # Wheel Down Event
		zoom_camera(1)
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			dragging = event.is_pressed()
	elif event is InputEventMouseMotion:
		if dragging:
			camera.offset = camera.offset - event.relative.rotated(camera.rotation) * camera.zoom
			update_transparent_checker_offset()
	

func _on_reset_camera_offset_pressed() -> void:
	camera.offset = Vector2.ZERO
	update_transparent_checker_offset()


func update_transparent_checker_offset() -> void:
	var o := get_global_transform_with_canvas().get_origin()
	var s := get_global_transform_with_canvas().get_scale()
	o.y = get_viewport_rect().size.y - o.y
	transparent_checker.update_offset(o, s)
	


# Can change when the preview texture changes
func _about_to_show() -> void:
	transparent_checker.update_rect()
	transparent_checker.rect_position = -transparent_checker.rect_size / 2

# Zoom Camera
func zoom_camera(dir: int) -> void:
	var viewport_size := viewport_container.rect_size
	var prev_zoom := camera.zoom
	var zoom_margin := camera.zoom * dir / 10
	if global.integer_zoom:
		zoom_margin = (camera.zoom / (Vector2.ONE - dir * camera.zoom)) - camera.zoom
		if zoom_margin == Vector2.INF:
			return
	if camera.zoom + zoom_margin > min_zoom:
		camera.zoom += zoom_margin
	if camera.zoom > max_zoom:
		camera.zoom = max_zoom
	camera.offset = camera.offset + (-0.5 * viewport_size + mouse_pos).rotated(camera.rotation) * (prev_zoom - camera.zoom)
	zoom_changed()


func zoom_changed() -> void:
	update_transparent_checker_offset()
	
	var percent = camera.zoom / max_zoom * 100.0
	zoom_label.text = str(percent.x) + "% zoomed out"
	
