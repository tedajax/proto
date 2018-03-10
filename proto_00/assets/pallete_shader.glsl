uniform sampler2D palette;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 index = Texel(texture, texture_coords);
    vec4 c = Texel(palette, index.rg);
    return c;
}
