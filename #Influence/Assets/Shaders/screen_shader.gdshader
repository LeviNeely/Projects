/////*
	////CRT shader for Godot Engine inspired by Yui Kinomoto @arlez80
////*/
////
////shader_type canvas_item;
////
////uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
////
////uniform float crt_curve : hint_range(0.0, 1.0) = 0.0;
////uniform float crt_scan_line_color : hint_range(0.0, 1.0) = 0.347;
////uniform float aperture_grille_rate : hint_range(0.0, 1.0) = 0.4;
////uniform float rf_switch_esque_blur : hint_range(0.0, 1.0) = 1.0;
////uniform float white_noise_rate : hint_range(0.0, 1.0) = 0.0;
////
////// Uniforms for moving static line effect
////uniform bool roll = true;
////uniform float roll_speed = 0.03;  // Positive values move down, negative up
////uniform float static_line_width : hint_range(0.001, 0.1) = 0.005; // Width of the static line
////
////float random(vec2 pos) { 
    ////return fract(sin(dot(pos, vec2(12.9898,78.233))) * 43758.5453);
////}
////
////void fragment() {
    ////vec2 crt_curve_shift = (vec2(1.0, 1.0) - sin(UV.yx * PI)) * crt_curve;
    ////vec2 crt_curve_scale = vec2(1.0, 1.0) + crt_curve_shift * 2.0;
    ////vec2 fixed_uv = SCREEN_UV * crt_curve_scale - crt_curve_shift;
    ////float enable_color = float(0.0 <= fixed_uv.x && fixed_uv.x <= 1.0 && 0.0 <= fixed_uv.y && fixed_uv.y <= 1.0);
////
    ////// Initialize distorted_uv with fixed_uv
    ////vec2 distorted_uv = fixed_uv;
////
    ////// Moving static line effect with pause and distortion
    ////if (roll) {
        //// Total cycle duration (movement + pause)
        //float total_cycle_duration = 1.0 / roll_speed + 5.0; // Includes pause duration
        //// Current cycle position [0, total_cycle_duration)
        //float cycle_pos = mod(TIME, total_cycle_duration);
        //// Active movement phase duration
        //float active_duration = 1.0 / roll_speed;
//
        //float line_position;
        //if (cycle_pos < active_duration) {
            //// Normalized position during active movement phase
            //line_position = cycle_pos / active_duration;
        //} else {
            //// Pause phase
            //line_position = -1.0; // Keep the line at the bottom
        //}
////
        ////float distance_from_line = abs(UV.y - line_position);
        ////bool in_static_line = distance_from_line < static_line_width;
////
        ////if (in_static_line) {
            ////float noise_value = random(UV * vec2(100.0, 100.0) + TIME * 10.0) * white_noise_rate;
            ////COLOR.rgb = mix(COLOR.rgb, vec3(1.0), noise_value);
////
            ////// Apply distortion within the static line
            ////float distortion_strength = 0.05; // Adjust the strength of the distortion
            ////distorted_uv.x += sin(UV.y * 100.0 + TIME * 10.0) * distortion_strength * noise_value;
        ////}
    ////}
////
    ////// Use distorted_uv for texture sampling to apply the distortion effect
    ////COLOR.rgb *= (
        ////texture(SCREEN_TEXTURE, distorted_uv).rgb * (1.0 - rf_switch_esque_blur * 0.5) +
        ////(
            ////texture(SCREEN_TEXTURE, distorted_uv + vec2(-SCREEN_PIXEL_SIZE.x * 3.1, 0.0)).rgb +
            ////texture(SCREEN_TEXTURE, distorted_uv + vec2(SCREEN_PIXEL_SIZE.x * 3.1, 0.0)).rgb
        ////) * (rf_switch_esque_blur * 0.25)
    ////) * enable_color;
////
    ////COLOR.a = 1.0;
////
    ////// Apply CRT scan line effect
    ////COLOR = mix(
        ////COLOR,
        ////vec4(0.0, 0.0, 0.0, 1.0),
        ////float(0 == int(fixed_uv.y / SCREEN_PIXEL_SIZE.y) % 2) * crt_scan_line_color
    ////) * 2.0;
