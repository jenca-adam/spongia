class_name Cuttable
extends Obj
signal cut_start(axis:int);
signal cut_end;
var cut_enabled = false
var cut_axis = 0

## axis index
# Z=0
# X=1
# Y=2 (big no no disabledaojdoksaopsadk)
const AXIS_VECS = [Vector3(0, 0, 1), Vector3(1, 0, 0), Vector3(0, 1, 0)]
const AXIS_COMP = [2, 0, 1] 
const PLANE_ORIENT = [PlaneMesh.FACE_Z, PlaneMesh.FACE_X, PlaneMesh.FACE_Y]
@export var cook_scale = 1.0
@export var cut_highlight_width = 0.005
@export var CUT_WIDTH = 0.01
@onready var cuttable_mat_z = load("res://cuttable_x.tres")
@onready var cuttable_mat_x = load("res://cuttable_x.tres")
@onready var cuttable_mat_y = load("res://cuttable_x.tres") ## all in one
@onready var cooked_mat = load("res://cooked.tres")
@onready var cut_coll_shape_z = $offset/cut_z/CollisionShape3D
@onready var cut_coll_z = $offset/cut_z
@onready var cut_coll_shape_x = $offset/cut_x/CollisionShape3D
@onready var cut_coll_x = $offset/cut_x
@onready var cut_coll_shape_y = $offset/cut_y/CollisionShape3D
@onready var cut_coll_y = $offset/cut_y
@export var cut_material_z:Material
@export var cut_material_x:Material
@export var cut_material_y:Material

var type:StringName
var volume
var _cut_colls = []
var _cut_shapes = []
var cook_time= 0.0
func get_mesh_volume(mesh: Mesh) -> float:
	var volume = 0.0
	for surface in range(mesh.get_surface_count()):
		var arrays = mesh.surface_get_arrays(surface)
		var vertices = arrays[Mesh.ARRAY_VERTEX]
		var indices= arrays[Mesh.ARRAY_INDEX]
		if not indices is PackedInt32Array or indices.is_empty():
			### assume csg is not retarded (it lowk is but ukwim)
			### couldn't find anything int he docs
			for i in range(0, vertices.size(), 3):
				volume += vertices[i].dot(vertices[i + 1].cross(vertices[i + 2])) / 6.0
		else:
			for i in range(0, indices.size(), 3):
				var a = vertices[indices[i]]
				var b = vertices[indices[i + 1]]
				var c = vertices[indices[i + 2]]
				volume += a.dot(b.cross(c)) / 6.0
	return absf(volume)
func _ready():
	if not type:
		type=name
	containable=true
	super._ready()
	
	cut_start.connect(_cut_enable)
	cut_end.connect(_cut_disable)

	_cut_colls = [cut_coll_z, cut_coll_x, cut_coll_y]
	_cut_shapes = [cut_coll_shape_z, cut_coll_shape_x, cut_coll_shape_y]
	for i in 3:
		_cut_colls[i].top_level = true
		_cut_shapes[i].shape = BoxShape3D.new()
	set_notify_transform(true)
	_update_cut_colliders()

	model.material_overlay = droppable_mat.duplicate_deep()
	model.material_overlay.next_pass.next_pass = cooked_mat.duplicate_deep()

	frozen.connect(_on_frozen)
	unfrozen.connect(_on_unfrozen)
	volume=get_mesh_volume(model.mesh)*absf(scale.x*scale.z*scale.y*model.scale.x*model.scale.z*model.scale.y)*20.0 ### bulharska konstanta
	print(name, " volume: ", volume)
	var mesh := model.mesh as Mesh
func _physics_process(delta):
	super._physics_process(delta)
	_update_cut_colliders() ### WORKAROUND: _notification doesn't seem to be called if the body's not asleep
func _process(delta):
	model.material_overlay.next_pass.next_pass.set_shader_parameter("scale", cook_scale);
	model.material_overlay.next_pass.next_pass.set_shader_parameter("alpha", 1.5*cook_time/30.0)
	
func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		_update_cut_colliders()

func _on_frozen():pass
func _on_unfrozen():pass


func _world_aabb() -> AABB:
	return model.global_transform * model.get_aabb()

