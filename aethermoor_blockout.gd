extends Node3D

# Blockout robusto y visible en Web/gl_compatibility.
# Ciudad-isla vertical sombría + abismo del Refugio.
# Sin look_at ni operaciones frágiles.

func _ready() -> void:
	var root := Node3D.new()
	root.name = "Citadel"
	$Regions.add_child(root)

	# --- Masa principal (siempre visible) ---
	_add_cyl(root, Vector3(0, 0, 0), 12000, 11000, 2500, Color(0.28, 0.32, 0.40))
	_add_cyl(root, Vector3(0, 2800, 0), 9000, 9500, 3000, Color(0.32, 0.36, 0.44))
	_add_cyl(root, Vector3(0, 6000, 0), 6000, 7000, 3500, Color(0.36, 0.40, 0.48))
	_add_cyl(root, Vector3(0, 9500, 0), 2800, 4000, 2800, Color(0.40, 0.44, 0.52))
	_add_cyl(root, Vector3(0, 11800, 0), 1200, 1800, 1800, Color(0.44, 0.48, 0.56))

	# Underside flotante
	_add_cyl(root, Vector3(0, -2000, 0), 11500, 2500, 2800, Color(0.14, 0.16, 0.20))

	# --- Anillos / terrazas ---
	_add_cyl(root, Vector3(0, 4500, 0), 10000, 10500, 180, Color(0.30, 0.34, 0.42))
	_add_cyl(root, Vector3(0, 3000, 0), 11000, 11500, 160, Color(0.28, 0.32, 0.40))
	_add_cyl(root, Vector3(0, 1200, 0), 11800, 12200, 160, Color(0.26, 0.30, 0.38))

	# --- Torres (8) ---
	for i in 8:
		var a := TAU * float(i) / 8.0
		var dist := 5500.0
		var h := 3500.0 + float(i % 4) * 800.0
		var x := cos(a) * dist
		var z := sin(a) * dist
		_add_cyl(root, Vector3(x, 1500 + h * 0.5, z), 180, 220, h, Color(0.34, 0.38, 0.46))
		_add_cyl(root, Vector3(x, 1500 + h + 400, z), 20, 90, 700, Color(0.50, 0.56, 0.64))

	# --- Bloques de edificios en el anillo medio ---
	for i in 16:
		var a := TAU * float(i) / 16.0
		var dist := 8500.0
		var h := 500.0 + float(i % 5) * 200.0
		var x := cos(a) * dist
		var z := sin(a) * dist
		_add_box(root, Vector3(x, 3200 + h * 0.5, z), Vector3(350, h, 300), Color(0.32, 0.36, 0.44))

	# --- Puentes ---
	for i in 4:
		var a := TAU * float(i) / 4.0 + 0.4
		var x := cos(a) * 7000.0
		var z := sin(a) * 7000.0
		_add_box(root, Vector3(x, 4600, z), Vector3(abs(cos(a)) * 2500 + 800, 80, abs(sin(a)) * 2500 + 800), Color(0.24, 0.28, 0.34))

	# --- Arcos grandes en la base ---
	for i in 6:
		var a := TAU * float(i) / 6.0
		var x := cos(a) * 9000.0
		var z := sin(a) * 9000.0
		_add_box(root, Vector3(x, -200, z), Vector3(200, 1800, 200), Color(0.18, 0.20, 0.26))
		_add_box(root, Vector3(x + cos(a + 1.2) * 600, 700, z + sin(a + 1.2) * 600), Vector3(1200, 160, 200), Color(0.18, 0.20, 0.26))

	# --- Niveles colgantes ---
	_add_cyl(root, Vector3(0, -4000, 0), 9000, 9500, 200, Color(0.20, 0.24, 0.30))
	_add_cyl(root, Vector3(0, -6500, 0), 7000, 7500, 200, Color(0.18, 0.22, 0.28))
	_add_cyl(root, Vector3(0, -9500, 0), 5000, 5500, 200, Color(0.16, 0.20, 0.26))

	for i in 8:
		var a := TAU * float(i) / 8.0
		var x := cos(a) * 4000.0
		var z := sin(a) * 4000.0
		_add_cyl(root, Vector3(x, -5500, z), 60, 140, 2500, Color(0.12, 0.14, 0.18))

	# --- Refugio: pozo y raíces ---
	_add_cyl(root, Vector3(0, -5000, 0), 3000, 2500, 14000, Color(0.08, 0.10, 0.14))

	# Cornisas
	for i in 6:
		var t := float(i) / 5.0
		var y := -2000.0 - t * 10000.0
		var a := t * TAU * 1.5
		var r := 2200.0
		_add_box(root, Vector3(cos(a) * r, y, sin(a) * r), Vector3(1800, 120, 700), Color(0.22, 0.26, 0.32))

	# Raíces (cilindros verticales / inclinados simples, sin look_at)
	_add_cyl(root, Vector3(2000, -6000, 1000), 200, 280, 8000, Color(0.10, 0.18, 0.14), Color(0.24, 1.0, 0.60), 1.5)
	_add_cyl(root, Vector3(-1800, -7000, -1200), 180, 250, 9000, Color(0.10, 0.16, 0.20), Color(0.35, 0.85, 1.0), 1.5)
	_add_cyl(root, Vector3(800, -9000, -2000), 220, 300, 7000, Color(0.10, 0.18, 0.14), Color(0.24, 1.0, 0.60), 1.8)
	_add_cyl(root, Vector3(-1000, -5000, 2000), 160, 220, 10000, Color(0.10, 0.16, 0.20), Color(0.35, 0.85, 1.0), 1.4)

	# Núcleo
	_add_cyl(root, Vector3(0, -14000, 0), 1500, 2200, 1500, Color(0.06, 0.08, 0.12), Color(0.30, 1.0, 0.80), 2.0)
	_add_sphere(root, Vector3(0, -13500, 0), 500, Color(0.05, 0.08, 0.10), Color(0.40, 1.0, 0.85), 4.0)

	# --- Luces bioluminiscentes ---
	_add_glow(root, Vector3(0, 12000, 0), 120, Color(0.40, 0.80, 1.0), 3.0)
	_add_glow(root, Vector3(0, 6000, 0), 100, Color(0.30, 1.0, 0.70), 2.5)
	_add_glow(root, Vector3(0, 0, 0), 100, Color(0.40, 0.80, 1.0), 2.5)
	_add_glow(root, Vector3(0, -8000, 0), 150, Color(0.30, 1.0, 0.75), 3.5)
	_add_glow(root, Vector3(0, -13500, 0), 200, Color(0.40, 1.0, 0.85), 5.0)

	# OmniLights
	_add_omni(root, Vector3(0, 12000, 0), Color(0.40, 0.80, 1.0), 2.5, 5000)
	_add_omni(root, Vector3(0, 4000, 0), Color(0.50, 0.70, 0.90), 2.0, 6000)
	_add_omni(root, Vector3(0, -6000, 0), Color(0.30, 1.0, 0.70), 2.5, 5000)
	_add_omni(root, Vector3(0, -13000, 0), Color(0.40, 1.0, 0.85), 3.5, 4000)

