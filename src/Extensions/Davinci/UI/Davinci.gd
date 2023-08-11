extends ConfirmationDialog

enum { SELECTED_CELS, FRAME, ALL_FRAMES, ALL_PROJECTS }

const VaildExtensions = ["shader", "gdshader", "tres", "res"]

onready var shader_preview: TextEdit = $"%ShaderPreview"
onready var image_preview: TextureRect = $"%ImagePreview"
onready var params_container: VBoxContainer = $"%ParamsContainer"

onready var errors: VBoxContainer = $"%Errors"

# Dialogs
onready var open_shader: FileDialog = $Dialogs/OpenShader
onready var save_shader: FileDialog = $Dialogs/SaveShader


# Persistant options
onready var selection_checkbox: CheckBox = $"%SelectionCheckbox"
onready var affected_options: OptionButton = $"%AffectedOptions"

# Shader Tool Buttons
onready var update_code_btn: Button = $"%UpdateCode"


var preview_image := Image.new()
var preview_texture := ImageTexture.new()
var selected_cels := Image.new()
var current_frame := Image.new()

var affect := 0
var shader_mat := ShaderMaterial.new()
var cache := {}

var auto_update_shader

var commit_idx := -1  # the current frame, image effect is applied to
var _preview_idx := 0  # the current frame, being previewed
var confirmed := false

var global



func _enter_tree() -> void:
	global = get_node("/root/Global")

func _ready() -> void:
#	call_deferred("popup")
	connect("confirmed", self, "_confirmed")
	connect("about_to_show", self, "_about_to_show")
	affected_options.get_popup().connect("index_pressed", self,\
		 "_on_AffectedOptions_index_pressed")
	clear_ui()
	update_image_preview()
	
	image_preview.set_material(shader_mat)

func _about_to_show() -> void:
	update_image_preview()
	update_shader_code(shader_preview.text)
	

# Open / Save Buttons
func _on_open_file_pressed() -> void:
	open_shader.popup_centered()

func _on_save_file_pressed() -> void:
	save_shader.popup_centered()

# File Dialogs
func _on_save_shader_file_selected(path: String) -> void:
	save_current_sahder(path)

func _on_open_shader_file_selected(path: String) -> void:
	check_is_shader(path)


func _on_update_code_pressed() -> void:
	update_shader_code(shader_preview.text)

func _on_auto_update_code_toggled(toggled: bool) -> void:
	update_code_btn.disabled = toggled
	auto_update_shader = toggled

func _on_shader_preview_text_changed() -> void:
	if auto_update_shader:
		update_shader_code(shader_preview.text)


func update_shader_code(new_code: String) -> void:
	cache.clear()
	
	update_image_preview()
	
	if !shader_mat:
		shader_mat = ShaderMaterial.new()
	if !shader_mat.shader:
		var shader = Shader.new()
		shader_mat.shader = shader
	
	shader_mat.shader.code = new_code
	
	var params = VisualServer.shader_get_param_list(shader_mat.shader.get_rid())
	parse_params(params)
	
	selection_checkbox.visible = cache.has("selection")


func save_current_sahder(path: String) -> void:
	if shader_mat.shader:
		var err = ResourceSaver.save(path, shader_mat.shader)
		if err != OK:
			var error_manager = get_node("/root/ErrorManager")
			var message = "Could not save shader (Error Code:" + str(err) + ")."
			if error_manager:
				error_manager.parse(err, "Could not save shader (", ").")
			ExtensionsApi.dialog.show_error(message)
		else:
			print("Saved shader to '", path, "'")


func check_is_shader(path: String) -> void:
	shader_preview.text = ""
	shader_mat.shader = null
	cache.clear()
	
	update_image_preview()
	
	var test = File.new()
	if !test.file_exists(path):
#		print("File Doesnt exist.")
		return
	
	if !VaildExtensions.has(path.get_extension()):
#		print("Icorrect extension")
		return
	
	var shader : Shader = load(path)
	
	if shader == null:
		return
	
	shader_preview.text = shader.code
	
	# Shader mat
	shader_mat.shader = shader
	
	
	
	var params = VisualServer.shader_get_param_list(shader.get_rid())
	parse_params(params)
	
	
	selection_checkbox.visible = cache.has("selection")


