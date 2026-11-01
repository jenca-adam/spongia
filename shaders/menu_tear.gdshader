shader_type canvas_item;

uniform float percentage: hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float slide_speed=0.0;
uniform sampler2D burn_texture;
uniform sampler2D tx;
uniform float x_thresh = 0.1;
uniform float dist_affect = 1.0;
uniform float softness: hint_range(0.001, 1.0, 0.001) = 0.1;
uniform bool enable_slide=false;
void fragment() {
	if (enable_slide){
		float foo;
	float real_uv_x=modf((UV.x+slide_speed*TIME),foo);
	COLOR=texture(tx, vec2(real_uv_x, UV.y));
	}
		if (UV.x<x_thresh*2.0){
		float edge_distance = min(1.0, UV.x/ x_thresh);
		float noise = texture(burn_texture, SCREEN_UV).r - edge_distance * dist_affect;
		float fade = smoothstep(0.0, softness, percentage - noise);
		COLOR.a *= fade;
	}
}