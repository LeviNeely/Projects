shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec2 screen_size = vec2(1920.0, 1080.0);
uniform bool show_curvature = false;
uniform float curvature_x_amount : hint_range(3.0, 15.0, 0.01) = 6.0; 
uniform float curvature_y_amount : hint_range(3.0, 15.0, 0.01) = 4.0;
uniform vec4 corner_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform bool show_vignette = false;
uniform float vignette_opacity : hint_range(0.0, 1.0, 0.01) = 0.2;
uniform bool show_horizontal_scan_lines = true;
uniform float horizontal_scan_lines_amount : hint_range(0.0, 1800.0, 0.1) = 180.0;
uniform float horizontal_scan_lines_opacity : hint_range(0.0, 1.0, 0.01) = 0.25;
uniform bool show_vertical_scan_lines = false;
uniform float vertical_scan_lines_amount : hint_range(0.0, 320.0, 0.1) = 320.0;
uniform float vertical_scan_lines_opacity : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float boost : hint_range(1.0, 2.0, 0.01) = 1.75;
uniform float aberration_amount : hint_range(0.0, 10.0, 0.01) = 2.75;

// Added uniforms for moving static line with pause
uniform bool roll = true;
uniform float roll_speed : hint_range(0.0001, 1.0) = 0.03;
uniform float static_line_width : hint_range(0.001, 0.1) = 0.005;

// Function to generate random values, used for noise in the static line
float random(vec2 pos) { 
    return fract(sin(dot(pos, vec2(12.9898, 78.233))) * 43758.5453);
}

vec2 uv_curve(vec2 uv) {
    if (show_curvature) {
        uv = uv * 2.0 - 1.0;
        vec2 offset = abs(uv.yx) / vec2(curvature_x_amount, curvature_y_amount);
        uv = uv + uv * offset * offset;
        uv = uv * 0.5 + 0.5;
    }
    return uv;
}

void fragment() {
    vec2 uv = uv_curve(UV);
    vec2 screen_uv = uv_curve(SCREEN_UV);
    vec3 color = texture(SCREEN_TEXTURE, screen_uv).rgb;

      // Aberration effect
    if (aberration_amount > 0.0) {
        float adjusted_amount = aberration_amount / screen_size.x;
        color.r = texture(SCREEN_TEXTURE, vec2(screen_uv.x + adjusted_amount, screen_uv.y)).r;
        color.g = texture(SCREEN_TEXTURE, screen_uv).g;
        color.b = texture(SCREEN_TEXTURE, vec2(screen_uv.x - adjusted_amount, screen_uv.y)).b;
    }

    // Vignette effect
    if (show_vignette) {
        float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
        vignette = clamp(pow((screen_size.x / 4.0) * vignette, vignette_opacity), 0.0, 1.0);
        color *= vignette;
    }

    // Horizontal scan lines effect
    if (show_horizontal_scan_lines) {
        float s = sin(screen_uv.y * horizontal_scan_lines_amount * PI * 2.0);
        s = (s * 0.5 + 0.5) * 0.9 + 0.1;
        vec4 scan_line = vec4(vec3(pow(s, horizontal_scan_lines_opacity)), 1.0);
        color *= scan_line.rgb;
    }

    // Vertical scan lines effect
    if (show_vertical_scan_lines) {
        float s = sin(screen_uv.x * vertical_scan_lines_amount * PI * 2.0);
        s = (s * 0.5 + 0.5) * 0.9 + 0.1;
        vec4 scan_line = vec4(vec3(pow(s, vertical_scan_lines_opacity)), 1.0);
        color *= scan_line.rgb;
    }

    if (show_horizontal_scan_lines || show_vertical_scan_lines) {
        color *= boost;
    }

    // Fill the blank space of the corners, left by the curvature, with black
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        color = corner_color.rgb;
    }


    // Moving static line effect with pause
    if (roll) {
        // Total cycle duration (movement + pause)
        float total_cycle_duration = 1.0 / roll_speed + 5.0; // Includes pause duration
        // Current cycle position [0, total_cycle_duration)
        float cycle_pos = mod(TIME, total_cycle_duration);
        // Active movement phase duration
        float active_duration = 1.0 / roll_speed;

        float line_position;
        if (cycle_pos < active_duration) {
            // Normalized position during active movement phase
            line_position = cycle_pos / active_duration;
        } else {
            // Pause phase
            line_position = -1.0; // Keep the line off-screen
        }

        float distance_from_line = abs(screen_uv.y - line_position);
        if (distance_from_line < static_line_width && line_position != -1.0) {
            float noise_value = random(screen_uv * vec2(100.0, 100.0) + TIME * 10.0);
            color += noise_value * vec3(1.0);
            // Apply distortion within the static line
            color.rg += sin(screen_uv.y * 100.0 + TIME * 10.0) * 0.01 * noise_value;
        }
    }

    COLOR = vec4(color, 1.0);
}
