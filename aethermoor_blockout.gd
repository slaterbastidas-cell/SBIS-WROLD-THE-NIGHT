extends Node3D

# Ciudad-isla flotante vertical (inspiración de la referencia, tono sombrío Aethermoor)
# Escala grande + densidad de arcos, torres, puentes y niveles colgantes.
const BASE_R := 14000.0
const TOP_Y := 12000.0
const BOTTOM_Y := -16000.0

func _ready() -> void:
	var root := Node3D.new()
	root.name = "Aethermoor_Citadel"
	$Regions.add_child(root)

	_build_core_mass(root)
	_build_upper_city(root)
	_build_mid_rings(root)
	_build_lower_hanging(root)
	_build_towers(root)
	_build_arches_and_bridges(root)
	_build_refugio_depths(root)
	_build_bio_accents(root)

# ---------------------------------------------------------------------------
# Masa central (roca/ciudad apilada)
# ---------------------------------------------------------------------------
func _build_core_mass(parent: Node3D) -> void:
	# Base ancha flotante
	_cyl(parent, "CoreBase", Vector3(0, 0, 0), BASE_R, BASE_R * 0.92, 2800.0, Color("#2A3340"))
	# Cuerpo medio
	_cyl(parent, "CoreMid", Vector3(0, 3200, 0), BASE_R * 0.72, BASE_R * 0.78, 3600.0, Color("#323C4A"))
	# Cuerpo alto
	_cyl(parent, "CoreHigh", Vector3(0, 7000, 0), BASE_R * 0.48, BASE_R * 0.55, 4200.0, Color("#3A4658"))
	# Pico / acrópolis
	_cyl(parent, "CorePeak", Vector3(0, 10500, 0), BASE_R * 0.22, BASE_R * 0.32, 2800.0, Color("#445060"))

	# Underside en cuña (isla flotante)
	_cyl(parent, "Underside", Vector3(0, -2200, 0), BASE_R * 0.95, BASE_R * 0.18, 3200.0, Color("#1A222C"))

# ---------------------------------------------------------------------------
# Ciudad superior (acrópolis sombría)
# ---------------------------------------------------------------------------
func _build_upper_city(parent: Node3D) -> void:
	var y := 9800.0
	# Plataformas aterrazadas
	for i in 5:
		var r := 4200.0 - i * 500.0
		_cyl(parent, "Terrace_%d" % i, Vector3(0, y + i * 420.0, 0), r, r * 1.05, 160.0, Color("#3E4A5A"))

	# Palacio central
	_box(parent, "Palace", Vector3(0, 11800, 0), Vector3(1800, 1600, 1800), Color("#4A5568"))
	_box(parent, "PalaceRoof", Vector3(0, 12700, 0), Vector3(2000, 200, 2000), Color("#2E3848"))
	# Torres del palacio
	for j in 4:
		var a := TAU * float(j) / 4.0 + 0.4
		var p := Vector3(cos(a) * 900.0, 12200, sin(a) * 900.0)
		_cyl(parent, "PalaceTower_%d" % j, p, 120.0, 160.0, 1400.0, Color("#505A6A"))
		_cyl(parent, "PalaceSpire_%d" % j, p + Vector3(0, 900, 0), 20.0, 80.0, 600.0, Color("#6A7888"))

	# Cúpula / anillo de energía sombría sobre la cima
	var halo := MeshInstance3D.new()
	halo.name = "SummitHalo"
	var t := TorusMesh.new()
	t.inner_radius = 1600.0
	t.outer_radius = 1900.0
	t.rings = 40
	t.ring_segments = 16
	halo.mesh = t
	halo.position = Vector3(0, 13200, 0)
	halo.rotation_degrees.x = 90.0
	var hm := StandardMaterial3D.new()
	hm.albedo_color = Color(0.1, 0.12, 0.16, 0.7)
	hm.emission_enabled = true
	hm.emission = Color("#6EC8FF")
	hm.emission_energy_multiplier = 2.5
	hm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	halo.material_override = hm
	parent.add_child(halo)

