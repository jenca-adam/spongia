shader_type spatial;
render_mode unshaded;
uniform float model_zmin = -0.1;
uniform float model_zmax = 0.1;
uniform float width;
uniform float z_target;
varying float z_normalized;

void vertex() {
    z_normalized = (VERTEX.z-model_zmin) / (model_zmax-model_zmin) ;
}

void fragment() {
    float pixel_width = fwidth(z_normalized) * width;

    if (abs(z_normalized - z_target) < pixel_width) {
        ALBEDO = vec3(1.0, 1.0, 0.0);
    } else {
        discard;
    }
}