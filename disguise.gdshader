shader_type canvas_item;

void vertex() {
	UV = vec2(UV.y, UV.x);
	// Called for every vertex the material is visible on.
}

void fragment() {
	//UV = vec2(UV.y, UV.x);
	COLOR.rg = UV;
	COLOR.a = 1.0;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
