@tool
class_name MaterialTexture2DArray
extends Texture2DArray

const Utils = preload("./utils.gd")

@export_tool_button("Force Refresh", "Reload")
var update_action: Callable = update_textures:
	get: return update_textures
	set(value): value = update_textures

## List of [ShaderMaterial]s to turn into textures in the array.
## Shaders must use the [code]texture_blit[/code] render mode.
@export var materials: Array[ShaderMaterial] = []:
	set(value):
		# Reset signal connections
		for m in materials:
			if m and m.changed.is_connected(update_textures):
				m.changed.disconnect(update_textures)
				
		for m in value:
			if m and !m.changed.is_connected(update_textures):
				m.changed.connect(update_textures, CONNECT_PERSIST)
				
		materials = value
		update_textures(true)

@export_custom(PROPERTY_HINT_LINK, "suffix:px") var resolution: Vector2i = Vector2i(512, 512):
	set(value):
		resolution = Vector2i(clampi(value.x, 1, Utils.MAX_RES), clampi(value.y, 1, Utils.MAX_RES))
		update_textures(true)

## The format used by the internal DrawableTexture2D.
@export_enum("Standard:0","sRGB:1","HDR (16 bit):2","HDR (32 bit):3") var render_format: int = 0:
	set(value):
		render_format = value
		update_textures(true)

## If true, will generate mipmaps for the texture once it has been rendered.
@export var create_mipmaps: bool = true:
	set(value):
		create_mipmaps = value
		update_textures(true)

## Should be true if the generated texture is meant to be used as a normal map.
@export var normal_map: bool = false:
	set(value):
		normal_map = value
		update_textures(true)

## The type of compression to use for the texture. Note that some types of compression only work on certain platforms.
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

func update_textures(editor_only: bool = false):
	
	if editor_only and !Engine.is_editor_hint():
		return
	
	if materials.is_empty():
		return
	
	var images: Array[Image] = []
	
	for m in materials:
		
		if !m or !m.shader:
			continue
		
		if !Utils.valid_shader_mode(m):
			continue
		
		var drawable_tex: DrawableTexture2D = DrawableTexture2D.new()
	
		drawable_tex.setup(resolution.x, resolution.y, render_format as DrawableTexture2D.DrawableFormat, Color.WHITE, false)
		
		var from := drawable_tex.create_placeholder()
		var rect := Rect2i(0, 0, resolution.x, resolution.y)
		drawable_tex.blit_rect(rect, from, Color.WHITE, 0, m)
			
		var img = drawable_tex.get_image()
		
		if create_mipmaps:
			img.generate_mipmaps(normal_map)
			
		if compression >= 0 and OS.has_feature("editor"):
			var used_compression = clampi(compression, 0, 4)
			img.compress_from_channels(used_compression as Image.CompressMode, compression_channels, Image.ASTC_FORMAT_4x4 if compression <= 4 else Image.ASTC_FORMAT_8x8)
			
		images.append(img)
	
	if images.size() == 0:
		return
	
	self.create_from_images(images)
	emit_changed()
