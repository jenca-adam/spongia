@tool
class_name MaterialTexture3D
extends ImageTexture3D

const Utils = preload("./utils.gd")

@export_tool_button("Force Refresh", "Reload")
var update_action: Callable = update_textures:
	get: return update_textures
	set(value): value = update_textures

## The [ShaderMaterial] to use when rendering this texture. The shader must use
## the [code]texture_blit[/code] render mode.
## If the material has a uniform named [code]UVZ[/code] it will be
## passed the current Z UV coordinate during the render.
@export var material: ShaderMaterial = null:
	set(value):
		Utils.connect_material(material, value, update_textures)
		material = value
		update_textures(true)

## The resolution of the 3D texture. [br]
## High resolutions quickly scale to use a [i]lot[/i] of memory - unlike
## regular 2D textures, 3D textures' memory footprint scales cubically.
@export_custom(PROPERTY_HINT_LINK, "suffix:px") var resolution: Vector3i = Vector3i(32, 32, 32):
	set(value):
		resolution = Vector3i(clampi(value.x, 1, Utils.MAX_RES_3D), clampi(value.y, 1, Utils.MAX_RES_3D), clampi(value.z, 1, Utils.MAX_RES_3D))
		update_textures(true)

## The format used by the internal DrawableTexture2D.
@export_enum("Standard:0","sRGB:1","HDR (16 bit):2","HDR (32 bit):3") var render_format: int = 0:
	set(value):
		render_format = value
		update_textures(true)

## If true, will generate mipmaps for the texture once it has been rendered.
@export var create_mipmaps: bool = false:
	set(value):
		create_mipmaps = value
		update_textures(true)

## The type of compression to use for the texture. Note that some types of compression only work on certain platforms. [br]
## For 3D textures, I would recommend avoiding compression and sticking to low resolutions (64x64x64 max).
@export_enum("None:-1","S3TC:0","ETC:1","ETC2:2","BPTC:3","ASTC (High Quality):4","ASTC (Low Quality):5") var compression: int = -1:
	set(value):
		compression = value
		update_textures(true)

## When compressing the textures, the compression can discard channels you don't want to keep.
@export_enum("RGBA:5", "RGB:4", "RG:3", "R:2")
var compression_channels: int = 5:
	set(value):
		compression_channels = value
		update_textures(true)

const UV_Z_PROPERTY: String = "UV_Z"

func update_textures(editor_only: bool = false):
	
	if editor_only and !Engine.is_editor_hint():
		return
	
	if !material or !material.shader:
		return
	
	if !Utils.valid_shader_mode(material):
		return
	
	var has_idx_property: bool = material.get_shader_parameter(UV_Z_PROPERTY) != null
	
	var images: Array[Image] = []
	
	for i in range(0,resolution.z):
		
		var drawable_tex: DrawableTexture2D = DrawableTexture2D.new()
		drawable_tex.setup(resolution.x, resolution.y, render_format as DrawableTexture2D.DrawableFormat, Color.WHITE, false)
		
		var from := drawable_tex.create_placeholder()
		var rect := Rect2i(0, 0, resolution.x, resolution.y)
		
		var mat_copy := material.duplicate()
		
		if has_idx_property:
			mat_copy.set_shader_parameter(UV_Z_PROPERTY, i/float(resolution.z))
		
		drawable_tex.blit_rect(rect, from, Color.WHITE, 0, mat_copy)
		
		var img = drawable_tex.get_image()
			
		if compression >= 0 and OS.has_feature("editor"):
			var used_compression = clampi(compression, 0, 4)
			img.compress_from_channels(used_compression as Image.CompressMode, compression_channels, Image.ASTC_FORMAT_4x4 if compression <= 4 else Image.ASTC_FORMAT_8x8)
			
		images.append(img)
	
	if images.size() == 0:
		return
	
	self.create(images[0].get_format(), resolution.x, resolution.y, resolution.z, create_mipmaps, images)
	emit_changed()
