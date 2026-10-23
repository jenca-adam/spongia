class_name Cuttable
extends Obj
signal cut_start(axis:int);
signal cut_end;
var cut_enabled = false
var model_min;
var model_max;
var cut_axis =0

## AXIS INDEXING::
# Z=0
# X=1
# Y=2

## because i'm stupid
const THRESH=0.1
@export var cut_highlight_width = 0.01
@export var CUT_WIDTH = 0.01
@onready var cuttable_mat_z = load("res://cuttable_z.tres")
@onready var cut_coll_shape_z = $offset/cut_z/CollisionShape3D
@onready var cut_coll_z = $offset/cut_z
@onready var cuttable_mat_x = load("res://cuttable_x.tres")
@onready var cut_coll_shape_x = $offset/cut_x/CollisionShape3D
@onready var cut_coll_x = $offset/cut_x
@export var cut_material_z:Material
@export var cut_material_x:Material
func setup_cut_coll(axis, cut_coll, cut_coll_shape,aabbx):
	var cut_shape:=BoxShape3D.new()
	cut_shape.size=Vector3(aabbx.size.x*(2 if axis==1 else 1), aabbx.size.y, aabbx.size.z*(2 if axis==0 else 1))
	cut_coll_shape.shape=cut_shape
	cut_coll.position=aabbx.position+aabbx.size/2
	
func _ready():
	super._ready()
	print(name, model)
	var aabbx = model.transform*model.get_aabb()
	model_min = aabbx.position
	model_max = aabbx.end
	print(name, model_min, model_max)
	cut_start.connect(_cut_enable)
	cut_end.connect(_cut_disable)
	setup_cut_coll(0, cut_coll_z, cut_coll_shape_z, aabbx)
	setup_cut_coll(1, cut_coll_x, cut_coll_shape_x, aabbx)
	model.material_overlay=droppable_mat.duplicate_deep()
func _cut_enable(axis):
	cut_axis=axis
	cut_enabled=true
	if (axis==0):
		
		model.material_overlay=cuttable_mat_z.duplicate_deep()
		model.material_overlay.set_shader_parameter("model_zmin", model_min.z)
		model.material_overlay.set_shader_parameter("model_zmax", model_max.z)
	if (axis==1):
		model.material_overlay=cuttable_mat_x.duplicate_deep()
		model.material_overlay.set_shader_parameter("model_xmin", model_min.x)
		model.material_overlay.set_shader_parameter("model_xmax", model_max.x)
func _cut_disable():
	cut_enabled=false
	model.material_overlay=droppable_mat.duplicate_deep()
func show_cut_z(pos:Vector3):
	if cut_enabled:
		pos=model.to_local(pos)
		assert(model_min.z<model_max.z)
		
		if pos.z<model_min.z or pos.z>model_max.z:
			return
		var target = (pos.z-model_min.z)/(model_max.z-model_min.z)
		print(target)
		model.material_overlay.set_shader_parameter("z_target", target)
		model.material_overlay.set_shader_parameter("width", cut_highlight_width)
		
func show_cut_x(pos:Vector3):
	if cut_enabled:
		pos=model.to_local(pos)
		if pos.x<model_min.x or pos.x>model_max.x:
			return
		var target = (pos.x-model_min.x)/(model_max.x-model_min.x)
		model.material_overlay.set_shader_parameter("x_target", target)
		model.material_overlay.set_shader_parameter("width", cut_highlight_width)
func show_cut(pos:Vector3):
	
	if cut_axis==0:
		show_cut_z(pos)
	elif cut_axis==1:
		show_cut_x(pos)
func _center_instance(instance: Node3D, mesh: Mesh) -> void:
	### IGNORE Y DIRECTION
	var offset: Node3D = instance.get_node("offset")
	var model: MeshInstance3D = instance.get_node("offset/model")
	model.mesh = mesh
	var local_aabb: AABB = offset.transform * model.transform * model.get_aabb()
	var center: Vector3 = local_aabb.get_center()
	center.y=0
	offset.position -= center
	instance.position += instance.transform.basis * center
func cut(pos:Vector3):
	if not cut_enabled:
		return
	var meshes1;
	var meshes2;
	pos=model.to_local(pos)
	if cut_axis==0:
		if pos.z<model_min.z or pos.z>model_max.z:
			return
		var plane_mesh_instance := MeshInstance3D.new()
		var plane_mesh := PlaneMesh.new()
		plane_mesh_instance.position=pos+Vector3(0.,0.,-CUT_WIDTH/2)
		plane_mesh.orientation=PlaneMesh.FACE_Z
		plane_mesh_instance.mesh = plane_mesh
		meshes1 = MeshTools.MeshDestruction.slice_mesh(plane_mesh_instance, model.mesh, cut_material_z)
		plane_mesh_instance.position=pos+Vector3(0.,0.,CUT_WIDTH/2)
		
		meshes2 = MeshTools.MeshDestruction.slice_mesh(plane_mesh_instance, meshes1[1],cut_material_z)
	elif cut_axis==1:
		if pos.x<model_min.x or pos.x>model_max.x:
			return
		var plane_mesh_instance := MeshInstance3D.new()
		var plane_mesh := PlaneMesh.new()
		plane_mesh_instance.position=pos+Vector3(-CUT_WIDTH/2,0,0)
		plane_mesh.orientation=PlaneMesh.FACE_X
		plane_mesh_instance.mesh = plane_mesh
		meshes1 = MeshTools.MeshDestruction.slice_mesh(plane_mesh_instance, model.mesh, cut_material_x)
		plane_mesh_instance.position=pos+Vector3(CUT_WIDTH/2,0,0)
		meshes2 = MeshTools.MeshDestruction.slice_mesh(plane_mesh_instance, meshes1[1],cut_material_x)
	var instance1 = duplicate()
	var instance2 = duplicate()
	var mesh1 = meshes1[0]
	var mesh2 = meshes2[1]
	_center_instance(instance1, mesh1)
	_center_instance(instance2, mesh2)
	add_sibling(instance1)
	add_sibling(instance2)

	queue_free()
		
