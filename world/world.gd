extends Node3D

func _ready() -> void:
	$WorldEnvironment.environment = _build_environment()
	$Aethermoor/Streaming.update_streaming(WorldManager.player_world_position)

func _build_environment() -> Environment:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY

	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("#050811")
	sky_material.sky_horizon_color = Color("#53647A")
	sky_material.ground_bottom_color = Color("#03050A")
	sky_material.ground_horizon_color = Color("#18202C")
	sky_material.sun_angle_max = 18.0
	sky.sky_material = sky_material
	environment.sky = sky

	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#9DB7D6")
	environment.ambient_light_energy = 0.42
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC

	environment.fog_enabled = true
	environment.fog_light_color = Color("#5A6A7D")
	environment.fog_light_energy = 0.22
	environment.fog_density = 0.004
	environment.fog_sky_affect = 0.65
	return environment
