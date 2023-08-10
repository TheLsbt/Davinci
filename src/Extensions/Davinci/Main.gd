extends Node

const DAVINCI_SCENE = preload("UI/Davinci.tscn")

var davinci = null
var global = null

var item_idx : int = -1

func _enter_tree() -> void:
	global = get_node("/root/Global")

	if global:
		davinci = DAVINCI_SCENE.instance()
		item_idx = ExtensionsApi.menu.add_menu_item(ExtensionsApi.menu.IMAGE, "Davinci Shader Editor", davinci)
		global.control.get_node("Dialogs").add_child(davinci)


func _exit_tree() -> void:
	if global:
		ExtensionsApi.menu.remove_menu_item(ExtensionsApi.menu.IMAGE, item_idx)
		davinci.queue_free()
