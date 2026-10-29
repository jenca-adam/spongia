shader_type texture_blit;


uniform float percentage: hint_range(0.0, 1.0, 0.01) = 1.0;

uniform sampler2D burn_texture;
uniform float x_thresh=0.1;
uniform float dist_affect=1.0;

void blit() {
	COLOR0=vec4(0,0,0,1);
	if (UV.x<x_thresh){
	float edge_distance=min(1.0, UV.x/x_thresh);
	float noise = texture(burn_texture, UV).r-edge_distance*dist_affect;
	if (noise>percentage){
		COLOR0=vec4(0,0,0,0);
	}
	
	}
	
}
