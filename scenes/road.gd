@tool
class_name Road
extends Path3D

@export var road_width := 12.0:
	set(value):
		road_width = value
		is_dirty = true
		call_deferred("generate_road")

@export var pole_mesh: Mesh:
	set(value):
		pole_mesh = value
		is_dirty = true
		call_deferred("generate_road")

@export var pole_height := 1.0:
	set(value):
		pole_height = value
		is_dirty = true
		call_deferred("generate_road")

@export var pole_radius := 0.03:
	set(value):
		pole_radius = value
		is_dirty = true
		call_deferred("generate_road")
	
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

@export var rail_width := 0.1:
	set(value):
		rail_width = value
		is_dirty = true
		call_deferred("generate_road")

@export var rail_height := 0.4:
	set(value):
		rail_height = value
		is_dirty = true
		call_deferred("generate_road")

var is_dirty := true


func _ready() -> void:
	call_deferred("generate_road")


func generate_road():
	if not is_dirty:
		return
	
	var road_half_width := road_width * 0.5
	var track = $Road.polygon
	track.set(0, Vector2(-road_half_width - 1.0, 0.0))
	track.set(1, Vector2(-road_half_width, 0.2))
	track.set(2, Vector2( road_half_width, 0.2))
	track.set(3, Vector2( road_half_width + 1.0, 0.0))
	$Road.polygon = track
	
	var ditch = $Ditch.polygon
	ditch.set(0, Vector2(-road_half_width * 1.5, -2.0))
	ditch.set(1, Vector2(-road_half_width - 1.0, 0.0))
	ditch.set(2, Vector2( road_half_width + 1.0, 0.0))
	ditch.set(3, Vector2( road_half_width * 1.5, -2.0))
	$Ditch.polygon = ditch
	
	var rail_half_width := rail_width * 0.5
	var rail_half_height := rail_height * 0.5
	
	var rail1 = $Rail1.polygon
	rail1.set(0, Vector2(-road_half_width - rail_half_width, pole_height * 0.5 - rail_half_height + pole_offset.y))
	rail1.set(1, Vector2(-road_half_width - rail_half_width, pole_height * 0.5 + rail_half_height + pole_offset.y))
	rail1.set(2, Vector2(-road_half_width + rail_half_width, pole_height * 0.5 + rail_half_height + pole_offset.y))
	rail1.set(3, Vector2(-road_half_width + rail_half_width, pole_height * 0.5 - rail_half_height + pole_offset.y))
	$Rail1.polygon = rail1
	
	var rail2 = $Rail2.polygon
	rail2.set(0, Vector2(road_half_width - rail_half_width, pole_height * 0.5 - rail_half_height + pole_offset.y))
	rail2.set(1, Vector2(road_half_width - rail_half_width, pole_height * 0.5 + rail_half_height + pole_offset.y))
	rail2.set(2, Vector2(road_half_width + rail_half_width, pole_height * 0.5 + rail_half_height + pole_offset.y))
	rail2.set(3, Vector2(road_half_width + rail_half_width, pole_height * 0.5 - rail_half_height + pole_offset.y))
	$Rail2.polygon = rail2
	
	var curve_length = curve.get_baked_length()
	var pole_count: int = floor(curve_length / pole_distance) if pole_distance > 0 else 0
	
	pole_mesh.sections = 2
	pole_mesh.section_length = 0.5 * pole_height
	pole_mesh.radius = pole_radius
	
	$Poles.multimesh.mesh = pole_mesh
	$Poles.multimesh.instance_count = pole_count * 2
	
	var offset := pole_distance * 0.5
	
	for i in range(pole_count):
		var curve_distance := offset + pole_distance * i + (i % 2)
		var pos := curve.sample_baked(curve_distance, true)
		var up := curve.sample_baked_up_vector(curve_distance, true)
		var forward := pos.direction_to(curve.sample_baked(curve_distance + 0.1, true))
		var basis := Basis()
		basis.y = up
		basis.x = forward.cross(up).normalized()
		basis.z = -forward
		
		if i % 2 == 0:
			pos += road_half_width * basis.x
		else:
			pos -= road_half_width * basis.x
		
		pos += pole_offset
		
		var t := Transform3D(basis, pos)
		
		$Poles.multimesh.set_instance_transform(i, t)
	
	is_dirty = false


func _on_curve_changed() -> void:
	is_dirty = true
	call_deferred("generate_road")

