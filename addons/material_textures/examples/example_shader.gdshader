shader_type texture_blit;

uniform float third_channel;

void blit() {
	COLOR0 = vec4(UV.x, UV.y, clamp(third_channel, 0.0, 1.0), 1.0);
}
