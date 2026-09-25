extends Node3D

func _ready() -> void:
	$WorldEnvironment.environment = _build_environment()
	if has_node("WorldSun"):
		var sun: DirectionalLight3D = $WorldSun
		sun.light_energy = 0.9
		sun.light_color = Color("#A8B8C8")
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
	sky_material.sky_horizon_color = Color("#2A3545")
	sky_material.ground_bottom_color = Color("#04060A")
	sky_material.ground_horizon_color = Color("#0C1218")
	sky_material.sky_curve = 0.1
	sky_material.ground_curve = 0.05
	sky_material.sun_angle_max = 12.0
	sky.sky_material = sky_material
	environment.sky = sky

	# Ambient bajo: la lectura del espacio la dan las luces bioluminiscentes del Refugio
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#6A8098")
	environment.ambient_light_energy = 0.35
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 1.1

	environment.fog_enabled = true
	environment.fog_light_color = Color("#3A4A58")
	environment.fog_light_energy = 0.15
	environment.fog_density = 0.00035
	environment.fog_sky_affect = 0.4
	environment.fog_depth_begin = 2000.0
	environment.fog_depth_end = 40000.0
	return environment
