extends Node3D

# Isla flotante única = escala combinada de las 9 regiones (~4050 km²)
# Radio ~36 km → diámetro ~72 km (equivalente al área total de Aethermoor)
const ISLAND_RADIUS := 36000.0
const ISLAND_THICKNESS := 4200.0
const SURFACE_Y := 0.0
const FLOAT_GAP := 8000.0

func _ready() -> void:
	_create_floating_island()
	_create_surface_detail()
	_create_rocks()
	_create_fractura()
	# Otras regiones NO se generan aquí: solo serán accesibles por portales.

func _create_floating_island() -> void:
	var root := Node3D.new()
	root.name = "Isla_Flotante_Aethermoor"
	root.position = Vector3(0.0, SURFACE_Y, 0.0)
	$Regions.add_child(root)

	# Cuerpo superior (superficie habitable)
	var top := MeshInstance3D.new()
	top.name = "IslandTop"
	var top_mesh := CylinderMesh.new()
	top_mesh.top_radius = ISLAND_RADIUS * 0.94
	top_mesh.bottom_radius = ISLAND_RADIUS
	top_mesh.height = ISLAND_THICKNESS * 0.55
	top_mesh.radial_segments = 72
	top_mesh.rings = 3
	top.mesh = top_mesh
	top.position = Vector3(0.0, ISLAND_THICKNESS * 0.275, 0.0)
	top.material_override = _stone_material(Color("#3A4658"))
	top.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	root.add_child(top)

	# Cuña inferior (isla flotante, se estrecha hacia abajo)
	var underside := MeshInstance3D.new()
	underside.name = "IslandUnderside"
	var under_mesh := CylinderMesh.new()
	under_mesh.top_radius = ISLAND_RADIUS * 0.98
	under_mesh.bottom_radius = ISLAND_RADIUS * 0.22
	under_mesh.height = ISLAND_THICKNESS * 0.85
	under_mesh.radial_segments = 72
	under_mesh.rings = 3
	underside.mesh = under_mesh
	underside.position = Vector3(0.0, -ISLAND_THICKNESS * 0.35, 0.0)
	underside.material_override = _stone_material(Color("#1E2632"))
	root.add_child(underside)

	# Anillo de acantilados exteriores (perfil irregular)
	var cliff_count := 10
	for i in cliff_count:
		var angle := TAU * float(i) / float(cliff_count)
		var dist := ISLAND_RADIUS * 0.88
		var cliff := MeshInstance3D.new()
		var cmesh := BoxMesh.new()
		cmesh.size = Vector3(
			4200.0 + (i % 3) * 800.0,
			1800.0 + (i % 4) * 400.0,
			3200.0 + (i % 2) * 600.0
		)
		cliff.mesh = cmesh
		cliff.position = Vector3(cos(angle) * dist, ISLAND_THICKNESS * 0.2, sin(angle) * dist)
		cliff.rotation_degrees = Vector3(0.0, rad_to_deg(angle) + 15.0, 0.0)
		cliff.material_override = _stone_material(Color("#2A3444"))
		root.add_child(cliff)

	# Núcleo inferior brillante (sugerencia de energía que sostiene la isla)
	var core := MeshInstance3D.new()
	core.name = "FloatCore"
	var core_mesh := CylinderMesh.new()
	core_mesh.top_radius = ISLAND_RADIUS * 0.12
	core_mesh.bottom_radius = ISLAND_RADIUS * 0.04
	core_mesh.height = FLOAT_GAP * 0.55
	core_mesh.radial_segments = 16
	core.mesh = core_mesh
	core.position = Vector3(0.0, -ISLAND_THICKNESS * 0.9 - FLOAT_GAP * 0.2, 0.0)
	var core_mat := StandardMaterial3D.new()
	core_mat.albedo_color = Color(0.08, 0.1, 0.14, 0.7)
	core_mat.emission_enabled = true
	core_mat.emission = Color("#8EC8FF")
	core_mat.emission_energy_multiplier = 2.2
	core_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	core_mat.roughness = 0.4
	core.material_override = core_mat
	root.add_child(core)

