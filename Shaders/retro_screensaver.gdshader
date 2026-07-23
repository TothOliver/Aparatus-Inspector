shader_type canvas_item;

uniform vec4 bg_color : source_color = vec4(0.0, 0.313, 0.313, 1.0); // Classic Windows 95/98 Teal
uniform float speed : hint_range(0.1, 5.0) = 1.0;
uniform float code_rain_alpha : hint_range(0.0, 1.0) = 0.35;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec2 st = UV;
    float time = TIME * speed;
    
    // 1. Teal Background Base
    vec3 color = bg_color.rgb;
    
    // 2. Retro Terminal Code Rain Drops
    vec2 code_uv = vec2(st.x * 60.0, st.y * 30.0 + time * 4.0 * (0.5 + random(vec2(floor(st.x * 60.0), 0.0))));
    vec2 code_id = floor(code_uv);
    float code_rand = random(code_id);
    
    float trail = fract(st.y * 3.0 - time * 0.6 * (0.8 + random(vec2(code_id.x, 1.0))));
    float code_brightness = pow(1.0 - trail, 3.5) * (code_rand > 0.55 ? 1.0 : 0.0) * code_rain_alpha;
    
    // Add subtle matrix green/cyan terminal glow
    color += vec3(0.0, code_brightness * 0.7, code_brightness * 0.5);
    
    COLOR = vec4(color, 1.0);
}
