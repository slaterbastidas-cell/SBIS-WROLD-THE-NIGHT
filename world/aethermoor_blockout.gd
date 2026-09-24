extends Node3D

const REGION_RADIUS := 11968.0 # ~450 km² circular reference
const REGION_HEIGHT := 120.0
const COLORS := [
	Color("#182231"), Color("#25232C"), Color("#30291F"),
	Color("#403523"), Color("#171B20"), Color("#1D2A22"),
	Color("#202B2B"), Color("#171C2A"), Color("#26303A")
]

func _ready() -> void:
	for i in EclipseWorldConstants.REGION_NAMES.size():
		_create_region(i, EclipseWorldConstants.REGION_NAMES[i], WorldManager.region_center(i))

func _create_region(index: int, name: String, center: Vector3) -> void:
	var body := MeshInstance3D.new()
	body.name = name.replace(" ", "_")
	var mesh := CylinderMesh.new()
	mesh.top_radius = REGION_RADIUS * _shape_factor(index)
	mesh.bottom_radius = mesh.top_radius * 1.08
	mesh.height = REGION_HEIGHT + abs(center.y) * 0.015
	mesh.radial_segments = 64
	mesh.rings = 4
	body.mesh = mesh
	body.position = center
	var material := StandardMaterial3D.new()
	material.albedo_color = COLORS[index]
	material.roughness = 0.95
	body.material_override = material
	add_child(body)

func _shape_factor(index: int) -> float:
	return [1.0, 0.94, 1.02, 1.08, 0.96, 0.88, 0.92, 1.04, 0.72][index]