func parse_params(params: Array) -> void:
	clear_ui()
	
	var code := shader_mat.shader.code
	code = code.c_unescape()
	
	var split = code.split("\n", false)
	var first_line : String = split[0]
	
	first_line.replace(" ", "")
	first_line.replace("/", "")
#
	var data = first_line.split(":", false)
	var excluded = data[1].replace(" ", "").split(",", false)
#
##	print(params)
	print(excluded)
	for p in params:
		var name = p.name
		var type = p.type
		
		if excluded.has(name):
			continue
		
		if name == "selection":
			if p.hint != PROPERTY_HINT_RESOURCE_TYPE: # 19
				show_error("NotValidSelectionUniform")
				continue
			if p.hint_string != "Texture":
				show_error("NotValidSelectionUniform")
				continue
			cache["selection"] = null
			continue
		
		var ui = null
		match type:
			TYPE_BOOL:
				ui = preload("res://src/Extensions/Davinci/UI/Params/BoolParam.tscn").instance()
			TYPE_INT:
				ui = preload("res://src/Extensions/Davinci/UI/Params/IntParam.tscn").instance()
			TYPE_REAL: # Float
				ui = preload("res://src/Extensions/Davinci/UI/Params/FloatParam.tscn").instance()
		if ui == null:
			return
		
		ui.param = name
		if shader_mat.get_shader_param(name) != null:
			ui.value = convert(shader_mat.get_shader_param(name), type)
		ui.root = self
		
		
		params_container.add_child(ui)
		
func param_value_changed(param: String, value) -> void:
	cache[param] = value
	update_davinci()


func update_image_preview() -> void:
	var project: Project = global.current_project
	var preview_image := Image.new()
	preview_image.create(project.size.x, project.size.y, false, Image.FORMAT_RGBA8)
	
	if affect == SELECTED_CELS:
		var undo_data := _get_undo_data(project)
		for cel_index in project.selected_cels:
			if !project.layers[cel_index[1]].can_layer_get_drawn():
				continue
			var cel: BaseCel = project.frames[cel_index[0]].cels[cel_index[1]]
			if not cel is PixelCel:
				continue
			var cel_image: Image = cel.image
			preview_image.copy_from(cel_image)
	
	elif affect == FRAME:
		var i := 0
		for cel in project.frames[project.current_frame].cels:
			if not cel is PixelCel:
				i += 1
				continue
			if project.layers[i].can_layer_get_drawn():
				preview_image.copy_from(cel.image)
			
	elif affect == ALL_FRAMES:
		for frame in project.frames:
			var i := 0
			commit_idx += 1  # frames are simply increasing by 1 in this mode
			for cel in frame.cels:
				if not cel is PixelCel:
					i += 1
					continue
				if project.layers[i].can_layer_get_drawn():
					preview_image.copy_from(cel.image)
				i += 1
				
	elif affect == ALL_PROJECTS:
		for _project in global.projects:
			commit_idx = -1
			
			for frame in _project.frames:
				var i := 0
				commit_idx += 1  # frames are simply increasing by 1 in this mode
				for cel in frame.cels:
					if not cel is PixelCel:
						i += 1
						continue
					if _project.layers[i].can_layer_get_drawn():
						preview_image.copy_from(cel.image)
					i += 1
				
	var preview_texture = ImageTexture.new()
	preview_texture.create_from_image(preview_image, 0)
	image_preview.texture = preview_texture
	
	# Offset to center the image base off size.
	image_preview.rect_position = -preview_image.get_size() / 2


func update_davinci() -> void:
	var project: Project = global.current_project
	var params := cache.duplicate(true)
	
	if params.has("selection"):
		var selection_tex := ImageTexture.new()
		if selection_checkbox.pressed and project.has_selection:
			selection_tex.create_from_image(project.selection_map, 0)
		
		params["selection"] = selection_tex
	
	if !confirmed:
		for param in params:
			shader_mat.set_shader_param(param, params[param])
	


