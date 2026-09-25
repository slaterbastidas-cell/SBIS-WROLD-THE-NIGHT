extends Node3D

func _ready() -> void:
	$WorldEnvironment.environment = _build_environment()
	if has_node("WorldSun"):
		var sun: DirectionalLight3D = $WorldSun
		sun.light_energy = 1.7
		sun.light_color = Color("#C8D4E8")
		sun.shadow_enabled = true
	WorldManager.update_player_position($ExplorerCamera.global_position)
	$Aethermoor/Streaming.update_streaming(WorldManager.player_world_position)

func _process(_delta: float) -> void:
	$Aethermoor/Streaming.update_streaming(WorldManager.player_world_position)

func _build_environment() -> Environment:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY

	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("#050811")
	sky_material.sky_horizon_color = Color("#3A4A5E")
	sky_material.ground_bottom_color = Color("#060A10")
	sky_material.ground_horizon_color = Color("#121A24")
	sky_material.sky_curve = 0.1
	sky_material.ground_curve = 0.06
	sky_material.sun_angle_max = 18.0
	sky.sky_material = sky_material
	environment.sky = sky

	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#A8C0DC")
	environment.ambient_light_energy = 0.7
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 1.2

	# Niebla suave: vacío debajo de la isla flotante, sin “otras islas” al fondo
	environment.fog_enabled = true
	environment.fog_light_color = Color("#4A5A6C")
	environment.fog_light_energy = 0.2
	environment.fog_density = 0.00025
	environment.fog_sky_affect = 0.35
	return environment
