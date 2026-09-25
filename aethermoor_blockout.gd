extends Node3D

const REGION_RADIUS_M := 11970.0
const REGION_COUNT := 9
const RINGS := 24
const SEGMENTS := 96

var region_centers := [
	Vector3(0.0, 2200.0, -42000.0),
	Vector3(36000.0, 1200.0, -26000.0),
	Vector3(47000.0, 400.0, 0.0),
	Vector3(34000.0, -200.0, 31000.0),
	Vector3(0.0, -2600.0, 38000.0),
	Vector3(-34000.0, 0.0, 30000.0),
	Vector3(-47000.0, 800.0, 0.0),
	Vector3(-34000.0, 1800.0, -27000.0),
	Vector3(0.0, 2600.0, 0.0)
]

var region_scales := [
	Vector2(1.05, 0.92), Vector2(0.98, 1.02), Vector2(1.04, 0.94),
	Vector2(1.08, 0.90), Vector2(0.96, 1.04), Vector2(0.92, 1.06),
	Vector2(1.00, 0.96), Vector2(1.05, 1.00), Vector2(0.72, 0.72)
]

var region_heights := [2600.0, 1900.0, 1200.0, 900.0, 3600.0, 2100.0, 1500.0, 2300.0, 3200.0]

func _ready() -> void:
	for i in REGION_COUNT:
		_create_region(i, EclipseWorldConstants.REGION_NAMES[i], region_centers[i])
	_create_fractura(region_centers[8])

func _create_region(index: int, region_name: String, center: Vector3) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = region_name.replace(" ", "_")
	mesh_instance.mesh = _build_island_mesh(index, center)
	mesh_instance.position = center
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	mesh_instance.material_override = _build_material(index)
	$Regions.add_child(mesh_instance)
	_create_landmark(index, center, region_heights[index])

func _build_island_mesh(index: int, center: Vector3) -> ArrayMesh:
	var vertices := PackedVector3Array()
	var indices := PackedInt32Array()
	var scale := region_scales[index]
	var height := region_heights[index]
	var noise := FastNoiseLite.new()
	noise.seed = 7103 + index * 977
	noise.frequency = 0.00022
	noise.fractal_octaves = 4
	noise.fractal_gain = 0.55

	for r in RINGS + 1:
		var t := float(r) / float(RINGS)
		var radius := REGION_RADIUS_M * t
		for s in SEGMENTS:
			var a := TAU * float(s) / float(SEGMENTS)
			var edge_noise := sin(a * 3.0 + index * 1.7) * 0.045
			edge_noise += sin(a * 7.0 - index * 0.9) * 0.022
			var shape := 1.0 + edge_noise * (0.25 + 0.75 * t)

			var local_x := cos(a) * radius * scale.x * shape
			var local_z := sin(a) * radius * scale.y * shape

			var radial := 1.0 - pow(t, 2.2)
			var plateau := pow(max(0.0, 1.0 - t), 0.48) * height
			var rolling := noise.get_noise_2d(center.x + local_x, center.z + local_z) * height * (0.12 + 0.28 * radial)
			var ridge := sin((local_x + local_z) * 0.00055 + index * 1.3) * height * 0.07 * radial
			var terrace := sin(t * PI * 5.0 + index * 0.8) * height * 0.045 * radial
			var y := plateau + rolling + ridge + terrace

			if t > 0.82:
				var falloff := pow((t - 0.82) / 0.18, 1.65)
				y -= falloff * height * 0.72

			vertices.append(Vector3(local_x, y, local_z))

	for r in RINGS:
		for s in SEGMENTS:
			var a := r * SEGMENTS + s
			var b := r * SEGMENTS + (s + 1) % SEGMENTS
			var c := (r + 1) * SEGMENTS + (s + 1) % SEGMENTS
			var d := (r + 1) * SEGMENTS + s
			# Winding that produces upward-facing normals for terrain
			indices.append_array([a, b, c, a, c, d])

	# Build with SurfaceTool so normals are generated (critical for gl_compatibility lighting)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(0, indices.size(), 3):
		st.add_vertex(vertices[indices[i]])
		st.add_vertex(vertices[indices[i + 1]])
		st.add_vertex(vertices[indices[i + 2]])
	st.generate_normals()
	var mesh := st.commit()
	return mesh

func _create_fractura(center: Vector3) -> void:
	var root := Node3D.new()
	root.name = "La_Fractura"
	root.position = center + Vector3(0.0, 5000.0, 0.0)
	$Regions.add_child(root)

	var wound := StandardMaterial3D.new()
	wound.albedo_color = Color("#10151C")
	wound.emission_enabled = true
	wound.emission = Color("#D9F4FF")
	wound.emission_energy_multiplier = 3.5
	wound.roughness = 0.35
	wound.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wound.albedo_color.a = 0.78

	for angle in [-18.0, 18.0]:
		var blade := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(180.0, 12000.0, 900.0)
		blade.mesh = mesh
		blade.rotation_degrees = Vector3(0.0, 0.0, angle)
		blade.material_override = wound
		root.add_child(blade)

	var core := MeshInstance3D.new()
	var core_mesh := CylinderMesh.new()
	core_mesh.top_radius = 260.0
	core_mesh.bottom_radius = 420.0
	core_mesh.height = 9000.0
	core_mesh.radial_segments = 12
	core.mesh = core_mesh
	core.material_override = wound
	root.add_child(core)

