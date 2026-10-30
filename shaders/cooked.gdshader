shader_type spatial;
uniform sampler3D noise;
uniform float alpha;
uniform float scale=1.0;
uniform float alpha_cap=0.95;
varying vec3 position;
uniform vec3 color:source_color;
void vertex() {
	position=VERTEX*scale;
	// Called for every vertex the material is visible on.
}

void fragment() {
	float noise_value = texture(noise, position).r;
	ALPHA=min(alpha_cap,alpha*(1.0-noise_value));
	ALBEDO=color;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
