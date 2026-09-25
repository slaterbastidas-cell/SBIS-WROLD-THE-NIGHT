extends Node3D

func _ready() -> void:
	$WorldEnvironment.environment = _build_environment()
	if has_node("WorldSun"):
		var sun: DirectionalLight3D = $WorldSun
		sun.light_energy = 1.1
		sun.light_color = Color("#9AABB8")
		sun.shadow_enabled = true
		sun.rotation_degrees = Vector3(-38, -50, 0)
	WorldManager.update_player_position($ExplorerCamera.global_position)
	$Aethermoor/Streaming.update_streaming(WorldManager.player_world_position)

func _process(_delta: float) -> void:
	$Aethermoor/Streaming.update_streaming(WorldManager.player_world_position)

func _build_environment() -> Environment:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY

	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("#04060C")
	sky_material.sky_horizon_color = Color("#1A2430")
	sky_material.ground_bottom_color = Color("#030508")
	sky_material.ground_horizon_color = Color("#0A1016")
	sky_material.sky_curve = 0.08
	sky_material.ground_curve = 0.05
	sky_material.sun_angle_max = 10.0
	sky.sky_material = sky_material
	environment.sky = sky

	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#7A90A8")
	environment.ambient_light_energy = 0.45
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 1.15

	environment.fog_enabled = true
	environment.fog_light_color = Color("#2A3848")
	environment.fog_light_energy = 0.18
	environment.fog_density = 0.0003
	environment.fog_sky_affect = 0.5
	return environment
