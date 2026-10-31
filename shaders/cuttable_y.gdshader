/* UNUSED */
shader_type spatial;
render_mode  unshaded;
uniform float model_ymin = -0.1;
uniform float model_ymax = 0.1;
uniform float width;
uniform float y_target;
varying float y_normalized;

void vertex() {
    y_normalized = (VERTEX.y-model_ymin) / (model_ymax-model_ymin) ;
}

void fragment() {
    float pixel_width = fwidth(y_normalized) * width;

    if (abs(y_normalized - y_target) < pixel_width) {
        ALBEDO = vec3(1.0, 1.0, 0.0);
    } else {
        discard;
    }
}