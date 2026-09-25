extends Node3D

# Isla principal ~ tamaño Caracas (diámetro ~24 km, radio ~12 km)
const ISLAND_RADIUS := 12000.0
const ISLAND_HEIGHT := 1800.0

func _ready() -> void:
	_create_caracas_island()
	_create_rocks()
	# Conservar el resto de regiones como siluetas lejanas (no se eliminan)
	_create_distant_regions()
	_create_fractura()

func _create_caracas_island() -> void:
	var root := Node3D.new()
	root.name = "Isla_Caracas"
	# Centrada bajo la vista inicial: cámara en (0, 6500, 15500) mirando al origen
	root.position = Vector3(0.0, 0.0, 0.0)
	$Regions.add_child(root)

	# Cuerpo principal de la isla (CylinderMesh siempre tiene normales → visible en Web)
	var body := MeshInstance3D.new()
	body.name = "IslandBody"
	var mesh := CylinderMesh.new()
	mesh.top_radius = ISLAND_RADIUS * 0.92
	mesh.bottom_radius = ISLAND_RADIUS
	mesh.height = ISLAND_HEIGHT
	mesh.radial_segments = 64
	mesh.rings = 4
	body.mesh = mesh
	body.position = Vector3(0.0, ISLAND_HEIGHT * 0.5, 0.0)
	body.material_override = _stone_material(Color("#3A4658"))
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	root.add_child(body)

	# Meseta superior un poco más clara
	var plateau := MeshInstance3D.new()
	plateau.name = "Plateau"
	var pmesh := CylinderMesh.new()
	pmesh.top_radius = ISLAND_RADIUS * 0.55
	pmesh.bottom_radius = ISLAND_RADIUS * 0.62
	pmesh.height = 280.0
	pmesh.radial_segments = 48
	plateau.mesh = pmesh
	plateau.position = Vector3(0.0, ISLAND_HEIGHT + 80.0, 0.0)
	plateau.material_override = _stone_material(Color("#4A5568"))
	root.add_child(plateau)

	# Acantilados / bordes irregulares (cajas)
	var cliff_offsets := [
		Vector3(9000.0, 400.0, 2000.0),
		Vector3(-8500.0, 350.0, -1500.0),
		Vector3(2000.0, 500.0, 9500.0),
		Vector3(-1500.0, 300.0, -9000.0),
		Vector3(7000.0, 450.0, -7000.0),
		Vector3(-7500.0, 380.0, 6500.0)
	]
	for i in cliff_offsets.size():
		var cliff := MeshInstance3D.new()
		var cmesh := BoxMesh.new()
		cmesh.size = Vector3(2200.0 + i * 180.0, 900.0 + i * 120.0, 1800.0)
		cliff.mesh = cmesh
		cliff.position = cliff_offsets[i] + Vector3(0.0, ISLAND_HEIGHT * 0.35, 0.0)
		cliff.rotation_degrees = Vector3(0.0, i * 35.0, 0.0)
		cliff.material_override = _stone_material(Color("#2E3848"))
		root.add_child(cliff)

