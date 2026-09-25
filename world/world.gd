extends Node3D

func _ready() -> void:
	$WorldEnvironment.environment = _build_environment()
	if has_node("WorldSun"):
		var sun: DirectionalLight3D = $WorldSun
		sun.light_energy = 1.8
		sun.light_color = Color(0.9, 0.92, 1.0)
		sun.shadow_enabled = false
	if has_node("Player"):
		WorldManager.update_player_position($Player.global_position)
	if has_node("Aethermoor/Streaming"):
		$Aethermoor/Streaming.update_streaming(WorldManager.player_world_position)

func _process(_delta: float) -> void:
	if has_node("Aethermoor/Streaming"):
		$Aethermoor/Streaming.update_streaming(WorldManager.player_world_position)

func _build_environment() -> Environment:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY

	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.05, 0.07, 0.12)
	sky_material.sky_horizon_color = Color(0.18, 0.22, 0.30)
	sky_material.ground_bottom_color = Color(0.04, 0.05, 0.07)
	sky_material.ground_horizon_color = Color(0.10, 0.12, 0.16)
	sky.sky_material = sky_material
	environment.sky = sky

	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.65, 0.70, 0.82)
	environment.ambient_light_energy = 0.7
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 1.2

	environment.fog_enabled = false
	return environment
