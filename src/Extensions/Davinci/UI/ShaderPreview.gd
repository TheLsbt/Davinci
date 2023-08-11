# This scripts only purpose is to add syntax highlighting

extends TextEdit

export var pixelorama_reserved_color : Color
export var davinci_override_color : Color
export var comment_color : Color

export var types_color : Color
export var flow_control_color : Color
export var member_color : Color
export var constant_color : Color
export var function_color : Color

const types = [
	"shader_type", "render_mode",
	"uniform", "const", "varying", "void", "bool", "int", "float","sampler2D"
]

const functions = [
	"abs", "acos", "acosh", "all", "any", "asin", "asinh", "atan", "atanh",
	"bool", "bvec2", "bvec3", "bvec4", "ceil", "clamp", "cos", "cosh", "cross",
	"degrees", "determinant", "distance", "dot", "equal", "exp", "exp2",
	"faceforward", "float", "floor", "fract", "greaterThan", "greaterThanEqual",
	"int", "inverse", "inversesqrt", "isinf", "isnan", "ivec2", "ivec3", "ivec4",
	"length", "lessThan", "lessThanEqual", "log", "log2", "mat2", "mat3", "mat4",
	"matrixCompMult", "max", "min", "mix", "mod", "normalize", "not", "notEqual",
	"outerProduct", "pow", "radians", "reflect", "refract", "round", "roundEven",
	"sign", "sin", "sinh", "smoothstep", "sqrt", "step", "tan", "tanh", "texture",
	"textureLod", "transpose", "trunc", "vec2", "vec3", "vec4"
]

const constants = [
	"AT_LIGHT_PASS", "COLOR", "FRAGCOORD", "MODULATE", "NORMAL", "NORMALMAP",
	"NORMAL_DEPTH", "NORMAL_TEXTURE", "POINT_COORD", "SCREEN_PIXEL_SIZE",
	"SCREEN_TEXTURE", "SCREEN_UV", "TEXTURE", "TEXTURE_PIXEL_SIZE", "TIME", "UV"
]

const flow_control = [
	"if", "else"
]

const members = [
	"unshaded", "light_only", "skip_vertex_transform",
	"blend_mix", "blend_add", "blend_sub", "blend_mul", "blend_premul_alpha", "blend_disabled",
	"COLOR", "TEXTURE", "UV"
]

func _ready() -> void:
	for i in types:
		add_keyword_color(i, types_color)
	
	for f in flow_control:
		add_keyword_color(f, flow_control_color)
	
	for m in members:
		add_keyword_color(m, member_color)
	
	for c in constants:
		add_keyword_color(c, constant_color)
	
	for d in functions:
		add_keyword_color(d, function_color)
	
	# Davinci customs
	add_color_region("--", "", davinci_override_color, false)
	
	add_color_region("//", "", comment_color, true)
	
	# Pixelorama Reserved
	add_keyword_color("selection", pixelorama_reserved_color)
