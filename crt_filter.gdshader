shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform float scanline_count : hint_range(0.0, 1000.0) = 400.0;
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.08;
uniform float curvature : hint_range(0.0, 1.0) = 0.025;
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.08;
uniform float grr_intensity : hint_range(0.0, 1.0) = 0.03;
uniform float aberration : hint_range(0.0, 0.1) = 0.001;

// Distortion function for curvature
vec2 curve(vec2 uv) {
    uv = uv * 2.0 - 1.0;
    vec2 offset = abs(uv.yx) / vec2(8.0 + curvature * 2.0, 8.0 + curvature * 2.0);
    uv = uv + uv * offset * offset * curvature * 15.0;
    uv = uv * 0.5 + 0.5;
    return uv;
}

void fragment() {
    // Warp UVs
    vec2 uv = curve(UV);
    
    // Check borders (cut off pixels outside warp boundary to make screen corners rounded)
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        // Color chromatic aberration (resolution-independent relative to 1280px design width)
        vec4 col;
        float shift = aberration * (1280.0 * SCREEN_PIXEL_SIZE.x);
        col.r = texture(screen_texture, uv - vec2(shift, 0.0)).r;
        col.g = texture(screen_texture, uv).g;
        col.b = texture(screen_texture, uv + vec2(shift, 0.0)).b;
        col.a = 1.0;
        
        // Scanlines (horizontal lines)
        float scanline = sin(uv.y * scanline_count * 2.0 * 3.14159265) * 0.5 + 0.5;
        col.rgb = mix(col.rgb, col.rgb * scanline, scanline_intensity);
        
        // Phosphor grill mask (vertical lines)
        float grill = sin(uv.x * scanline_count * 1.3333 * 2.0 * 3.14159265) * 0.5 + 0.5;
        col.rgb = mix(col.rgb, col.rgb * grill, grr_intensity);
        
        // Vignette (darker corners)
        vec2 v_uv = uv * (1.0 - uv.yx);
        float vignette = v_uv.x * v_uv.y * 15.0;
        vignette = clamp(pow(vignette, vignette_intensity), 0.0, 1.0);
        col.rgb *= vignette;
        
        COLOR = col;
    }
}
