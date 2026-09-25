extends Node3D

# Isla flotante = contenedor de Aethermoor
# Refugio de los Caídos = región inferior vertical (inframundo vivo)
const ISLAND_RADIUS := 36000.0
const ISLAND_THICKNESS := 4200.0
const ABYSS_RADIUS := 9000.0
const DEPTH_MAX := -28000.0

func _ready() -> void:
	_create_floating_island()
	_create_refugio_de_los_caidos()

# ---------------------------------------------------------------------------
# ISLA FLOTANTE (superficie)
# ---------------------------------------------------------------------------
func _create_floating_island() -> void:
	var root := Node3D.new()
	root.name = "Isla_Flotante"
	$Regions.add_child(root)

	var top := MeshInstance3D.new()
	top.name = "IslandTop"
	var top_mesh := CylinderMesh.new()
	top_mesh.top_radius = ISLAND_RADIUS * 0.94
	top_mesh.bottom_radius = ISLAND_RADIUS
	top_mesh.height = ISLAND_THICKNESS * 0.55
	top_mesh.radial_segments = 64
	top.mesh = top_mesh
	top.position = Vector3(0.0, ISLAND_THICKNESS * 0.275, 0.0)
	top.material_override = _mat_stone(Color("#3A4658"))
	root.add_child(top)

	var underside := MeshInstance3D.new()
	underside.name = "IslandUnderside"
	var under_mesh := CylinderMesh.new()
	under_mesh.top_radius = ISLAND_RADIUS * 0.98
	under_mesh.bottom_radius = ISLAND_RADIUS * 0.22
	under_mesh.height = ISLAND_THICKNESS * 0.85
	under_mesh.radial_segments = 64
	underside.mesh = under_mesh
	underside.position = Vector3(0.0, -ISLAND_THICKNESS * 0.35, 0.0)
	underside.material_override = _mat_stone(Color("#1A222C"))
	root.add_child(underside)

	# Anillo de acantilados en el borde
	for i in 8:
		var angle := TAU * float(i) / 8.0
		var cliff := MeshInstance3D.new()
		var cmesh := BoxMesh.new()
		cmesh.size = Vector3(5000.0, 2000.0, 3500.0)
		cliff.mesh = cmesh
		cliff.position = Vector3(cos(angle) * ISLAND_RADIUS * 0.9, ISLAND_THICKNESS * 0.15, sin(angle) * ISLAND_RADIUS * 0.9)
		cliff.rotation_degrees.y = rad_to_deg(angle)
		cliff.material_override = _mat_stone(Color("#2A3444"))
		root.add_child(cliff)

# ---------------------------------------------------------------------------
# REFUGIO DE LOS CAÍDOS
# superficie → grietas → abismo → cavernas → raíces → ruinas → profundidades
# ---------------------------------------------------------------------------
func _create_refugio_de_los_caidos() -> void:
	var root := Node3D.new()
	root.name = "Refugio_de_los_Caidos"
	$Regions.add_child(root)

	_create_abyss_mouth(root)
	_create_descending_ledges(root)
	_create_cavern_shells(root)
	_create_giant_roots(root)
	_create_ruins(root)
	_create_bio_lights(root)
	_create_deep_core(root)

func _create_abyss_mouth(parent: Node3D) -> void:
	# Boca del abismo en el centro de la isla (grieta circular)
	var rim := MeshInstance3D.new()
	rim.name = "AbyssRim"
	var torus := TorusMesh.new()
	torus.inner_radius = ABYSS_RADIUS * 0.92
	torus.outer_radius = ABYSS_RADIUS * 1.08
	torus.rings = 48
	torus.ring_segments = 24
	rim.mesh = torus
	rim.position = Vector3(0.0, ISLAND_THICKNESS * 0.55 + 20.0, 0.0)
	rim.rotation_degrees.x = 90.0
	rim.material_override = _mat_stone(Color("#1C2430"))
	parent.add_child(rim)

	# Paredes verticales del pozo principal
	var shaft := MeshInstance3D.new()
	shaft.name = "AbyssShaft"
	var shaft_mesh := CylinderMesh.new()
	shaft_mesh.top_radius = ABYSS_RADIUS
	shaft_mesh.bottom_radius = ABYSS_RADIUS * 0.75
	shaft_mesh.height = 12000.0
	shaft_mesh.radial_segments = 48
	# Capes abiertos: usamos solo el “tubo” visual con material oscuro
	shaft.mesh = shaft_mesh
	shaft.position = Vector3(0.0, ISLAND_THICKNESS * 0.2 - 6000.0, 0.0)
	var shaft_mat := _mat_stone(Color("#121820"))
	shaft_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	shaft.material_override = shaft_mat
	parent.add_child(shaft)

	# Grietas radiales en la superficie
	for i in 6:
		var angle := TAU * float(i) / 6.0 + 0.2
		var crack := MeshInstance3D.new()
		var cmesh := BoxMesh.new()
		cmesh.size = Vector3(1800.0, 400.0, 6000.0)
		crack.mesh = cmesh
		var dist := ABYSS_RADIUS * 1.15
		crack.position = Vector3(cos(angle) * dist, ISLAND_THICKNESS * 0.55, sin(angle) * dist)
		crack.rotation_degrees.y = rad_to_deg(angle)
		crack.material_override = _mat_stone(Color("#151C26"))
		parent.add_child(crack)

