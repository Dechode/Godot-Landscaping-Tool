@tool
class_name Road
extends Path3D

@export var road_width := 12.0:
	set(value):
		road_width = value
		is_dirty = true
		call_deferred("generate_road")
@export var pole_mesh: Mesh
@export var pole_distance := 2.0:
	set(value):
		pole_distance = value
		is_dirty = true
		call_deferred("generate_road")
	
@export var pole_offset := Vector3.ZERO:
	set(value):
		pole_offset = value
		is_dirty = true
		call_deferred("generate_road")


var is_dirty := true


func _ready() -> void:
	call_deferred("generate_road")


func generate_road():
	if not is_dirty:
		return
	
	var half_width := road_width * 0.5
	var track = $Road.polygon
	track.set(0, Vector2(-half_width - 1.0, 0.0))
	track.set(1, Vector2(-half_width, 0.2))
	track.set(2, Vector2( half_width, 0.2))
	track.set(3, Vector2( half_width + 1.0, 0.0))
	$Road.polygon = track
	
	var ditch = $Ditch.polygon
	ditch.set(0, Vector2(-half_width * 1.5, -2.0))
	ditch.set(1, Vector2(-half_width - 1.0, 0.0))
	ditch.set(2, Vector2( half_width + 1.0, 0.0))
	ditch.set(3, Vector2( half_width * 1.5, -2.0))
	$Ditch.polygon = ditch
	
	var curve_length = curve.get_baked_length()
	
	var pole_count = floor(curve_length / pole_distance) if pole_distance > 0 else 0
	var rail_position = half_width + pole_distance
	
	$Poles.multimesh.mesh = pole_mesh
	
	$Poles.multimesh.instance_count = pole_count * 2
	var real_post_dist: float = curve_length / pole_count
	var offset := pole_distance * 0.5

	for i in range(pole_count * 2):
		print(i)
		var curve_distance := offset + pole_distance * i
		var position := curve.sample_baked(curve_distance, true)
		var up := curve.sample_baked_up_vector(curve_distance, true)
		var forward := position.direction_to(curve.sample_baked(curve_distance + 0.1, true))
		var basis := Basis()
		basis.y = up
		basis.x = forward.cross(up).normalized()
		basis.z = -forward
		
		if i < pole_count: 
			position += half_width * basis.x
		else:
			print("Placing poles to the other side")
			position -= half_width * basis.x
		
		position += pole_offset
		
		var t := Transform3D(basis, position)
		
		$Poles.multimesh.set_instance_transform(i, t)
	is_dirty = false


func _on_curve_changed() -> void:
	is_dirty = true
	generate_road()
