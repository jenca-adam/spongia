shader_type spatial;
render_mode unshaded, depth_test_disabled;
uniform sampler2D noise;
uniform float outline_width=1.0;
uniform float height_scale;
varying vec2 uv;
void vertex() {
	float distance=length(VERTEX);
	vec3 n=normalize(VERTEX);
	uv=UV;
	VERTEX+=vec3(0,1,0)*((texture(noise,uv).x-0.5)*height_scale);
}
void fragment(){
	vec2 dist = min(UV, 1.0 - UV);
    float edge = min(dist.x, dist.y);
	if (texture(noise, uv).g*edge>0.01+outline_width*0.005){
		discard;
	}
	if (texture(noise, uv).g*edge<0.01){
		discard;
	}
}