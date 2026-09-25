extends Node3D

# Zona de inicio — Isla del Alba (referencia: ciudad blanca sobre roca oscura flotante)
# Escala: diámetro ~2400 m (muy por encima de cualquier estadio; ~3×+ en espíritu monumental)

const R := 1200.0          # radio superficie
const H_ROCK := 900.0      # grosor masa rocosa
const H_CITY := 180.0      # altura terrazas

func _ready() -> void:
	var root := Node3D.new()
	root.name = "Isle_of_Dawn"
	$Regions.add_child(root)

	_build_rock_mass(root)
	_build_city(root)
	_build_underside_lights(root)
	_build_portal_ring(root)
	_build_void_plane(root)

# ---------------------------------------------------------------------------
# Masa rocosa oscura (base flotante + estalactitas)
# ---------------------------------------------------------------------------
func _build_rock_mass(parent: Node3D) -> void:
	# Disco superior de roca
	_cyl(parent, "RockTop", Vector3(0, 0, 0), R, R * 0.98, 120.0, Color(0.12, 0.11, 0.10))
	# Cuerpo
	_cyl(parent, "RockBody", Vector3(0, -H_ROCK * 0.35, 0), R * 0.98, R * 0.55, H_ROCK * 0.7, Color(0.09, 0.08, 0.08))
	# Cuña inferior
	_cyl(parent, "RockTip", Vector3(0, -H_ROCK * 0.85, 0), R * 0.55, R * 0.08, H_ROCK * 0.5, Color(0.07, 0.06, 0.06))

	# Estalactitas / pilares colgantes
	for i in 16:
		var a := TAU * float(i) / 16.0 + 0.1
		var dist := R * (0.35 + float(i % 4) * 0.12)
		var len := 400.0 + float(i % 5) * 180.0
		_cyl(parent, "Stalactite_%d" % i,
			Vector3(cos(a) * dist, -H_ROCK * 0.5 - len * 0.35, sin(a) * dist),
			18.0 + float(i % 3) * 10.0,
			40.0 + float(i % 3) * 15.0,
			len,
			Color(0.06, 0.05, 0.05))

# ---------------------------------------------------------------------------
# Ciudad blanca / dorada (domo, anillos, torres, terrazas)
# ---------------------------------------------------------------------------
func _build_city(parent: Node3D) -> void:
	var city := Node3D.new()
	city.name = "City"
	city.position = Vector3(0, 80, 0)
	parent.add_child(city)

	# Plaza / anillos concéntricos
	_cyl(city, "Plaza", Vector3(0, 10, 0), R * 0.72, R * 0.75, 40.0, Color(0.92, 0.90, 0.85))
	_cyl(city, "RingA", Vector3(0, 50, 0), R * 0.55, R * 0.58, 30.0, Color(0.88, 0.86, 0.80))
	_cyl(city, "RingB", Vector3(0, 90, 0), R * 0.38, R * 0.42, 30.0, Color(0.90, 0.88, 0.82))

	# Domo central
	_cyl(city, "DomeBase", Vector3(0, 180, 0), 220.0, 260.0, 120.0, Color(0.95, 0.93, 0.88))
	_sphere(city, "Dome", Vector3(0, 320, 0), 240.0, Color(0.96, 0.94, 0.90), Color(1.0, 0.95, 0.75), 0.6)
	# Aguja del domo
	_cyl(city, "DomeSpire", Vector3(0, 520, 0), 8.0, 28.0, 160.0, Color(0.85, 0.78, 0.55))

	# Torres / minaretes alrededor del domo
	for i in 8:
		var a := TAU * float(i) / 8.0
		var d := 380.0
		var x := cos(a) * d
		var z := sin(a) * d
		_cyl(city, "Minaret_%d" % i, Vector3(x, 280, z), 22.0, 32.0, 420.0, Color(0.93, 0.91, 0.86))
		_cyl(city, "MinaretCap_%d" % i, Vector3(x, 520, z), 6.0, 26.0, 80.0, Color(0.80, 0.72, 0.48))

	# Torres exteriores (anillo amplio)
	for i in 12:
		var a := TAU * float(i) / 12.0 + 0.2
		var d := R * 0.62
		var x := cos(a) * d
		var z := sin(a) * d
		var h := 280.0 + float(i % 4) * 60.0
		_cyl(city, "OuterTower_%d" % i, Vector3(x, h * 0.5 + 20.0, z), 28.0, 40.0, h, Color(0.91, 0.89, 0.84))
		_cyl(city, "OuterSpire_%d" % i, Vector3(x, h + 60.0, z), 5.0, 20.0, 70.0, Color(0.82, 0.74, 0.50))

	# Bloques de “edificios” en terrazas
	for i in 20:
		var a := TAU * float(i) / 20.0
		var d := R * 0.48
		var x := cos(a) * d
		var z := sin(a) * d
		var h := 90.0 + float(i % 5) * 35.0
		_box(city, "House_%d" % i, Vector3(x, 40 + h * 0.5, z), Vector3(70, h, 60), Color(0.90, 0.88, 0.82))

	# Muralla baja perimetral
	_cyl(city, "Wall", Vector3(0, 35, 0), R * 0.88, R * 0.92, 50.0, Color(0.85, 0.82, 0.76))

	# Puentes radiales simples
	for i in 4:
		var a := TAU * float(i) / 4.0
		var mid := Vector3(cos(a) * R * 0.4, 55, sin(a) * R * 0.4)
		_box(city, "Bridge_%d" % i, mid, Vector3(abs(cos(a)) * 500 + 80, 20, abs(sin(a)) * 500 + 80), Color(0.88, 0.86, 0.80))