func _create_rocks() -> void:
	var root := Node3D.new()
	root.name = "Rocas"
	root.position = Vector3(0.0, ISLAND_HEIGHT + 200.0, 0.0)
	$Regions.add_child(root)

	var rock_positions := [
		Vector3(0.0, 0.0, 0.0),
		Vector3(1800.0, 40.0, 900.0),
		Vector3(-1600.0, 20.0, -1200.0),
		Vector3(900.0, 60.0, -2000.0),
		Vector3(-2200.0, 30.0, 1500.0),
		Vector3(3200.0, 10.0, -800.0),
		Vector3(-800.0, 50.0, 2800.0),
		Vector3(500.0, 25.0, 3500.0),
		Vector3(-3500.0, 15.0, -500.0),
		Vector3(2500.0, 35.0, 2200.0),
		Vector3(-1200.0, 45.0, -2800.0),
		Vector3(4000.0, 5.0, 500.0)
	]

	for i in rock_positions.size():
		var rock := MeshInstance3D.new()
		rock.name = "Rock_%02d" % i
		# Formas variadas: cajas y cilindros cortos
		if i % 3 == 0:
			var mesh := BoxMesh.new()
			var s := 180.0 + (i % 5) * 40.0
			mesh.size = Vector3(s, s * 0.7, s * 0.9)
			rock.mesh = mesh
		else:
			var mesh := CylinderMesh.new()
			mesh.top_radius = 60.0 + (i % 4) * 25.0
			mesh.bottom_radius = 90.0 + (i % 4) * 30.0
			mesh.height = 120.0 + (i % 6) * 35.0
			mesh.radial_segments = 8
			rock.mesh = mesh
		rock.position = rock_positions[i]
		rock.rotation_degrees = Vector3((i * 17) % 40 - 20, i * 40.0, (i * 11) % 30 - 15)
		rock.material_override = _stone_material(Color("#505868") if i % 2 == 0 else Color("#3A4250"))
		root.add_child(rock)

	# Un par de monolitos más altos (silueta)
	for j in 3:
		var mono := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(120.0, 420.0 + j * 80.0, 120.0)
		mono.mesh = mesh
		mono.position = Vector3(-400.0 + j * 450.0, 200.0 + j * 40.0, -600.0)
		mono.material_override = _stone_material(Color("#2A3340"))
		root.add_child(mono)

func _create_distant_regions() -> void:
	# Siluetas lejanas de las otras regiones (no se eliminan del diseño)
	var centers := [
		Vector3(0.0, 2200.0, -42000.0),
		Vector3(36000.0, 1200.0, -26000.0),
		Vector3(47000.0, 400.0, 0.0),
		Vector3(34000.0, -200.0, 31000.0),
		Vector3(0.0, -2600.0, 38000.0),
		Vector3(-34000.0, 0.0, 30000.0),
		Vector3(-47000.0, 800.0, 0.0),
		Vector3(-34000.0, 1800.0, -27000.0)
	]
	var names := [
		"Villa_Eclipse", "Antigua_Ciudadela", "Cleopatt", "Valle_Desierto",
		"Refugio_Caidos", "Isla_Paz", "Biblioteca", "Cosmos"
	]
	var colors := [
		Color("#3A4658"), Color("#4A4A52"), Color("#5C5040"), Color("#6A5A48"),
		Color("#2E343C"), Color("#354A40"), Color("#404A56"), Color("#353A50")
	]
	for i in centers.size():
		var body := MeshInstance3D.new()
		body.name = names[i]
		var mesh := CylinderMesh.new()
		mesh.top_radius = 9000.0
		mesh.bottom_radius = 10000.0
		mesh.height = 800.0 + abs(centers[i].y) * 0.2
		mesh.radial_segments = 32
		body.mesh = mesh
		body.position = centers[i]
		body.material_override = _stone_material(colors[i])
		$Regions.add_child(body)

func _create_fractura() -> void:
	var root := Node3D.new()
	root.name = "La_Fractura"
	root.position = Vector3(0.0, 4500.0, 0.0)
	$Regions.add_child(root)

	var wound := StandardMaterial3D.new()
	wound.albedo_color = Color(0.06, 0.08, 0.11, 0.8)
	wound.emission_enabled = true
	wound.emission = Color("#D9F4FF")
	wound.emission_energy_multiplier = 3.5
	wound.roughness = 0.35
	wound.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	for angle in [-18.0, 18.0]:
		var blade := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(180.0, 10000.0, 900.0)
		blade.mesh = mesh
		blade.rotation_degrees = Vector3(0.0, 0.0, angle)
		blade.material_override = wound
		root.add_child(blade)

	var core := MeshInstance3D.new()
	var core_mesh := CylinderMesh.new()
	core_mesh.top_radius = 220.0
	core_mesh.bottom_radius = 380.0
	core_mesh.height = 8000.0
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
	m.emission = color * 0.4
	m.emission_energy_multiplier = 0.3
	return m
