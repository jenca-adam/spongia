shader_type texture_blit;

// Gets set automatically when the material gets rendered
uniform float UV_Z;

void blit() {
	vec3 uv = vec3(UV, UV_Z);
	COLOR0 = vec4(uv, 1.0);
}
