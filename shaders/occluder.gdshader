shader_type spatial;
render_mode depth_draw_always, blend_add, cull_back, unshaded;

void fragment() {
    ALBEDO = vec3(1.0);
    ALPHA = 0.0;
}