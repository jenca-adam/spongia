@tool
class_name MaterialTexture2D
extends PortableCompressedTexture2D

const Utils = preload("./utils.gd")

enum Compression {
	None = COMPRESSION_MODE_LOSSLESS,
	Lossy = COMPRESSION_MODE_LOSSY,
	Universal = COMPRESSION_MODE_BASIS_UNIVERSAL, ## Works on every platform and reduces texture channels to only what is actually used by the material.
	S3TC = COMPRESSION_MODE_S3TC,
	ETC2 = COMPRESSION_MODE_ETC2,
	BPTC = COMPRESSION_MODE_BPTC,
	ASTC = COMPRESSION_MODE_ASTC,
}

@export_tool_button("Force Refresh", "Reload")
var update_action: Callable = update_texture:
	get:
		return update_texture
	set(value):
		update_action = update_texture

## The [ShaderMaterial] to use when rendering this texture.
## The shader must use the [code]texture_blit[/code] render mode.
@export var material: ShaderMaterial = null:
	set(value):
		Utils.connect_material(material, value, update_texture)
		material = value
		update_texture(true)

@export_custom(PROPERTY_HINT_LINK, "suffix:px") var resolution: Vector2i = Vector2i(512, 512):
	set(value):
		resolution = Vector2i(clampi(value.x, 1, Utils.MAX_RES), clampi(value.y, 1, Utils.MAX_RES))
		update_texture(true)

## The format used by the internal DrawableTexture2D.
@export_enum("Standard:0","sRGB:1","HDR (16 bit):2","HDR (32 bit):3") var render_format: int = 0:
	set(value):
		render_format = value
		update_texture(true)

## If true, will generate mipmaps for the texture once it has been rendered.
@export var create_mipmaps: bool = true:
	set(value):
		create_mipmaps = value
		update_texture(true)

## Should be true if the generated texture is meant to be used as a normal map.
@export var normal_map: bool = false:
	set(value):
		normal_map = value
		update_texture(true)

## The type of compression to use for the texture. Note that some types of compression only work on certain platforms.
## Universal is slow to compress but works on every platform.
@export var compression: Compression = Compression.None:
	set(value):
		compression = value
		update_texture(true)

## When compression is set to lossy, determines just how lossy the compression is.
@export_range(0.0, 1.0, 0.1, "hide_slider") var compression_quality: float = 0.8:
	set(value):
		compression_quality = clampf(value, 0.0, 1.0)
		update_texture(true)

func update_texture(editor_only: bool = false):
	
	if editor_only and !Engine.is_editor_hint():
		return
	
	if !material or !material.shader or !Utils.valid_shader_mode(material):
		return
	
	var dt: DrawableTexture2D = DrawableTexture2D.new()
	
	dt.setup(resolution.x, resolution.y, render_format as DrawableTexture2D.DrawableFormat, Color.WHITE, false)
	
	var from := create_placeholder()
	var rect := Rect2i(0, 0, resolution.x, resolution.y)
	
	dt.blit_rect(rect, from, Color.WHITE, 0, material)
	
	if (compression == CompressionMode.COMPRESSION_MODE_BASIS_UNIVERSAL):
		set_basisu_compressor_params(lerp(0, 10, compression_quality), 0.0)
		
	var img = dt.get_image()
	
	if create_mipmaps:
		img.generate_mipmaps(normal_map)
	
	self.size_override = resolution
	self.create_from_image(img, compression as CompressionMode, normal_map, compression_quality)
	emit_changed()
