@tool
class_name TreePatch
extends Node3D

@export var amount := 20:
	set(value):
		amount = value
		call_deferred("generate_patch")
		
@export var rows := 5:
	set(value):
		rows = value
		call_deferred("generate_patch")

@export var spacing := 1.0:
	set(value):
		spacing = value
		call_deferred("generate_patch")

@export var terrain_heightmap: NoiseTexture2D:
	set(value):
		terrain_heightmap = value
		call_deferred("generate_patch")

@export var leave_mesh := Mesh:
	set(value):
		leave_mesh = value
		call_deferred("generate_patch")

@export var trunk_mesh := Mesh:
	set(value):
		trunk_mesh = value
		call_deferred("generate_patch")

@export var tree_mesh := Mesh:
	set(value):
		tree_mesh = value
		call_deferred("generate_patch")

@onready var leave_mm := $LeavesMultiMesh
@onready var trunk_mm := $TrunksMultiMesh
@onready var tree_mesh_mm := $TreeMultiMesh


func _ready() -> void:
	call_deferred("generate_patch")


func generate_patch():
	print(tree_mesh)
	print(is_instance_valid(tree_mesh))
	
	if is_instance_valid(tree_mesh):
		tree_mesh_mm.multimesh.mesh = tree_mesh
		tree_mesh_mm.multimesh.instance_count = amount
	else:
		if not is_instance_valid(leave_mesh):
			push_warning("No leave mesh set")
			return
		if not is_instance_valid(trunk_mesh):
			push_warning("No trunk mesh set")
			return
		
		leave_mm.multimesh.mesh = leave_mesh
		trunk_mm.multimesh.mesh = trunk_mesh
		leave_mm.multimesh.instance_count = amount
		trunk_mm.multimesh.instance_count = amount
	
	var pos := position
	for i in range(amount):
		pos = Vector3.ZERO
		pos.z += i
		pos.x += (i % rows)
		pos.z = (pos.z - pos.x) / rows
		pos.x -= rows * 0.5
		pos.z -= rows * 0.5
		pos *= spacing
		pos.y = 1.0 # TODO read from heightmap
		
		var basis = Basis()
		var t := Transform3D(basis, pos)
		if is_instance_valid(tree_mesh):
			tree_mesh_mm.multimesh.set_instance_transform(i, t)
		else:
			leave_mm.multimesh.set_instance_transform(i, t)
			trunk_mm.multimesh.set_instance_transform(i, t)
	

