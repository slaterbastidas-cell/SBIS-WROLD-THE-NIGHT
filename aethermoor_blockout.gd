extends Node3D

# Zona de inicio mínima y visible (evitar pantalla negra)
# Isla flotante simple + suelo caminable + luces

func _ready() -> void:
	var root := Node3D.new()
	root.name = "StartIsle"
	$Regions.add_child(root)

	# Suelo principal (caminable)
	_cyl(root, "Ground", Vector3(0, 0, 0), 800.0, 820.0, 40.0, Color(0.35, 0.38, 0.45))

	# Anillo de borde
	_cyl(root, "Rim", Vector3(0, 25, 0), 780.0, 800.0, 30.0, Color(0.55, 0.52, 0.48))

	# Plaza central clara
	_cyl(root, "Plaza", Vector3(0, 22, 0), 200.0, 220.0, 20.0, Color(0.75, 0.72, 0.68))

	# Domo / hito central (orientación)
	_cyl(root, "DomeBase", Vector3(0, 80, 0), 60.0, 80.0, 80.0, Color(0.85, 0.82, 0.75))
	_sphere(root, "Dome", Vector3(0, 150, 0), 70.0, Color(0.90, 0.88, 0.82), Color(1.0, 0.95, 0.7), 0.8)

	# Cuatro torres de referencia
	for i in 4:
		var a := TAU * float(i) / 4.0 + 0.4
		var x := cos(a) * 450.0
		var z := sin(a) * 450.0
		_cyl(root, "Tower_%d" % i, Vector3(x, 100, z), 20.0, 28.0, 180.0, Color(0.70, 0.68, 0.62))

	# Base rocosa inferior (silueta flotante)
	_cyl(root, "RockUnder", Vector3(0, -200, 0), 780.0, 200.0, 350.0, Color(0.12, 0.11, 0.10))

	# Luces para que no quede negro
	var sun_fill := OmniLight3D.new()
	sun_fill.light_color = Color(0.9, 0.92, 1.0)
	sun_fill.light_energy = 3.0
	sun_fill.omni_range = 2000.0
	sun_fill.position = Vector3(0, 400, 0)
	root.add_child(sun_fill)

	for i in 6:
		var a := TAU * float(i) / 6.0
		var pos := Vector3(cos(a) * 300.0, 40.0, sin(a) * 300.0)
		var l := OmniLight3D.new()
		l.light_color = Color(1.0, 0.85, 0.6)
		l.light_energy = 1.5
		l.omni_range = 250.0
		l.position = pos
		root.add_child(l)

func _cyl(parent: Node3D, n: String, pos: Vector3, r_top: float, r_bot: float, h: float, col: Color) -> void:
	var node := MeshInstance3D.new()
	node.name = n
	var mesh := CylinderMesh.new()
	mesh.top_radius = r_top
	mesh.bottom_radius = r_bot
	mesh.height = h
	mesh.radial_segments = 32
	node.mesh = mesh
	node.position = pos
	node.material_override = _mat(col)
	# Colisión para caminar
	var static_body := StaticBody3D.new()
	var col_shape := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = maxf(r_top, r_bot)
	shape.height = h
	col_shape.shape = shape
	static_body.position = pos
	static_body.add_child(col_shape)
	parent.add_child(node)
	parent.add_child(static_body)

func _sphere(parent: Node3D, n: String, pos: Vector3, r: float, col: Color, em: Color = Color.BLACK, em_e: float = 0.0) -> void:
	var node := MeshInstance3D.new()
	node.name = n
	var mesh := SphereMesh.new()
	mesh.radius = r
	mesh.height = r * 2.0
	node.mesh = mesh
	node.position = pos
	var mat := _mat(col)
	if em_e > 0.0:
		mat.emission_enabled = true
		mat.emission = em
		mat.emission_energy_multiplier = em_e
	node.material_override = mat
	parent.add_child(node)

func _mat(col: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.roughness = 0.8
	m.emission_enabled = true
	m.emission = col * 0.35
	m.emission_energy_multiplier = 0.4
	return m