# ---- helpers seguros ----
func _add_cyl(parent: Node3D, pos: Vector3, r_top: float, r_bot: float, h: float, albedo: Color, emission: Color = Color.BLACK, em_energy: float = 0.0) -> void:
	var n := MeshInstance3D.new()
	var m := CylinderMesh.new()
	m.top_radius = r_top
	m.bottom_radius = r_bot
	m.height = h
	m.radial_segments = 24
	n.mesh = m
	n.position = pos
	n.material_override = _make_mat(albedo, emission, em_energy)
	parent.add_child(n)

func _add_box(parent: Node3D, pos: Vector3, size: Vector3, albedo: Color) -> void:
	var n := MeshInstance3D.new()
	var m := BoxMesh.new()
	m.size = size
	n.mesh = m
	n.position = pos
	n.material_override = _make_mat(albedo)
	parent.add_child(n)

func _add_sphere(parent: Node3D, pos: Vector3, radius: float, albedo: Color, emission: Color, em_energy: float) -> void:
	var n := MeshInstance3D.new()
	var m := SphereMesh.new()
	m.radius = radius
	m.height = radius * 2.0
	n.mesh = m
	n.position = pos
	n.material_override = _make_mat(albedo, emission, em_energy)
	parent.add_child(n)

func _add_glow(parent: Node3D, pos: Vector3, radius: float, emission: Color, em_energy: float) -> void:
	_add_sphere(parent, pos, radius, Color(0.05, 0.06, 0.08, 0.8), emission, em_energy)

func _add_omni(parent: Node3D, pos: Vector3, col: Color, energy: float, range_m: float) -> void:
	var l := OmniLight3D.new()
	l.light_color = col
	l.light_energy = energy
	l.omni_range = range_m
	l.position = pos
	parent.add_child(l)

func _make_mat(albedo: Color, emission: Color = Color.BLACK, em_energy: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = albedo
	mat.roughness = 0.88
	mat.metallic = 0.03
	if em_energy > 0.0:
		mat.emission_enabled = true
		mat.emission = emission
		mat.emission_energy_multiplier = em_energy
	else:
		mat.emission_enabled = true
		mat.emission = albedo * 0.4
		mat.emission_energy_multiplier = 0.35
	return mat
