shader_type canvas_item;

void fragment() {
	float average = (COLOR.r + COLOR.b + COLOR.g) / 3.0;
	COLOR.r = average;
	COLOR.b = average + 0.01;
	COLOR.g = average;
}