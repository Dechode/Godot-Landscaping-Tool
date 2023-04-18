@tool
class_name Terrain
extends Node3D


@export var heightmap_texture = preload("res://heightmap.tres") as NoiseTexture2D:
	set(value):
		heightmap_texture = value
		update_terrain()

@export var terrain_size := 512:
	set(value):
		terrain_size = value
		update_terrain()
		
@export var terrain_height := 1.0:
	set(value):
		terrain_height = value
		update_terrain()

@export var subdivide_ratio := 1.0:
	set(value):
		subdivide_ratio = value
		update_terrain()


var heightmap_shape := HeightMapShape3D.new()

@onready var terrain_mesh := $StaticBody3D/TerrainMesh as MeshInstance3D
@onready var terrain_body := $StaticBody3D as StaticBody3D
@onready var collision_shape := $StaticBody3D/CollisionShape3D as CollisionShape3D


func _ready() -> void:
	collision_shape.shape = heightmap_shape
	update_terrain()


func update_terrain():
	_update_terrain_w_params(terrain_size, terrain_size, terrain_height, int(terrain_size * subdivide_ratio))


func _update_terrain_w_params(width: int, depth: int, height_ratio: float, mesh_subdivisions: int):
	if not terrain_mesh:
		push_warning("No terrain mesh found!")
		return
	if not terrain_body:
		push_warning("No terrain static body found!")
		return
	if not collision_shape:
		push_warning("No collision shape found!")
		return
	if width * depth % 4 != 0:
		push_warning("terrain width * depth must be multiple of 4!")
		return
	
	var noise = heightmap_texture.noise
	var img: Image = noise.get_image(512, 512)
	img.convert(Image.FORMAT_RF)
	img.resize(width, depth)
	
	var height_data := img.get_data().to_float32_array()
	
	if height_data.size() <= 0:
		push_warning("Could not get heightmap data from texture")
	
	for i in range(height_data.size()):
		height_data[i] *= height_ratio
		
	heightmap_shape.map_width = img.get_width()
	heightmap_shape.map_depth = img.get_height()
	heightmap_shape.map_data = height_data
	collision_shape.shape = heightmap_shape
	collision_shape.force_update_transform()
	
	terrain_mesh.mesh.size = Vector2i(width-1, depth-1)
	terrain_mesh.mesh.subdivide_width = mesh_subdivisions
	terrain_mesh.mesh.subdivide_depth = mesh_subdivisions
	
	var shader := terrain_mesh.get_active_material(0)
	var normalmap := heightmap_texture.duplicate(true)
	normalmap.as_normal_map = true
	shader.set_shader_parameter("terrain_max_height", height_ratio)
	shader.set_shader_parameter("terrain_heightmap", heightmap_texture)
	shader.set_shader_parameter("terrain_normalmap", normalmap)
	
	var pfx_shader = $GPUParticles3D.process_material # as ShaderMaterial
	print("particle shader = " + str(pfx_shader))
	pfx_shader.set_shader_parameter("terrain_heightmap", heightmap_texture)
	pfx_shader.set_shader_parameter("terrain_normalmap", normalmap)
	pfx_shader.set_shader_parameter("terrain_size", Vector2(width, depth))
	pfx_shader.set_shader_parameter("terrain_max_height", height_ratio)
	

