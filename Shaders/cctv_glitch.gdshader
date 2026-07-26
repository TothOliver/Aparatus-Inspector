shader_type canvas_item;

uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float time : hint_range(0.0, 100.0) = 0.0;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;
    if (glitch_intensity > 0.001) {
        // Horizontal line tearing displacement
        float line_noise = rand(vec2(trunc(uv.y * 24.0), trunc(time * 45.0)));
        if (line_noise < glitch_intensity * 0.75) {
            uv.x += (rand(vec2(uv.y, time)) - 0.5) * 0.16 * glitch_intensity;
        }
        
        // RGB chromatic aberration shift
        float shift = 0.015 * glitch_intensity;
        vec4 col_r = texture(TEXTURE, vec2(uv.x + shift, uv.y));
        vec4 col_g = texture(TEXTURE, uv);
        vec4 col_b = texture(TEXTURE, vec2(uv.x - shift, uv.y));
        
        vec4 final_color = vec4(col_r.r, col_g.g, col_b.b, col_g.a);
        
        // High-frequency static noise overlay
        float noise = rand(uv + vec2(time * 10.0, time * 20.0));
        final_color.rgb = mix(final_color.rgb, vec3(noise), glitch_intensity * 0.5);
        
        COLOR = final_color;
    } else {
        COLOR = texture(TEXTURE, uv);
    }
}
