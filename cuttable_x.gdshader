shader_type spatial;
render_mode depth_test_disabled;
uniform float model_xmin = -0.1;
uniform float model_xmax = 0.1;
uniform float width;
uniform float x_target;
varying float x_normalized;

void vertex() {
    x_normalized = (VERTEX.x-model_xmin) / (model_xmax-model_xmin) ;
}

void fragment() {
    float pixel_width = fwidth(x_normalized) * width;

    if (abs(x_normalized - x_target) < pixel_width) {
        ALBEDO = vec3(1.0, 1.0, 0.0);
    } else {
        discard;
    }
}