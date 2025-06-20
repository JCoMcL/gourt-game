shader_type canvas_item;
uniform float grow : hint_range(0,1) = 0.0;
uniform vec2 handle = vec2(0,0);


void vertex() {
		float upness = 1.0 - UV.y;
		VERTEX.x *= 1.0 + upness * grow;
		VERTEX += handle * upness;
		//FIXME: affine texture mapping
}

float stripes(float f) {
	return sin(f*100.0);
}