func _confirmed() -> void:
	confirmed = true
	commit_idx = -1
	var project: Project = global.current_project
	if affect == SELECTED_CELS:
		var undo_data := _get_undo_data(project)
		for cel_index in project.selected_cels:
			if !project.layers[cel_index[1]].can_layer_get_drawn():
				continue
			var cel: BaseCel = project.frames[cel_index[0]].cels[cel_index[1]]
			if not cel is PixelCel:
				continue
			var cel_image: Image = cel.image
			commit_idx = cel_index[0]  # frame is cel_index[0] in this mode
			commit_action(cel_image)
		_commit_undo("Draw", undo_data, project)

	elif affect == FRAME:
		var undo_data := _get_undo_data(project)
		var i := 0
		commit_idx = project.current_frame
		for cel in project.frames[project.current_frame].cels:
			if not cel is PixelCel:
				i += 1
				continue
			if project.layers[i].can_layer_get_drawn():
				commit_action(cel.image)
			i += 1
		_commit_undo("Draw", undo_data, project)

	elif affect == ALL_FRAMES:
		var undo_data := _get_undo_data(project)
		for frame in project.frames:
			var i := 0
			commit_idx += 1  # frames are simply increasing by 1 in this mode
			for cel in frame.cels:
				if not cel is PixelCel:
					i += 1
					continue
				if project.layers[i].can_layer_get_drawn():
					commit_action(cel.image)
				i += 1
		_commit_undo("Draw", undo_data, project)

	elif affect == ALL_PROJECTS:
		for _project in global.projects:
			commit_idx = -1

			var undo_data := _get_undo_data(_project)
			for frame in _project.frames:
				var i := 0
				commit_idx += 1  # frames are simply increasing by 1 in this mode
				for cel in frame.cels:
					if not cel is PixelCel:
						i += 1
						continue
					if _project.layers[i].can_layer_get_drawn():
						commit_action(cel.image, _project)
					i += 1
			_commit_undo("Draw", undo_data, _project)

func commit_action(cel: Image, project: Project = global.current_project) -> void:
	var params := cache.duplicate(true)
	
	if params.has("selection"):
		var selection_tex := ImageTexture.new()
		if selection_checkbox.pressed and project.has_selection:
			selection_tex.create_from_image(project.selection_map, 0)
		
		params["selection"] = selection_tex
	
	if confirmed:
		var gen := ShaderImageEffect.new()
		gen.generate_image(cel, shader_mat.shader, params, project.size)
		yield(gen, "done")

func _get_undo_data(project: Project) -> Dictionary:
	var data := {}
	var images := _get_selected_draw_images(project)
	for image in images:
		image.unlock()
		data[image] = image.data
	return data
	
func _commit_undo(action: String, undo_data: Dictionary, project: Project) -> void:
	var redo_data := _get_undo_data(project)
	project.undos += 1
	project.undo_redo.create_action(action)
	for image in redo_data:
		project.undo_redo.add_do_property(image, "data", redo_data[image])
	for image in undo_data:
		project.undo_redo.add_undo_property(image, "data", undo_data[image])
	project.undo_redo.add_do_method(global, "undo_or_redo", false, -1, -1, project)
	project.undo_redo.add_undo_method(global, "undo_or_redo", true, -1, -1, project)
	project.undo_redo.commit_action()

func _get_selected_draw_images(project: Project) -> Array:  # Array of Images
	var images := []
	if affect == SELECTED_CELS:
		for cel_index in project.selected_cels:
			var cel: BaseCel = project.frames[cel_index[0]].cels[cel_index[1]]
			if cel is PixelCel:
				images.append(cel.image)
	else:
		for frame in project.frames:
			for cel in frame.cels:
				if cel is PixelCel:
					images.append(cel.image)
	return images

# Signal
func _on_AffectedOptions_index_pressed(idx: int) -> void:
	affect = idx
	update_image_preview()

func show_error(error_id: String) -> void:
	if errors.has_node(error_id):
		errors.get_node(error_id).show()
	else:
		printerr("Error: ", error_id, "does not exist.")

# Util
# Cleans the params (ui) and errors
func clear_ui() -> void:
	for error in errors.get_children():
		error.hide()
	for child in params_container.get_children():
		child.free()

func menu_item_clicked() -> void:
	popup_centered()