////}
//
//shader_type canvas_item;
//
//uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
//uniform vec2 screen_size = vec2(1920.0, 1080.0);
//uniform bool show_curvature = false;
//uniform float curvature_x_amount : hint_range(3.0, 15.0, 0.01) = float(6.0); 
//uniform float curvature_y_amount : hint_range(3.0, 15.0, 0.01) = float(4.0);
//uniform vec4 corner_color = vec4(0.0, 0.0, 0.0, 1.0);
//uniform bool show_vignette = false;
//uniform float vignette_opacity : hint_range(0.0, 1.0, 0.01) = 0.2;
//uniform bool show_horizontal_scan_lines = true;
//uniform float horizontal_scan_lines_amount : hint_range(0.0, 180.0, 0.1) = 180.0;
//uniform float horizontal_scan_lines_opacity : hint_range(0.0, 1.0, 0.01) = 0.25;
//uniform bool show_vertical_scan_lines = false;
//uniform float vertical_scan_lines_amount : hint_range(0.0, 320.0, 0.1) = 320.0;
//uniform float vertical_scan_lines_opacity : hint_range(0.0, 1.0, 0.01) = 0.1;
//uniform float boost : hint_range(1.0, 2.0, 0.01) = 1.75;
//uniform float aberration_amount : hint_range(0.0, 10.0, 0.01) = 2.75;
//
//vec2 uv_curve(vec2 uv) {
	//if (show_curvature) {
		//uv = uv * 2.0 - 1.0;
		//vec2 offset = abs(uv.yx) / vec2(curvature_x_amount, curvature_y_amount);
		//uv = uv + uv * offset * offset;
		//uv = uv * 0.5 + 0.5;
	//}
//
	//return uv;
//}
//
//
//void fragment() {
	//vec2 uv = uv_curve(UV);
	//vec2 screen_uv = uv_curve(SCREEN_UV);
	//vec3 color = texture(SCREEN_TEXTURE, screen_uv).rgb;
//
	//if (aberration_amount > 0.0) {
		//float adjusted_amount = aberration_amount / screen_size.x;
		//color.r = texture(SCREEN_TEXTURE, vec2(screen_uv.x + adjusted_amount, screen_uv.y)).r;
		//color.g = texture(SCREEN_TEXTURE, screen_uv).g;
		//color.b = texture(SCREEN_TEXTURE, vec2(screen_uv.x - adjusted_amount, screen_uv.y)).b;
	//}
//
	//if (show_vignette) {
		//float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
		//vignette = clamp(pow((screen_size.x / 4.0) * vignette, vignette_opacity), 0.0, 1.0);
		//color *= vignette;
	//}
//
	//if (show_horizontal_scan_lines) {
		//float s = sin(screen_uv.y * horizontal_scan_lines_amount * PI * 2.0);
		//s = (s * 0.5 + 0.5) * 0.9 + 0.1;
		//vec4 scan_line = vec4(vec3(pow(s, horizontal_scan_lines_opacity)), 1.0);
		//color *= scan_line.rgb;
	//}
//
	//if (show_vertical_scan_lines) {
		//float s = sin(screen_uv.x * vertical_scan_lines_amount * PI * 2.0);
		//s = (s * 0.5 + 0.5) * 0.9 + 0.1;
		//vec4 scan_line = vec4(vec3(pow(s, vertical_scan_lines_opacity)), 1.0);
		//color *= scan_line.rgb;
	//}
//
	//if (show_horizontal_scan_lines || show_vertical_scan_lines) {
		//color *= boost;
	//}
//
	//// Fill the blank space of the corners, left by the curvature, with black.
	//if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		//color = corner_color.rgb;
	//}
//
	//COLOR = vec4(color, 1.0);
//}