# ---------------------------------------------------------------------------
# Anillos intermedios (barrios en terraza)
# ---------------------------------------------------------------------------
func _build_mid_rings(parent: Node3D) -> void:
	var ring_defs := [
		{"y": 5500.0, "r": 9000.0, "h": 200.0},
		{"y": 4000.0, "r": 10500.0, "h": 180.0},
		{"y": 2500.0, "r": 11500.0, "h": 160.0},
		{"y": 800.0, "r": 12500.0, "h": 160.0}
	]
	for i in ring_defs.size():
		var d: Dictionary = ring_defs[i]
		_cyl(parent, "Ring_%d" % i, Vector3(0, d.y, 0), d.r * 0.92, d.r, d.h, Color("#2E3848"))

		# Bloques de “edificios” alrededor del anillo
		var count := 12 + i * 2
		for k in count:
			var a := TAU * float(k) / float(count) + i * 0.15
			var dist := d.r * 0.78
			var h := 400.0 + (k % 5) * 180.0
			var w := 280.0 + (k % 3) * 80.0
			_box(parent, "House_%d_%d" % [i, k],
				Vector3(cos(a) * dist, d.y + h * 0.5 + 40.0, sin(a) * dist),
				Vector3(w, h, w * 0.9),
				Color("#3A4656") if k % 2 == 0 else Color("#445060"))
			# Techo simple
			_box(parent, "Roof_%d_%d" % [i, k],
				Vector3(cos(a) * dist, d.y + h + 80.0, sin(a) * dist),
				Vector3(w * 1.1, 60.0, w),
				Color("#1E2834"))

# ---------------------------------------------------------------------------
# Parte inferior colgante (como la referencia, pero oscura)
# ---------------------------------------------------------------------------
func _build_lower_hanging(parent: Node3D) -> void:
	# Niveles que cuelgan bajo la base
	var hang := [
		{"y": -3500.0, "r": 10000.0},
		{"y": -5500.0, "r": 8500.0},
		{"y": -8000.0, "r": 6500.0},
		{"y": -11000.0, "r": 4500.0}
	]
	for i in hang.size():
		var d: Dictionary = hang[i]
		_cyl(parent, "HangDisk_%d" % i, Vector3(0, d.y, 0), d.r * 0.9, d.r, 220.0, Color("#222A35"))

		# Arcos estructurales bajo cada disco
		for k in 8:
			var a := TAU * float(k) / 8.0
			var p := Vector3(cos(a) * d.r * 0.65, d.y - 600.0, sin(a) * d.r * 0.65)
			_box(parent, "HangArch_%d_%d" % [i, k], p, Vector3(200.0, 1200.0, 200.0), Color("#1A222C"))
			_box(parent, "HangArchTop_%d_%d" % [i, k],
				p + Vector3(0, 700.0, 0),
				Vector3(900.0, 160.0, 200.0),
				Color("#1A222C"))

	# Estalactitas / raíces de piedra colgando
	for i in 14:
		var a := TAU * float(i) / 14.0 + 0.1
		var dist := 5000.0 + (i % 4) * 1200.0
		var h := 1800.0 + (i % 5) * 600.0
		_cyl(parent, "Stalactite_%d" % i,
			Vector3(cos(a) * dist, -2000.0 - h * 0.5, sin(a) * dist),
			40.0 + (i % 3) * 30.0,
			120.0 + (i % 3) * 50.0,
			h,
			Color("#151C26"))

# ---------------------------------------------------------------------------
# Torres verticales (silueta de ciudad)
# ---------------------------------------------------------------------------
func _build_towers(parent: Node3D) -> void:
	var towers := [
		{"p": Vector3(3500, 2000, 2800), "h": 5200.0, "r": 280.0},
		{"p": Vector3(-4000, 1500, 2000), "h": 4800.0, "r": 240.0},
		{"p": Vector3(2000, 3000, -4500), "h": 6000.0, "r": 300.0},
		{"p": Vector3(-2500, 1000, -3800), "h": 4500.0, "r": 220.0},
		{"p": Vector3(5500, 500, 1000), "h": 3800.0, "r": 200.0},
		{"p": Vector3(-5500, 800, -1500), "h": 4200.0, "r": 210.0},
		{"p": Vector3(0, 4000, 5000), "h": 5500.0, "r": 260.0},
		{"p": Vector3(1000, 2500, 0), "h": 7000.0, "r": 320.0}
	]
	for i in towers.size():
		var d: Dictionary = towers[i]
		_cyl(parent, "Tower_%d" % i, d.p + Vector3(0, d.h * 0.5, 0), d.r * 0.7, d.r, d.h, Color("#3A4656"))
		_cyl(parent, "Spire_%d" % i, d.p + Vector3(0, d.h + 400.0, 0), 15.0, d.r * 0.45, 900.0, Color("#5A6A7A"))
		# Balcones
		_box(parent, "Balcony_%d" % i, d.p + Vector3(d.r + 40.0, d.h * 0.6, 0), Vector3(200.0, 80.0, 300.0), Color("#2A3444"))

