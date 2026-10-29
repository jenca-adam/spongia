shader_type texture_blit;

// Gets set automatically when the material gets rendered
uniform int cubemap_face_index;

#include "res://addons/material_textures/utils.gdshaderinc"

void blit() {
	vec3 dir = cubemap_uv_to_direction(cubemap_face_index, UV);
	COLOR0 = vec4(dir * 0.5 + 0.5, 1.0);
}
