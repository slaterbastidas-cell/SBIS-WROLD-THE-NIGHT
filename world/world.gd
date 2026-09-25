extends Node3D

func _ready() -> void:
	$WorldEnvironment.environment = _build_environment()
	# Soft directional fill for Web / gl_compatibility (keeps night mood)
	if has_node("WorldSun"):
		var sun: DirectionalLight3D = $WorldSun
		sun.light_energy = 1.35
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
	# Night sky kept; ground of the sky no longer pure black so the lower half is not a void
	sky_material.sky_top_color = Color("#050811")
	sky_material.sky_horizon_color = Color("#3A4A5E")
	sky_material.ground_bottom_color = Color("#0C1018")
	sky_material.ground_horizon_color = Color("#1E2A38")
	sky_material.sky_curve = 0.12
	sky_material.ground_curve = 0.08
	sky_material.sun_angle_max = 18.0
	sky.sky_material = sky_material
	environment.sky = sky

	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#A8C0DC")
	environment.ambient_light_energy = 0.55
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 1.15

	environment.fog_enabled = true
	environment.fog_light_color = Color("#5A6A7D")
	environment.fog_light_energy = 0.28
	environment.fog_density = 0.00055
	environment.fog_sky_affect = 0.45
	environment.fog_aerial_perspective = 0.15
	return environment
