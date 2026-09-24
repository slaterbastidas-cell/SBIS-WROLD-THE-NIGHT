extends CanvasLayer

var label: Label

func _ready() -> void:
	label = Label.new()
	label.position = Vector2(18, 18)
	label.add_theme_font_size_override("font_size", 18)
	add_child(label)

func _process(_delta: float) -> void:
	var position := WorldManager.player_world_position
	var region := WorldManager.world_to_region(position)
	label.text = "ECLIPSE WORLD — AETHERMOOR\n" + 		"Region: %s\n" % region + 		"Position: %.0f / %.0f / %.0f\n" % [position.x, position.y, position.z] + 		"Chunk: %s" % [Vector2i(floori(position.x / EclipseWorldConstants.CHUNK_SIZE_M), floori(position.z / EclipseWorldConstants.CHUNK_SIZE_M))]
