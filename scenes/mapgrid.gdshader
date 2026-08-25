shader_type spatial;

uniform vec3 grid_offset = vec3(0.0);
uniform float grid_size = 1.0;
uniform float line_width = 0.05;
uniform vec4 grid_color : source_color = vec4(0.0, 0.8, 1.0, 1.0);
uniform vec4 base_color : source_color = vec4(0.1, 0.1, 0.1, 1.0);

varying vec3 world_pos;

void vertex() {
    // Transform vertex position from local space to world space
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    // Offset world position by the drag vector (ignoring Y for a floor grid, or use XYZ)
    vec2 coord = (world_pos.xz + grid_offset.xz) / grid_size;
    
    // Find distance to the nearest grid line
    vec2 grid = abs(fract(coord - 0.5) - 0.5) / fwidth(coord);
    float line = min(grid.x, grid.y);
    
    // Create anti-aliased grid line mask
    float weight = 1.0 - min(line / line_width, 1.0);
    
    ALBEDO = mix(base_color.rgb, grid_color.rgb, weight);
    ALPHA = mix(base_color.a, grid_color.a, weight);
}