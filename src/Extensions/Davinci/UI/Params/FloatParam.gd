extends HBoxContainer

onready var label: Label = $Label
onready var spinbox: SpinBox = $SpinBox

var param := ""
var value := 0.0
var root : ConfirmationDialog = null

func _ready() -> void:
	label.text = param.capitalize()
	spinbox.value = value

func _on_spinbox_value_changed(new_value: float) -> void:
	root.param_value_changed(param, new_value)