//shader_type canvas_item;
//
//uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
//uniform vec2 screen_size = vec2(1920.0, 1080.0);
//uniform bool show_curvature = false;
//uniform float curvature_x_amount : hint_range(3.0, 15.0, 0.01) = 6.0; 
//uniform float curvature_y_amount : hint_range(3.0, 15.0, 0.01) = 4.0;
//uniform vec4 corner_color = vec4(0.0, 0.0, 0.0, 1.0);
//uniform bool show_vignette = false;
//uniform float vignette_opacity : hint_range(0.0, 1.0, 0.01) = 0.2;
//uniform bool show_horizontal_scan_lines = true;
//uniform float horizontal_scan_lines_amount : hint_range(0.0, 180.0, 0.1) = 180.0;
//uniform float horizontal_scan_lines_opacity : hint_range(0.0, 1.0, 0.01) = 0.25;
//uniform bool show_vertical_scan_lines = false;
//uniform float vertical_scan_lines_amount : hint_range(0.0, 320.0, 0.1) = 320.0;
//uniform float vertical_scan_lines_opacity : hint_range(0.0, 1.0, 0.01) = 0.1;
//uniform float boost : hint_range(1.0, 2.0, 0.01) = 1.75;
//uniform float aberration_amount : hint_range(0.0, 10.0, 0.01) = 2.75;
//
//// Added uniforms for moving static line
//uniform bool roll = true;
//uniform float roll_speed : hint_range(0.0001, 1.0) = 0.03;
//uniform float static_line_width : hint_range(0.001, 0.1) = 0.005;
//
//// Function to generate random values, used for noise in the static line
//float random(vec2 pos) { 
    //return fract(sin(dot(pos, vec2(12.9898, 78.233))) * 43758.5453);
//}
//
//vec2 uv_curve(vec2 uv) {
    //if (show_curvature) {
        //uv = uv * 2.0 - 1.0;
        //vec2 offset = abs(uv.yx) / vec2(curvature_x_amount, curvature_y_amount);
        //uv = uv + uv * offset * offset;
        //uv = uv * 0.5 + 0.5;
    //}
    //return uv;
//}
//
//void fragment() {
    //vec2 uv = uv_curve(UV);
    //vec2 screen_uv = uv_curve(SCREEN_UV);
    //vec3 color = texture(SCREEN_TEXTURE, screen_uv).rgb;
//
    //// Aberration effect
    //if (aberration_amount > 0.0) {
        //float adjusted_amount = aberration_amount / screen_size.x;
        //color.r = texture(SCREEN_TEXTURE, vec2(screen_uv.x + adjusted_amount, screen_uv.y)).r;
        //color.g = texture(SCREEN_TEXTURE, screen_uv).g;
        //color.b = texture(SCREEN_TEXTURE, vec2(screen_uv.x - adjusted_amount, screen_uv.y)).b;
    //}
//
    //// Vignette effect
    //if (show_vignette) {
        //float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
        //vignette = clamp(pow((screen_size.x / 4.0) * vignette, vignette_opacity), 0.0, 1.0);
        //color *= vignette;
    //}
//
    //// Horizontal scan lines effect
    //if (show_horizontal_scan_lines) {
        //float s = sin(screen_uv.y * horizontal_scan_lines_amount * PI * 2.0);
        //s = (s * 0.5 + 0.5) * 0.9 + 0.1;
        //vec4 scan_line = vec4(vec3(pow(s, horizontal_scan_lines_opacity)), 1.0);
        //color *= scan_line.rgb;
    //}
//
    //// Vertical scan lines effect
    //if (show_vertical_scan_lines) {
        //float s = sin(screen_uv.x * vertical_scan_lines_amount * PI * 2.0);
        //s = (s * 0.5 + 0.5) * 0.9 + 0.1;
        //vec4 scan_line = vec4(vec3(pow(s, vertical_scan_lines_opacity)), 1.0);
        //color *= scan_line.rgb;
    //}
//
    //if (show_horizontal_scan_lines || show_vertical_scan_lines) {
        //color *= boost;
    //}
//
    //// Fill the blank space of the corners, left by the curvature, with black
    //if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        //color = corner_color.rgb;
    //}

    //// Moving static line effect
    //if (roll) {
        //float line_position = mod(TIME * roll_speed, 1.0);
        //float distance_from_line = abs(screen_uv.y - line_position);
        //if (distance_from_line < static_line_width) {
            //float noise_value = random(screen_uv * vec2(100.0, 100.0) + TIME * 10.0);
            //color += noise_value * vec3(1.0);
            //// Apply distortion within the static line
            //color.rg += sin(screen_uv.y * 100.0 + TIME * 10.0) * 0.01 * noise_value;
        //}
    //}
//
    //COLOR = vec4(color, 1.0);
//}

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
uniform float horizontal_scan_lines_amount : hint_range(0.0, 180.0, 0.1) = 180.0;
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