func _axis_range(axis:int) -> Vector2:
	var box = _world_aabb()
	var c:int = AXIS_COMP[axis]
	return Vector2(box.position[c], box.end[c])

func _update_cut_colliders() -> void:
	if _cut_colls.is_empty() or not is_inside_tree():
		return
	var box = _world_aabb()
	for axis in range(3):
		var size = box.size
		if axis < 2:
			size.x *= 2
			size.z *= 2
		else:
			size.y *= 2
		var shape:BoxShape3D = _cut_shapes[axis].shape
		if shape.size != size:
			shape.size = size
		_cut_colls[axis].global_transform = Transform3D(Basis.IDENTITY, box.get_center())

func _cut_materials() -> Array:
	return [cuttable_mat_z, cuttable_mat_x, cuttable_mat_y]

func _cut_material_for(axis:int) -> Material:
	return [cut_material_z, cut_material_x, cut_material_y][axis]

func _cut_enable(axis):
	cut_axis = axis
	cut_enabled = true
	var old_next_next_pass=model.material_overlay.next_pass.next_pass
	model.material_overlay = _cut_materials()[axis].duplicate_deep()
	model.material_overlay.next_pass.next_pass=old_next_next_pass
func _cut_disable():
	cut_enabled = false
	var old_next_next_pass=model.material_overlay.next_pass.next_pass
	model.material_overlay = droppable_mat.duplicate_deep()
	model.material_overlay.next_pass.next_pass=old_next_next_pass
func show_cut(pos:Vector3):
	if not cut_enabled:
		return
	var mat = model.material_overlay as ShaderMaterial
	var r = _axis_range(cut_axis)
	if pos[AXIS_COMP[cut_axis]] < r.x or pos[AXIS_COMP[cut_axis]] > r.y:
		mat.set_shader_parameter("width", 0)
		return
	var n_local:Vector3 = model.global_basis.transposed() * AXIS_VECS[cut_axis]
	var len = n_local.length()
	var d = n_local.dot(model.to_local(pos)) / len
	mat.set_shader_parameter("cut_normal", n_local.normalized())
	mat.set_shader_parameter("cut_dist", d)
	mat.set_shader_parameter("width", cut_highlight_width)

func _center_instance(instance: Node3D, mesh: Mesh) -> void:
	var offset: Node3D = instance.get_node("offset")
	var model: MeshInstance3D = instance.get_node("offset/model")
	model.mesh = mesh
	var local_aabb: AABB = offset.transform * model.transform * model.get_aabb()
	var center: Vector3 = local_aabb.get_center()
	center.y=0
	offset.position -= center
	instance.position += instance.transform.basis * center

func _make_cut_plane(world_pos:Vector3) -> MeshInstance3D:
	var inst = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.orientation = PLANE_ORIENT[cut_axis]
	inst.mesh = plane
	inst.transform = model.global_transform.affine_inverse() * Transform3D(Basis.IDENTITY, world_pos)
	return inst

func cut(pos:Vector3):
	if not cut_enabled:
		return false
	var r = _axis_range(cut_axis)
	var c:int = AXIS_COMP[cut_axis]
	if pos[c] < r.x or pos[c] > r.y:
		return false

	var dir:Vector3 = AXIS_VECS[cut_axis]
	var mat = _cut_material_for(cut_axis)

	var plane1 = _make_cut_plane(pos - dir * CUT_WIDTH / 2)
	var meshes1 = MeshTools.MeshDestruction.slice_mesh(plane1, model.mesh, mat)
	var plane2 = _make_cut_plane(pos + dir * CUT_WIDTH / 2)
	var meshes2 = MeshTools.MeshDestruction.slice_mesh(plane2, meshes1[1], mat)

	var instance1 = duplicate()
	var instance2 = duplicate()
	instance1.type=type
	instance2.type=type
	instance1.cook_time = cook_time
	instance2.cook_time=cook_time
	instance1.cook_scale = cook_scale
	instance2.cook_scale = cook_scale
	_center_instance(instance1, meshes1[0])
	_center_instance(instance2, meshes2[1])
	add_sibling(instance1)
	add_sibling(instance2)
	instance1.unfreeze()
	instance2.unfreeze()
	queue_free()
	return true
