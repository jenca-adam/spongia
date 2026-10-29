// Use this to get a direction vector from the UV when rendering to a cubemap texture.
vec3 cubemap_uv_to_direction(int index, vec2 uv)
{
    vec3 xyz = vec3(0.0);
    // convert range 0 to 1 to -1 to 1
    uv = uv * 2.0 - 1.0;
    switch (index)
    {
        case 0:
        xyz = vec3( 1.0f,  -uv.y, -uv.x);
        break;  // POSITIVE X
        case 1:
        xyz = vec3(-1.0f,  -uv.y,  uv.x);
        break;  // NEGATIVE X
        case 2:
        xyz = vec3( uv.x,  1.0f,  uv.y);
        break;  // POSITIVE Y
        case 3:
        xyz = vec3( uv.x, -1.0f, -uv.y);
        break;  // NEGATIVE Y
        case 4:
        xyz = vec3( uv.x,  -uv.y,  1.0f);
        break;  // POSITIVE Z
        case 5:
        xyz = vec3( -uv.x,  -uv.y, -1.0f);
        break;  // NEGATIVE Z
    }
    return normalize(xyz);
}