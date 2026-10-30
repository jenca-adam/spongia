shader_type spatial;
render_mode depth_draw_never, unshaded;
  uniform vec3 cut_normal = vec3(0, 0, 1);
  uniform float cut_dist = 0.0;
  uniform float width = 0.0;
  varying vec3 local_pos;
  void vertex() { local_pos = VERTEX; }
  void fragment() {
	float d = abs(dot(local_pos, cut_normal) - cut_dist);
    if (d<width) {
        ALBEDO = vec3(1.0, 1.0, 0.0);
    } else {
        discard;
    }
}