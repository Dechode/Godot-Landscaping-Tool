shader_type particles;

uniform sampler2D terrain_heightmap;
uniform sampler2D terrain_normalmap;
uniform vec2 terrain_size;
uniform float terrain_max_height;

uniform float rows;
uniform float spacing;
uniform bool orient_to_normal;
uniform vec3 scale = vec3(1.0);
uniform vec3 offset = vec3(0.0);
uniform float randomize_position = 0.0;
uniform float randomize_rotation = 0.0;

uniform sampler2D foliage_patch_map;


float get_height(vec2 pos) {
	pos -= 0.5 * terrain_size;
	pos /= terrain_size;	
	return terrain_max_height * texture(terrain_heightmap, pos).r;
}

vec3 unpack_normalmap(vec3 rgb) {
vec3 n = rgb.xzy * 2.0 - vec3(1.0);
n.z *= -1.0;
return n;
}	

vec3 get_normal(vec2 pos) {
	pos -= 0.5 * terrain_size;
	pos /= terrain_size;
	return unpack_normalmap(texture(terrain_normalmap, pos).rgb);
}

void start() {
	// Place start code here.
	vec3 pos = vec3(0.0, 0.0, 0.0);
	pos.z = float(INDEX);
	pos.x = mod(pos.z, rows);
	pos.z = (pos.z - pos.x) / rows;
	pos.x -= rows * 0.5;
	pos.z -= rows * 0.5;

	pos *= spacing;
	
	pos.x += EMISSION_TRANSFORM[3][0] - mod(EMISSION_TRANSFORM[3][0], spacing);
	pos.z += EMISSION_TRANSFORM[3][2] - mod(EMISSION_TRANSFORM[3][2], spacing);
	
	vec3 noise = texture(terrain_heightmap, pos.xz * 0.1).rgb;
	pos.x += noise.z * spacing * randomize_position; // * instance_pos_randomize;
	pos.z -= noise.x * spacing * randomize_position; // * instance_pos_randomize;
	pos.y = get_height(pos.xz);
	
	pos += offset;
	
	if (orient_to_normal == true)
	{
	TRANSFORM[1].xyz = get_normal(pos.xz); //* instance_orientation_influence;
	TRANSFORM[2].xyz = sin(get_normal(pos.zx) * faceforward(vec3(1.0),TRANSFORM[1].xyz, vec3(0.0, 0.0, 1.0))); //* instance_orientation_influence ;
	TRANSFORM[0].xyz = sin(get_normal(pos.zx) * faceforward(vec3(1.0),TRANSFORM[1].xyz, vec3(1.0, 0.0, 0.0))); //* instance_orientation_influence ;
	} else {
	TRANSFORM[0].xyz = vec3(0.0);
	TRANSFORM[1].xyz = vec3(0.0);
	TRANSFORM[2].xyz = vec3(0.0);
	}
	
	TRANSFORM[3][0] = pos.x;
	TRANSFORM[3][1] = pos.y;
	TRANSFORM[3][2] = pos.z;
	
	TRANSFORM[0][0] = cos(noise.x * randomize_rotation) * scale.x; // instance_rot_randomize 
	TRANSFORM[0][2] = -sin(noise.x * randomize_rotation) * scale.x;
	TRANSFORM[2][0] = sin(noise.z * randomize_rotation) * scale.z;
	TRANSFORM[2][2] = cos(noise.z * randomize_rotation) * scale.z;
	
	TRANSFORM[0][0] = scale.x;
	TRANSFORM[1][1] = scale.y;
	TRANSFORM[2][2] = scale.z;
}
//void process() {
//	// Place process code here.
//}


