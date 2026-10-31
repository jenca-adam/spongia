shader_type canvas_item;
uniform float freq=1.0;
uniform float min_alpha=0.0;
void fragment() {
	COLOR.a*=max(min_alpha,abs(sin(TAU*TIME*freq)));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
