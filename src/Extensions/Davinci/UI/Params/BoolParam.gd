extends HBoxContainer

onready var label: Label = $Label
onready var check_box: CheckBox = $CheckBox

var param := ""
var value := false
var root : ConfirmationDialog = null

func _ready() -> void:
	label.text = param.capitalize()
	check_box.pressed = value

func _on_check_box_toggled(toggled: bool) -> void:
	root.param_value_changed(param, toggled)
