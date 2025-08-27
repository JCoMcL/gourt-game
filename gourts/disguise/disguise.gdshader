shader_type canvas_item;

uniform float top_padding_px = 0.0;
uniform float full_length_px = 730.0;
uniform float scale_adjustment_factor = 1.1;

void vertex() {
	UV = vec2(UV.y, UV.x);
	UV.y *= full_length_px * TEXTURE_PIXEL_SIZE.y * scale_adjustment_factor;
	//VERTEX.y -= top_padding_px / scale_adjustment_factor;
	// Called for every vertex the material is visible on.
}

float px_to_uv(float px) {
	return px;
}

void fragment() {
	vec2 _UV = UV;
	_UV.y += top_padding_px * TEXTURE_PIXEL_SIZE.y;
	//_UV.y *= .7;
	COLOR.rg = UV;
	//COLOR.a = 1.0;
	COLOR = texture(TEXTURE, _UV);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