func _create_landmark(index: int, center: Vector3, terrain_height: float) -> void:
	var root := Node3D.new()
	root.name = "Landmark_%02d" % index
	root.position = center + Vector3(0.0, terrain_height * 0.92, 0.0)
	$Regions.add_child(root)

	var stone := StandardMaterial3D.new()
	stone.albedo_color = Color("#2A3340")
	stone.roughness = 0.88
	stone.metallic = 0.05

	if index == 0:
		_add_spire(root, 0.0, 0.0, 700.0, 180.0, stone)
		_add_spire(root, -260.0, 140.0, 420.0, 110.0, stone)
		_add_spire(root, 240.0, -120.0, 520.0, 130.0, stone)
	elif index == 1:
		for x in [-360.0, 360.0]:
			_add_tower(root, x, 0.0, 650.0, 150.0, stone)
		_add_bridge(root, 0.0, 0.0, 500.0, 1200.0, stone)
	elif index == 2:
		_add_obelisk(root, 0.0, 0.0, 900.0, 210.0, stone)
	elif index == 3:
		_add_obelisk(root, -240.0, 180.0, 430.0, 150.0, stone)
		_add_obelisk(root, 260.0, -160.0, 360.0, 120.0, stone)
	elif index == 4:
		_add_spire(root, 0.0, 0.0, 1100.0, 260.0, stone)
		_add_spire(root, -430.0, 260.0, 650.0, 180.0, stone)
		_add_spire(root, 420.0, -260.0, 720.0, 190.0, stone)
	elif index == 5:
		_add_ring(root, 0.0, 0.0, 520.0, 70.0, stone)
	elif index == 6:
		_add_obelisk(root, 0.0, 0.0, 780.0, 180.0, stone)
		_add_obelisk(root, 300.0, 120.0, 430.0, 120.0, stone)
	elif index == 7:
		_add_spire(root, 0.0, 0.0, 820.0, 200.0, stone)
		_add_spire(root, -280.0, 220.0, 540.0, 140.0, stone)
		_add_spire(root, 300.0, -200.0, 620.0, 150.0, stone)
	else:
		for x in [-520.0, 0.0, 520.0]:
			_add_tower(root, x, 0.0, 900.0 if x == 0.0 else 620.0, 180.0, stone)
		_add_bridge(root, 0.0, 0.0, 620.0, 1500.0, stone)

func _add_obelisk(parent: Node3D, x: float, z: float, height: float, radius: float, material: Material) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius * 0.35
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 6
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = Vector3(x, height * 0.5, z)
	node.material_override = material
	parent.add_child(node)

func _add_spire(parent: Node3D, x: float, z: float, height: float, radius: float, material: Material) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.0
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 8
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = Vector3(x, height * 0.5, z)
	node.material_override = material
	parent.add_child(node)

func _add_tower(parent: Node3D, x: float, z: float, height: float, radius: float, material: Material) -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(radius, height, radius)
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = Vector3(x, height * 0.5, z)
	node.material_override = material
	parent.add_child(node)

func _add_bridge(parent: Node3D, x: float, z: float, y: float, length: float, material: Material) -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(length, 90.0, 140.0)
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = Vector3(x, y, z)
	node.material_override = material
	parent.add_child(node)

func _add_ring(parent: Node3D, x: float, z: float, radius: float, thickness: float, material: Material) -> void:
	var mesh := TorusMesh.new()
	mesh.inner_radius = radius
	mesh.outer_radius = radius + thickness
	mesh.rings = 48
	mesh.ring_segments = 12
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = Vector3(x, radius * 0.12, z)
	node.rotation_degrees.x = 90.0
	node.material_override = material
	parent.add_child(node)

func _build_material(index: int) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	# Slightly lifted albedos so terrain is readable under night ambient + directional light
	var palettes := [
		Color("#3A4658"), Color("#4A4A52"), Color("#5C5040"),
		Color("#6A5A48"), Color("#2E343C"), Color("#354A40"),
		Color("#404A56"), Color("#353A50"), Color("#2E3A44")
	]
	material.albedo_color = palettes[index]
	material.roughness = 0.92
	material.metallic = 0.04
	# Subtle emission so islands remain visible even when the sun is edge-on
	material.emission_enabled = true
	material.emission = palettes[index] * 0.35
	material.emission_energy_multiplier = 0.25
	return material