# ---------------------------------------------------------------------------
# Arcos y puentes
# ---------------------------------------------------------------------------
func _build_arches_and_bridges(parent: Node3D) -> void:
	# Puentes entre anillos
	var bridges := [
		{"y": 5600.0, "a": 0.3, "len": 2800.0},
		{"y": 4100.0, "a": 1.2, "len": 3200.0},
		{"y": 2600.0, "a": 2.4, "len": 3600.0},
		{"y": 900.0, "a": 3.8, "len": 4000.0},
		{"y": 5600.0, "a": 3.5, "len": 2600.0},
		{"y": 3000.0, "a": 5.0, "len": 3000.0}
	]
	for i in bridges.size():
		var d: Dictionary = bridges[i]
		var dir := Vector3(cos(d.a), 0, sin(d.a))
		var pos := dir * 6000.0 + Vector3(0, d.y, 0)
		_box(parent, "Bridge_%d" % i, pos, Vector3(d.len, 100.0, 280.0), Color("#2A3340"))
		# Barandales
		_box(parent, "RailL_%d" % i, pos + Vector3(0, 80, 160), Vector3(d.len, 40.0, 40.0), Color("#1A222C"))
		_box(parent, "RailR_%d" % i, pos + Vector3(0, 80, -160), Vector3(d.len, 40.0, 40.0), Color("#1A222C"))

	# Grandes arcos estructurales en la base
	for i in 6:
		var a := TAU * float(i) / 6.0
		var base := Vector3(cos(a) * 8000.0, -800.0, sin(a) * 8000.0)
		_box(parent, "BigArchL_%d" % i, base + Vector3(-500, 0, 0).rotated(Vector3.UP, a), Vector3(200, 2200, 200), Color("#1E2834"))
		_box(parent, "BigArchR_%d" % i, base + Vector3(500, 0, 0).rotated(Vector3.UP, a), Vector3(200, 2200, 200), Color("#1E2834"))
		_box(parent, "BigArchTop_%d" % i, base + Vector3(0, 1200, 0), Vector3(1400, 200, 200), Color("#1E2834"))