func _create_descending_ledges(parent: Node3D) -> void:
	# Plataformas/cornisas en espiral descendente
	var levels := 8
	for i in levels:
		var t := float(i) / float(levels - 1)
		var y := ISLAND_THICKNESS * 0.3 - t * 14000.0
		var radius := ABYSS_RADIUS * (0.95 - t * 0.35)
		var angle := t * TAU * 1.5

		var ledge := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(3500.0 - t * 800.0, 180.0, 2200.0)
		ledge.mesh = mesh
		ledge.position = Vector3(cos(angle) * radius * 0.7, y, sin(angle) * radius * 0.7)
		ledge.rotation_degrees.y = rad_to_deg(angle) + 90.0
		ledge.material_override = _mat_stone(Color("#2A3340"))
		parent.add_child(ledge)

		# Pilar de soporte
		var pillar := MeshInstance3D.new()
		var pmesh := CylinderMesh.new()
		pmesh.top_radius = 120.0
		pmesh.bottom_radius = 180.0
		pmesh.height = 900.0 + i * 200.0
		pmesh.radial_segments = 8
		pillar.mesh = pmesh
		pillar.position = ledge.position + Vector3(0.0, -pmesh.height * 0.4, 0.0)
		pillar.material_override = _mat_stone(Color("#222A35"))
		parent.add_child(pillar)

func _create_cavern_shells(parent: Node3D) -> void:
	# Cáscaras de caverna (arcos / anillos) a distintas profundidades
	var depths := [-4000.0, -9000.0, -15000.0, -21000.0]
	var radii := [7000.0, 6000.0, 5000.0, 4200.0]
	for i in depths.size():
		var shell := MeshInstance3D.new()
		shell.name = "CavernShell_%d" % i
		var torus := TorusMesh.new()
		torus.inner_radius = radii[i] * 0.85
		torus.outer_radius = radii[i]
		torus.rings = 36
		torus.ring_segments = 16
		shell.mesh = torus
		shell.position = Vector3(0.0, depths[i], 0.0)
		shell.rotation_degrees.x = 90.0
		shell.material_override = _mat_stone(Color("#1A222C"))
		parent.add_child(shell)

		# Pared lateral de caverna (cilindro parcial visual)
		var wall := MeshInstance3D.new()
		var wmesh := CylinderMesh.new()
		wmesh.top_radius = radii[i] * 1.05
		wmesh.bottom_radius = radii[i] * 0.95
		wmesh.height = 2800.0
		wmesh.radial_segments = 40
		wall.mesh = wmesh
		wall.position = Vector3(0.0, depths[i] - 800.0, 0.0)
		var wmat := _mat_stone(Color("#141A22"))
		wmat.cull_mode = BaseMaterial3D.CULL_DISABLED
		wall.material_override = wmat
		parent.add_child(wall)

