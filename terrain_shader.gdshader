shader_type spatial;

uniform sampler2D heightmap;
uniform sampler2D terrain_normalmap;
uniform float height_ratio = 1.0;

uniform sampler2D terrain_color;

//uniform sampler2D splatmap;
//uniform sampler2D texture_1;
//uniform sampler2D texture_2;
//uniform sampler2D texture_3;
//uniform sampler2D texture_4;

varying float vertex_y;

vec3 unpack_normals(vec4 normal){
	vec3 n = normal.xzy * 2.0 - vec3(1.0);
	n.z *= -1.0;
	return n;
}

void fragment() {
	vec3 normal = unpack_normals(texture(terrain_normalmap, UV));
	normal = normalize(normal);
	
	float pos = vertex_y / height_ratio;
	vec3 color = texture(terrain_color, vec2(pos, 0)).rgb;
	
	
//	vec4 smt = texture(splatmap, UV);
//	vec3 c1 = mix(texture(texture_1, UV).rga, texture(texture_2, UV).rga, smt.r);
//	vec3 c2 = mix(c1, texture(texture_2, UV).rga, smt.g);
//	vec3 c3 = mix(c2, texture(texture_3, UV).rga, smt.b);
//	vec3 c4 = mix(c3, texture(texture_4, UV).rga, smt.a);
	
	NORMAL = (VIEW_MATRIX * vec4(normal, 0.0)).xyz;
	ALBEDO = color;
//	ALBEDO = c4.xyz;
}

void vertex() {
	VERTEX.y += texture(heightmap, UV).r * height_ratio;
	vertex_y = VERTEX.y;
	vec4 normalmap = texture(terrain_normalmap, UV);
	NORMAL = unpack_normals(normalmap);
}
