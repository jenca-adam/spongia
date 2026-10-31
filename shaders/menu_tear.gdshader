shader_type canvas_item;

uniform float percentage: hint_range(0.0, 1.0, 0.01) = 1.0;

uniform sampler2D burn_texture;
uniform float x_thresh = 0.1;
uniform float dist_affect = 1.0;
uniform float softness: hint_range(0.001, 1.0, 0.001) = 0.1;

void fragment() {
		if (UV.x<x_thresh*2.0){
		float edge_distance = min(1.0, UV.x / x_thresh);
		float noise = texture(burn_texture, SCREEN_UV).r - edge_distance * dist_affect;
		float fade = smoothstep(0.0, softness, percentage - noise);
		COLOR.a *= fade;
	}
}