//A rainbow colored bar thing
//shader_type canvas_item;
//
//uniform float shine_size : hint_range(0.01, 1.0, 0.01) = 0.15;
//uniform float shine_angle : hint_range(0.0, 89.9, 0.1) = 60.0;
//
//float scale(float value, float inMin, float inMax, float outMin, float outMax) {
	//return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
//}
//
//void fragment() {
	//// Animate shine progress
	//float time = mod(TIME, 2.0 * PI); // Loop time every 2*PI seconds
	//float shine_progress = (sin(time) + 1.0) / 2.0; // Scale sin output to range [0.0, 1.0]
//
	//// Animate shine color
	//vec4 shine_color;
	//shine_color.r = (sin(time) + 1.0) / 2.0; // Red channel
	//shine_color.g = (sin(time + 2.0 * PI / 3.0) + 1.0) / 2.0; // Green channel, offset by 2/3 PI
	//shine_color.b = (sin(time + 4.0 * PI / 3.0) + 1.0) / 2.0; // Blue channel, offset by 4/3 PI
	//shine_color.a = 0.25; // Alpha channel
//
	//// Original shader logic
	//COLOR = texture(TEXTURE, UV);
	//float slope = tan(radians(shine_angle));
	//float progress = scale(shine_progress, 0.0, 1.0, -1.0 - shine_size - shine_size * slope, 1.0 * slope);
	//float shine = step(slope * UV.x - UV.y, progress + shine_size + shine_size * slope) - step(slope * UV.x - UV.y, progress);
	//COLOR.rgb = mix(COLOR.rgb, shine_color.rgb, shine * shine_color.a);
//}

//A glow flash effect
//shader_type canvas_item;
//
//uniform float speed = 1.;
//
//uniform vec4 tint : source_color = vec4(1., 1., 0., 1.);
//
//uniform float span : hint_range(0.1, 1.) = .3;
//
//float luminance(vec4 colour) {
	//return 1.0 - sqrt(0.299*colour.r*colour.r + 0.587*colour.g*colour.g + 0.114*colour.b*colour.b);
//}
//
//void fragment() {
	//vec4 colour = texture(TEXTURE, UV);
	//float target = abs(sin(TIME * PI * speed) * (1. + span));
	//if(colour.a > 0.) {
		//float lum = luminance(colour);
		//float diff = abs(lum - target);
		//float mx = clamp(1. - diff / span, 0., 1.);
		//colour = mix(colour, tint, mx);
	//}
	//
	//COLOR = colour;
//}

// HSV to RBG from https://www.rapidtables.com/convert/color/hsv-to-rgb.html
// Rotation matrix from https://en.wikipedia.org/wiki/Rotation_matrix

//Rainbow gradient
shader_type canvas_item;

void fragment() {
	float hue = UV.x * cos(radians(35.0)) - UV.y * sin(radians(35.0));
	hue = fract(hue + fract(TIME  * 0.2));
	float x = 1. - abs(mod(hue / (1./ 6.), 2.) - 1.);
	vec3 rainbow;
	if(hue < 1./6.){
		rainbow = vec3(1., x, 0.);
	} else if (hue < 1./3.) {
		rainbow = vec3(x, 1., 0);
	} else if (hue < 0.5) {
		rainbow = vec3(0, 1., x);
	} else if (hue < 2./3.) {
		rainbow = vec3(0., x, 1.);
	} else if (hue < 5./6.) {
		rainbow = vec3(x, 0., 1.);
	} else {
		rainbow = vec3(1., 0., x);
	}
	vec4 color = texture(TEXTURE, UV);
	COLOR = mix(color, vec4(rainbow, color.a), 0.5);
}