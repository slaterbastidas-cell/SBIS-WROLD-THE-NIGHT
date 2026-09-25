extends Node3D

func _ready() -> void:
	$WorldEnvironment.environment = _build_environment()
	if has_node("WorldSun"):
		var sun: DirectionalLight3D = $WorldSun
		sun.light_energy = 1.4
		sun.light_color = Color(0.85, 0.88, 0.95)
		sun.shadow_enabled = false
		sun.rotation_degrees = Vector3(-35, -40, 0)
	WorldManager.update_player_position($ExplorerCamera.global_position)
	$Aethermoor/Streaming.update_streaming(WorldManager.player_world_position)

func _process(_delta: float) -> void:
	$Aethermoor/Streaming.update_streaming(WorldManager.player_world_position)

func _build_environment() -> Environment:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY

	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.04, 0.06, 0.10)
	sky_material.sky_horizon_color = Color(0.15, 0.18, 0.24)
	sky_material.ground_bottom_color = Color(0.02, 0.03, 0.05)
	sky_material.ground_horizon_color = Color(0.05, 0.07, 0.10)
	sky_material.sun_angle_max = 14.0
	sky.sky_material = sky_material
	environment.sky = sky

	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.55, 0.60, 0.72)
	environment.ambient_light_energy = 0.55
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 1.15

	environment.fog_enabled = true
	environment.fog_light_color = Color(0.20, 0.25, 0.32)
	environment.fog_light_energy = 0.15
	environment.fog_density = 0.00025
	environment.fog_sky_affect = 0.4
	return environment
