extends RefCounted

enum TexFormat {
	Standard = DrawableTexture2D.DRAWABLE_FORMAT_RGBA8, ## 32-bit texture, 8 bits per channel.
	sRGB = DrawableTexture2D.DRAWABLE_FORMAT_RGBA8_SRGB, ## 32-bit texture, 8 bits per channel, with sRGB conversion.
	HDRHalfPrecision = DrawableTexture2D.DRAWABLE_FORMAT_RGBAH, ## Can store values outside of 0-1 range with half precision.
	HDR = DrawableTexture2D.DRAWABLE_FORMAT_RGBAF, ## Can store values outside of 0-1 range with full precision.
}

static func valid_shader_mode(m: ShaderMaterial) -> bool:
	if (m.shader.get_mode() != Shader.MODE_TEXTURE_BLIT):
		printerr("Material %s is not using a shader with render_mode texture_blit, skipping...")
		return false
	return true

static func connect_material(old_mat: ShaderMaterial, new_mat: ShaderMaterial, c: Callable) -> void:
	if new_mat != old_mat:
		# Disconnect the old material first
		if old_mat and old_mat.changed.is_connected(c):
			new_mat.changed.disconnect(c)
		
		# Connect new material
		if new_mat and !new_mat.changed.is_connected(c):
			new_mat.changed.connect(c, CONNECT_PERSIST)

const MAX_RES: int = 1 << 14
const MAX_RES_3D: int = 1 << 10