func _create_giant_roots(parent: Node3D) -> void:
	# Raíces gigantes que atraviesan el abismo (ecosistema vivo)
	var root_data := [
		{"from": Vector3(6000.0, 2000.0, 2000.0), "to": Vector3(1500.0, -8000.0, -1000.0), "r": 380.0},
		{"from": Vector3(-5000.0, 1500.0, 4000.0), "to": Vector3(-1200.0, -12000.0, 800.0), "r": 320.0},
		{"from": Vector3(2000.0, 1000.0, -7000.0), "to": Vector3(-800.0, -16000.0, -2000.0), "r": 420.0},
		{"from": Vector3(-7000.0, 800.0, -3000.0), "to": Vector3(1000.0, -10000.0, 1500.0), "r": 280.0},
		{"from": Vector3(4000.0, -2000.0, 5000.0), "to": Vector3(0.0, -20000.0, 0.0), "r": 500.0},
		{"from": Vector3(-3000.0, -5000.0, -4000.0), "to": Vector3(2000.0, -22000.0, 1000.0), "r": 350.0},
		{"from": Vector3(8000.0, -1000.0, -2000.0), "to": Vector3(3000.0, -14000.0, 3000.0), "r": 260.0},
		{"from": Vector3(-2000.0, 500.0, 8000.0), "to": Vector3(-2500.0, -18000.0, -500.0), "r": 400.0}
	]

	for i in root_data.size():
		var data: Dictionary = root_data[i]
		var start: Vector3 = data.from
		var end: Vector3 = data.to
		var mid := (start + end) * 0.5
		var length := start.distance_to(end)
		var dir := (end - start).normalized()

		var root_mesh := MeshInstance3D.new()
		root_mesh.name = "Root_%02d" % i
		var cyl := CylinderMesh.new()
		cyl.top_radius = data.r * 0.7
		cyl.bottom_radius = data.r
		cyl.height = length
		cyl.radial_segments = 10
		root_mesh.mesh = cyl
		root_mesh.position = mid
		# Orientar el cilindro a lo largo de dir
		root_mesh.look_at(end, Vector3.UP)
		root_mesh.rotate_object_local(Vector3.RIGHT, PI * 0.5)

		# Material de raíz con bioluminiscencia tenue
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("#1A2A22")
		mat.roughness = 0.85
		mat.emission_enabled = true
		mat.emission = Color("#3DFF9A") if i % 2 == 0 else Color("#5AD4FF")
		mat.emission_energy_multiplier = 0.9 + (i % 3) * 0.25
		root_mesh.material_override = mat
		parent.add_child(root_mesh)

		# Nudos / bulbos en la raíz
		var bulb := MeshInstance3D.new()
		var bmesh := SphereMesh.new()
		bmesh.radius = data.r * 1.3
		bmesh.height = data.r * 2.2
		bulb.mesh = bmesh
		bulb.position = start.lerp(end, 0.35)
		var bmat := StandardMaterial3D.new()
		bmat.albedo_color = Color("#15201A")
		bmat.emission_enabled = true
		bmat.emission = Color("#7CFFC8")
		bmat.emission_energy_multiplier = 1.4
		bulb.material_override = bmat
		parent.add_child(bulb)

func _create_ruins(parent: Node3D) -> void:
	# Ruinas absorbidas por la tierra a media profundidad
	var ruin_y := -7000.0
	for i in 7:
		var angle := TAU * float(i) / 7.0
		var dist := 3500.0 + (i % 3) * 800.0

		# Columna rota
		var col := MeshInstance3D.new()
		var cmesh := CylinderMesh.new()
		cmesh.top_radius = 90.0
		cmesh.bottom_radius = 140.0
		cmesh.height = 600.0 + (i % 4) * 250.0
		cmesh.radial_segments = 8
		col.mesh = cmesh
		col.position = Vector3(cos(angle) * dist, ruin_y + (i % 3) * 200.0, sin(angle) * dist)
		col.rotation_degrees = Vector3((i * 13) % 25 - 12, i * 40.0, (i * 7) % 20 - 10)
		col.material_override = _mat_stone(Color("#2E3848"))
		parent.add_child(col)

		# Bloque erosionado
		var block := MeshInstance3D.new()
		var bmesh := BoxMesh.new()
		bmesh.size = Vector3(400.0 + i * 40.0, 200.0, 350.0)
		block.mesh = bmesh
		block.position = col.position + Vector3(300.0, -200.0, -150.0)
		block.rotation_degrees.y = i * 25.0
		block.material_override = _mat_stone(Color("#252E3A"))
		parent.add_child(block)

	# Arco de ruina central
	var arch_l := MeshInstance3D.new()
	var amesh := BoxMesh.new()
	amesh.size = Vector3(200.0, 1200.0, 200.0)
	arch_l.mesh = amesh
	arch_l.position = Vector3(-600.0, ruin_y + 400.0, 0.0)
	arch_l.material_override = _mat_stone(Color("#303A48"))
	parent.add_child(arch_l)

	var arch_r := arch_l.duplicate()
	arch_r.position = Vector3(600.0, ruin_y + 400.0, 0.0)
	parent.add_child(arch_r)

	var arch_top := MeshInstance3D.new()
	var tmesh := BoxMesh.new()
	tmesh.size = Vector3(1600.0, 180.0, 220.0)
	arch_top.mesh = tmesh
	arch_top.position = Vector3(0.0, ruin_y + 1000.0, 0.0)
	arch_top.material_override = _mat_stone(Color("#303A48"))
	parent.add_child(arch_top)

