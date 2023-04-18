@tool
class_name TreeGen
extends Node3D

@export var total_tree_height := 20.0:
	set(value):
		total_tree_height = value
		generate_tree()
		
@export var leaves_radius := 5.0:
	set(value):
		leaves_radius = value
		generate_tree()
		
@export var trunk_radius := 0.5:
	set(value):
		trunk_radius = value
		generate_tree()
		
@export_range(0.0, 1.0) var leave_coverage := 0.5:
	set(value):
		leave_coverage = value
		generate_tree()

@export var leave_mesh: Mesh:
	set(value):
		leave_mesh = value
		generate_tree()

@export var trunk_mesh: Mesh:
	set(value):
		trunk_mesh = value
		generate_tree()

var leave_height := 15.0
var trunk_height := 5.0

@onready var leaves := $TreeLeaves
@onready var trunk := $TreeTrunk
@onready var output_mesh := $Output/MeshInstance3D

func _ready() -> void:
	call_deferred("generate_tree")


func generate_tree():
	if not leave_mesh or not trunk_mesh:
		push_warning("No meshes set")
		return
	
	leaves.mesh = leave_mesh
	trunk.mesh = trunk_mesh
	
	leave_height = total_tree_height * leave_coverage
	trunk_height = total_tree_height - leave_height
	
	leaves.mesh.size = leaves_radius
	leaves.mesh.section_length = leave_height * 0.5
	
	trunk.mesh.height = trunk_height
	trunk.mesh.bottom_radius = trunk_radius
	trunk.mesh.top_radius = trunk_radius * 0.7
	
	trunk.position.y = trunk_height * 0.5
	leaves.position.y = trunk_height + leave_height * 0.5
	export_tree()


func export_tree():
#	print(trunk.mesh.surface_get_arrays(0))
	
	pass
