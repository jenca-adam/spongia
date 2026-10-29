shader_type texture_blit;

group_uniforms Channels;
uniform sampler2D textures[4];

group_uniforms Channels.Red;
uniform int red_source_texture_index : hint_range(0, 3) = 0;
uniform int red_source_channel: hint_enum("Red","Green","Blue","Alpha") = 0;

group_uniforms Channels.Green;
uniform int green_source_texture_index : hint_range(0, 3) = 0;
uniform int green_source_channel: hint_enum("Red","Green","Blue","Alpha") = 0;

group_uniforms Channels.Blue;
uniform int blue_source_texture_index : hint_range(0, 3) = 0;
uniform int blue_source_channel: hint_enum("Red","Green","Blue","Alpha") = 0;

group_uniforms Channels.Alpha;
uniform int alpha_source_texture_index : hint_range(0, 3) = 0;
uniform int alpha_source_channel: hint_enum("Red","Green","Blue","Alpha") = 0;

float get_channel(int texidx, int channel, vec2 uv) {
	return texture(textures[texidx], uv)[channel];
}

void blit() {
	vec4 result = vec4(0.0);
	
	result.r = get_channel(red_source_texture_index, red_source_channel, UV);
	result.g = get_channel(green_source_texture_index, green_source_channel, UV);
	result.b = get_channel(blue_source_texture_index, blue_source_channel, UV);
	result.a = get_channel(alpha_source_texture_index, alpha_source_channel, UV);
	COLOR0 = result;
}