func _create_surface_detail() -> void:
	var root := Node3D.new()
	root.name = "SurfaceDetail"
	root.position = Vector3(0.0, ISLAND_THICKNESS * 0.55 + 40.0, 0.0)
	$Regions.add_child(root)

	# Mesetas interiores (dan escala y relieve)
	var plateaus := [
		{"pos": Vector3(0.0, 80.0, 0.0), "r": 9000.0, "h": 220.0, "c": Color("#4A5568")},
		{"pos": Vector3(14000.0, 40.0, 8000.0), "r": 5500.0, "h": 160.0, "c": Color("#3E4A5A")},
		{"pos": Vector3(-12000.0, 60.0, -10000.0), "r": 6000.0, "h": 180.0, "c": Color("#424E5E")},
		{"pos": Vector3(8000.0, 30.0, -15000.0), "r": 4800.0, "h": 140.0, "c": Color("#3A4656")},
		{"pos": Vector3(-16000.0, 50.0, 6000.0), "r": 5200.0, "h": 150.0, "c": Color("#404C5C")}
	]
	for p in plateaus:
		var node := MeshInstance3D.new()
		var mesh := CylinderMesh.new()
		mesh.top_radius = p.r * 0.92
		mesh.bottom_radius = p.r
		mesh.height = p.h
		mesh.radial_segments = 40
		node.mesh = mesh
		node.position = p.pos
		node.material_override = _stone_material(p.c)
		root.add_child(node)

func _create_rocks() -> void:
	var root := Node3D.new()
	root.name = "Rocas"
	root.position = Vector3(0.0, ISLAND_THICKNESS * 0.55 + 120.0, 0.0)
	$Regions.add_child(root)

	var rng_positions := [
		Vector3(2000.0, 0.0, 1500.0),
		Vector3(-3500.0, 20.0, 2800.0),
		Vector3(5000.0, 10.0, -4000.0),
		Vector3(-8000.0, 30.0, -2000.0),
		Vector3(11000.0, 5.0, 3000.0),
		Vector3(-2000.0, 40.0, 9000.0),
		Vector3(3000.0, 15.0, -9000.0),
		Vector3(-12000.0, 25.0, 4000.0),
		Vector3(9000.0, 0.0, 11000.0),
		Vector3(-5000.0, 35.0, -11000.0),
		Vector3(15000.0, 10.0, -2000.0),
		Vector3(-15000.0, 20.0, -5000.0),
		Vector3(0.0, 50.0, 6000.0),
		Vector3(7000.0, 0.0, 0.0),
		Vector3(-7000.0, 0.0, 0.0),
		Vector3(0.0, 0.0, -7000.0)
	]

	for i in rng_positions.size():
		var rock := MeshInstance3D.new()
		rock.name = "Rock_%02d" % i
		if i % 3 == 0:
			var mesh := BoxMesh.new()
			var s := 280.0 + (i % 5) * 70.0
			mesh.size = Vector3(s, s * 0.65, s * 0.85)
			rock.mesh = mesh
		else:
			var mesh := CylinderMesh.new()
			mesh.top_radius = 80.0 + (i % 4) * 40.0
			mesh.bottom_radius = 120.0 + (i % 4) * 50.0
			mesh.height = 160.0 + (i % 6) * 50.0
			mesh.radial_segments = 8
			rock.mesh = mesh
		rock.position = rng_positions[i]
		rock.rotation_degrees = Vector3((i * 17) % 40 - 20, i * 37.0, (i * 11) % 30 - 15)
		rock.material_override = _stone_material(Color("#505868") if i % 2 == 0 else Color("#3A4250"))
		root.add_child(rock)

	# Monolitos centrales (punto de referencia visual)
	for j in 4:
		var mono := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(160.0, 520.0 + j * 90.0, 160.0)
		mono.mesh = mesh
		mono.position = Vector3(-600.0 + j * 420.0, 280.0 + j * 30.0, -800.0)
		mono.material_override = _stone_material(Color("#2A3340"))
		root.add_child(mono)

func _create_fractura() -> void:
	# Herida vertical en el centro — ancla narrativa, no portal aún
	var root := Node3D.new()
	root.name = "La_Fractura"
	root.position = Vector3(0.0, ISLAND_THICKNESS * 0.55 + 200.0, 0.0)
	$Regions.add_child(root)

	var wound := StandardMaterial3D.new()
	wound.albedo_color = Color(0.06, 0.08, 0.11, 0.82)
	wound.emission_enabled = true
	wound.emission = Color("#D9F4FF")
	wound.emission_energy_multiplier = 3.8
	wound.roughness = 0.35
	wound.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	for angle in [-16.0, 16.0]:
		var blade := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(220.0, 14000.0, 1100.0)
		blade.mesh = mesh
		blade.rotation_degrees = Vector3(0.0, 0.0, angle)
		blade.material_override = wound
		root.add_child(blade)

	var core := MeshInstance3D.new()
	var core_mesh := CylinderMesh.new()
	core_mesh.top_radius = 280.0
	core_mesh.bottom_radius = 480.0
	core_mesh.height = 11000.0
	core_mesh.radial_segments = 12
	core.mesh = core_mesh
	core.material_override = wound
	root.add_child(core)

func _stone_material(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.9
	m.metallic = 0.03
	m.emission_enabled = true
	m.emission = color * 0.35
	m.emission_energy_multiplier = 0.28
	return m