# ---------------------------------------------------------------------------
# Refugio de los Caídos (interior / profundidad vertical)
# ---------------------------------------------------------------------------
func _build_refugio_depths(parent: Node3D) -> void:
	var refugio := Node3D.new()
	refugio.name = "Refugio_de_los_Caidos"
	parent.add_child(refugio)

	# Pozo central
	var shaft := MeshInstance3D.new()
	var sm := CylinderMesh.new()
	sm.top_radius = 3500.0
	sm.bottom_radius = 2200.0
	sm.height = 18000.0
	sm.radial_segments = 40
	shaft.mesh = sm
	shaft.position = Vector3(0, -7000, 0)
	var shaft_mat := _mat(Color("#0E141A"))
	shaft_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	shaft.material_override = shaft_mat
	refugio.add_child(shaft)

	# Cornisas en espiral dentro del pozo
	for i in 10:
		var t := float(i) / 9.0
		var y := -1000.0 - t * 14000.0
		var a := t * TAU * 2.0
		var r := 2800.0 - t * 800.0
		_box(refugio, "Ledge_%d" % i,
			Vector3(cos(a) * r * 0.75, y, sin(a) * r * 0.75),
			Vector3(2200.0, 140.0, 900.0),
			Color("#252E3A"))

	# Raíces gigantes bioluminiscentes
	var roots := [
		[Vector3(4000, 1000, 2000), Vector3(800, -9000, -500), 280.0],
		[Vector3(-3500, 500, 3000), Vector3(-600, -12000, 400), 320.0],
		[Vector3(2000, -2000, -4000), Vector3(0, -14000, 0), 400.0],
		[Vector3(-2000, -4000, 3500), Vector3(500, -16000, -200), 260.0],
		[Vector3(5000, -1000, -1000), Vector3(1500, -11000, 1500), 300.0]
	]
	for i in roots.size():
		var s: Vector3 = roots[i][0]
		var e: Vector3 = roots[i][1]
		var rad: float = roots[i][2]
		var mid := (s + e) * 0.5
		var length := s.distance_to(e)
		var node := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = rad * 0.65
		cyl.bottom_radius = rad
		cyl.height = length
		cyl.radial_segments = 8
		node.mesh = cyl
		node.position = mid
		node.look_at(e, Vector3.UP)
		node.rotate_object_local(Vector3.RIGHT, PI * 0.5)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("#15201A")
		mat.emission_enabled = true
		mat.emission = Color("#3DFF9A") if i % 2 == 0 else Color("#5AD4FF")
		mat.emission_energy_multiplier = 1.2
		node.material_override = mat
		refugio.add_child(node)

	# Núcleo profundo
	_cyl(refugio, "DeepCore", Vector3(0, -16000, 0), 1800.0, 2800.0, 1600.0, Color("#0A1016"))
	var core_glow := MeshInstance3D.new()
	var cg := SphereMesh.new()
	cg.radius = 600.0
	cg.height = 1200.0
	core_glow.mesh = cg
	core_glow.position = Vector3(0, -15500, 0)
	var cgm := StandardMaterial3D.new()
	cgm.albedo_color = Color(0.05, 0.08, 0.1, 0.8)
	cgm.emission_enabled = true
	cgm.emission = Color("#4DFFC8")
	cgm.emission_energy_multiplier = 3.5
	cgm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	core_glow.material_override = cgm
	refugio.add_child(core_glow)

# ---------------------------------------------------------------------------
# Acentos de bioluminiscencia
# ---------------------------------------------------------------------------
func _build_bio_accents(parent: Node3D) -> void:
	var pts := [
		Vector3(0, 12500, 0), Vector3(3000, 6000, 2000), Vector3(-2500, 4500, -3000),
		Vector3(0, 2000, 0), Vector3(4000, -4000, 1000), Vector3(-3000, -7000, -2000),
		Vector3(0, -10000, 0), Vector3(1500, -13000, 500), Vector3(-1000, -15000, 0)
	]
	for i in pts.size():
		var orb := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 70.0 + (i % 3) * 30.0
		sm.height = sm.radius * 2.0
		orb.mesh = sm
		orb.position = pts[i]
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.08, 0.1, 0.12, 0.85)
		mat.emission_enabled = true
		mat.emission = Color("#6EC8FF") if i % 2 == 0 else Color("#5CFFB0")
		mat.emission_energy_multiplier = 2.8
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		orb.material_override = mat
		parent.add_child(orb)

		var light := OmniLight3D.new()
		light.light_color = mat.emission
		light.light_energy = 2.0
		light.omni_range = 2200.0
		light.position = pts[i]
		parent.add_child(light)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
func _cyl(parent: Node3D, n: String, pos: Vector3, r_top: float, r_bot: float, h: float, col: Color) -> void:
	var node := MeshInstance3D.new()
	node.name = n
	var mesh := CylinderMesh.new()
	mesh.top_radius = r_top
	mesh.bottom_radius = r_bot
	mesh.height = h
	mesh.radial_segments = 28
	node.mesh = mesh
	node.position = pos
	node.material_override = _mat(col)
	parent.add_child(node)

func _box(parent: Node3D, n: String, pos: Vector3, size: Vector3, col: Color) -> void:
	var node := MeshInstance3D.new()
	node.name = n
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.position = pos
	node.material_override = _mat(col)
	parent.add_child(node)

func _mat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.9
	m.metallic = 0.04
	m.emission_enabled = true
	m.emission = color * 0.3
	m.emission_energy_multiplier = 0.22
	return m