func _create_bio_lights(parent: Node3D) -> void:
	# Puntos de bioluminiscencia dispersos (minerales / esporas)
	var lights := [
		Vector3(2000.0, -3000.0, 1500.0),
		Vector3(-2500.0, -5500.0, -1000.0),
		Vector3(1000.0, -9000.0, -3000.0),
		Vector3(-1500.0, -12000.0, 2500.0),
		Vector3(3000.0, -15000.0, 500.0),
		Vector3(-500.0, -18000.0, -1500.0),
		Vector3(0.0, -22000.0, 0.0),
		Vector3(4000.0, -6000.0, 4000.0),
		Vector3(-4000.0, -8000.0, -3500.0),
		Vector3(1500.0, -11000.0, 3500.0)
	]
	for i in lights.size():
		var orb := MeshInstance3D.new()
		orb.name = "BioLight_%02d" % i
		var smesh := SphereMesh.new()
		smesh.radius = 90.0 + (i % 4) * 40.0
		smesh.height = smesh.radius * 2.0
		orb.mesh = smesh
		orb.position = lights[i]
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.1, 0.15, 0.12, 0.85)
		mat.emission_enabled = true
		var hues := [Color("#4DFFB0"), Color("#6EC8FF"), Color("#A0FF7A"), Color("#7AE0FF")]
		mat.emission = hues[i % hues.size()]
		mat.emission_energy_multiplier = 2.5 + (i % 3) * 0.8
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		orb.material_override = mat
		parent.add_child(orb)

		# OmniLight local para iluminar el entorno cercano (gl_compatibility)
		var light := OmniLight3D.new()
		light.light_color = hues[i % hues.size()]
		light.light_energy = 1.8
		light.omni_range = 2500.0 + (i % 3) * 800.0
		light.position = lights[i]
		parent.add_child(light)

func _create_deep_core(parent: Node3D) -> void:
	# Fondo del abismo: núcleo antiguo, no infierno
	var core := MeshInstance3D.new()
	core.name = "DeepCore"
	var mesh := CylinderMesh.new()
	mesh.top_radius = 2800.0
	mesh.bottom_radius = 4500.0
	mesh.height = 2000.0
	mesh.radial_segments = 32
	core.mesh = mesh
	core.position = Vector3(0.0, DEPTH_MAX + 1000.0, 0.0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#0E141A")
	mat.emission_enabled = true
	mat.emission = Color("#2A5A6E")
	mat.emission_energy_multiplier = 1.2
	mat.roughness = 0.7
	core.material_override = mat
	parent.add_child(core)

	# Anillo de minerales en el fondo
	var ring := MeshInstance3D.new()
	var tmesh := TorusMesh.new()
	tmesh.inner_radius = 3000.0
	tmesh.outer_radius = 3800.0
	tmesh.rings = 32
	tmesh.ring_segments = 12
	ring.mesh = tmesh
	ring.position = Vector3(0.0, DEPTH_MAX + 2000.0, 0.0)
	ring.rotation_degrees.x = 90.0
	var rmat := StandardMaterial3D.new()
	rmat.albedo_color = Color("#152028")
	rmat.emission_enabled = true
	rmat.emission = Color("#5CFFD0")
	rmat.emission_energy_multiplier = 2.0
	ring.material_override = rmat
	parent.add_child(ring)

# ---------------------------------------------------------------------------
# Materiales
# ---------------------------------------------------------------------------
func _mat_stone(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.92
	m.metallic = 0.02
	m.emission_enabled = true
	m.emission = color * 0.25
	m.emission_energy_multiplier = 0.2
	return m
