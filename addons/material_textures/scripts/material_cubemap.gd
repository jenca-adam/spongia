@tool
class_name MaterialCubemap
extends Cubemap

const Utils = preload("./utils.gd")


@export_tool_button("Force Refresh", "Reload")
var update_action: Callable = update_textures:
	get: return update_textures
	set(value): value = update_textures

## The [ShaderMaterial] to use when rendering this texture. The shader must use
## the [code]texture_blit[/code] render mode. [br]
## If the material has a uniform named [code]cubemap_face_index[/code] it will be
## passed the current face index when rendering the texture.
@export var material: ShaderMaterial = null:
	set(value):
		Utils.connect_material(material, value, update_textures)
		material = value
		update_textures(true)

## The resolution of each side of the cubemap.
@export_custom(PROPERTY_HINT_LINK, "suffix:px") var resolution: Vector2i = Vector2i(512, 512):
	set(value):
		resolution = Vector2i(clampi(value.x, 1, Utils.MAX_RES), clampi(value.y, 1, Utils.MAX_RES))
		update_textures(true)
		
## The format used by the internal DrawableTexture2D.
@export_enum("Standard:0","sRGB:1","HDR (16 bit):2","HDR (32 bit):3")
var render_format: int = 0:
	set(value):
		render_format = value
		update_textures(true)

## If true, will generate mipmaps for the texture once it has been rendered.
@export var create_mipmaps: bool = true:
	set(value):
		create_mipmaps = value
		update_textures(true)

## The type of compression to use for the texture. Note that some types of compression only work on certain platforms.
@export_enum("None:-1","S3TC:0","ETC:1","ETC2:2","BPTC:3","ASTC (High Quality):4","ASTC (Low Quality):5")
var compression: int = -1:
	set(value):
		compression = value
		update_textures(true)

## When compressing the textures, the compression can discard channels you don't want to keep.
@export_enum("RGBA:5", "RGB:4", "RG:3", "R:2")
var compression_channels: int = 4:
	set(value):
		compression_channels = value
		update_textures(true)


const IDX_PROPERTY: String = "cubemap_face_index"

func update_textures(editor_only: bool = false):
	
	if editor_only and !Engine.is_editor_hint():
		return
	
	if !material or !material.shader:
		return
	
	if !Utils.valid_shader_mode(material):
		return
	
	var has_idx_property: bool = material.get_shader_parameter(IDX_PROPERTY) != null
	
	var images: Array[Image] = []
	
	for i in range(0,6):
		
		var drawable_tex: DrawableTexture2D = DrawableTexture2D.new()
		drawable_tex.setup(resolution.x, resolution.y, render_format as DrawableTexture2D.DrawableFormat, Color.WHITE, false)
		
		var from := drawable_tex.create_placeholder()
		var rect := Rect2i(0, 0, resolution.x, resolution.y)
		
		var mat_copy := material.duplicate()
		
		if has_idx_property:
			mat_copy.set_shader_parameter(IDX_PROPERTY, i)
		
		drawable_tex.blit_rect(rect, from, Color.WHITE, 0, mat_copy)
		
		var img = drawable_tex.get_image()
		
		if create_mipmaps:
			img.generate_mipmaps()
			
		if compression >= 0 and OS.has_feature("editor"):
			var used_compression = clampi(compression, 0, 4)
			
			img.compress_from_channels(used_compression as Image.CompressMode, compression_channels, Image.ASTC_FORMAT_4x4 if compression <= 4 else Image.ASTC_FORMAT_8x8)
			
		images.append(img)
	
	if images.size() == 0:
		return
	
	self.create_from_images(images)
	emit_changed()