# ---------------------------------------------------------------------------
# Luces cálidas en la roca inferior (como la referencia)
# ---------------------------------------------------------------------------
func _build_underside_lights(parent: Node3D) -> void:
	for i in 24:
		var a := TAU * float(i) / 24.0
		var dist := R * (0.25 + float(i % 5) * 0.1)
		var y := -200.0 - float(i % 6) * 90.0
		var pos := Vector3(cos(a) * dist, y, sin(a) * dist)
		_sphere(parent, "WarmLight_%d" % i, pos, 12.0 + float(i % 3) * 4.0,
			Color(0.15, 0.10, 0.05), Color(1.0, 0.75, 0.35), 3.5)
		var light := OmniLight3D.new()
		light.light_color = Color(1.0, 0.72, 0.35)
		light.light_energy = 2.2
		light.omni_range = 350.0
		light.position = pos
		parent.add_child(light)

# ---------------------------------------------------------------------------
# Anillo portal bajo la isla (referencia)
# ---------------------------------------------------------------------------
func _build_portal_ring(parent: Node3D) -> void:
	var ring := MeshInstance3D.new()
	ring.name = "PortalRing"
	var t := TorusMesh.new()
	t.inner_radius = 380.0
	t.outer_radius = 480.0
	t.rings = 48
	t.ring_segments = 20
	ring.mesh = t
	ring.position = Vector3(0, -H_ROCK * 1.35, 0)
	ring.rotation_degrees.x = 90.0
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.1, 0.12, 0.08, 0.85)
	mat.emission_enabled = true
	mat.emission = Color(0.85, 1.0, 0.45)
	mat.emission_energy_multiplier = 4.0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring.material_override = mat
	parent.add_child(ring)

	# Núcleo del anillo
	_sphere(parent, "PortalCore", Vector3(0, -H_ROCK * 1.35, 0), 40.0,
		Color(0.1, 0.12, 0.05), Color(1.0, 1.0, 0.6), 6.0)

	var portal_light := OmniLight3D.new()
	portal_light.light_color = Color(0.85, 1.0, 0.5)
	portal_light.light_energy = 4.0
	portal_light.omni_range = 1200.0
	portal_light.position = Vector3(0, -H_ROCK * 1.35, 0)
	parent.add_child(portal_light)

# ---------------------------------------------------------------------------
# Plano de “océano / vacío” oscuro (suelo visual lejano)
# ---------------------------------------------------------------------------
func _build_void_plane(parent: Node3D) -> void:
	var water := MeshInstance3D.new()
	water.name = "VoidSea"
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(20000, 20000)
	water.mesh = mesh
	water.position = Vector3(0, -H_ROCK * 1.8, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.02, 0.04, 0.07)
	mat.roughness = 0.15
	mat.metallic = 0.6
	mat.emission_enabled = true
	mat.emission = Color(0.02, 0.05, 0.08)
	mat.emission_energy_multiplier = 0.3
	water.material_override = mat
	parent.add_child(water)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
func _cyl(parent: Node3D, n: String, pos: Vector3, r_top: float, r_bot: float, h: float, col: Color, em: Color = Color.BLACK, em_e: float = 0.0) -> void:
	var node := MeshInstance3D.new()
	node.name = n
	var m := CylinderMesh.new()
	m.top_radius = r_top
	m.bottom_radius = r_bot
	m.height = h
	m.radial_segments = 32
	node.mesh = m
	node.position = pos
	node.material_override = _mat(col, em, em_e)
	parent.add_child(node)

func _box(parent: Node3D, n: String, pos: Vector3, size: Vector3, col: Color) -> void:
	var node := MeshInstance3D.new()
	node.name = n
	var m := BoxMesh.new()
	m.size = size
	node.mesh = m
	node.position = pos
	node.material_override = _mat(col)
	parent.add_child(node)

func _sphere(parent: Node3D, n: String, pos: Vector3, r: float, col: Color, em: Color = Color.BLACK, em_e: float = 0.0) -> void:
	var node := MeshInstance3D.new()
	node.name = n
	var m := SphereMesh.new()
	m.radius = r
	m.height = r * 2.0
	node.mesh = m
	node.position = pos
	node.material_override = _mat(col, em, em_e)
	parent.add_child(node)

func _mat(albedo: Color, emission: Color = Color.BLACK, em_energy: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = albedo
	mat.roughness = 0.75
	mat.metallic = 0.08
	if em_energy > 0.0:
		mat.emission_enabled = true
		mat.emission = emission
		mat.emission_energy_multiplier = em_energy
	else:
		mat.emission_enabled = true
		mat.emission = albedo * 0.25
		mat.emission_energy_multiplier = 0.25
	return mat
