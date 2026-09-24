extends Node

var world_origin := Vector3.ZERO
var player_world_position := Vector3.ZERO

const REGION_CENTERS := [
	Vector3(0.0, 2200.0, -42000.0),
	Vector3(36000.0, 1200.0, -26000.0),
	Vector3(47000.0, 400.0, 0.0),
	Vector3(34000.0, -200.0, 31000.0),
	Vector3(0.0, -2600.0, 38000.0),
	Vector3(-34000.0, 0.0, 30000.0),
	Vector3(-47000.0, 800.0, 0.0),
	Vector3(-34000.0, 1800.0, -27000.0),
	Vector3(0.0, 2600.0, 0.0)
]

func update_player_position(position: Vector3) -> void:
	player_world_position = position

func world_to_region(position: Vector3) -> String:
	var best_name := "Castillo del Cosmos"
	var best_distance := INF
	for i in EclipseWorldConstants.REGION_NAMES.size():
		var distance := position.distance_squared_to(REGION_CENTERS[i])
		if distance < best_distance:
			best_distance = distance
			best_name = EclipseWorldConstants.REGION_NAMES[i]
	return best_name

func region_center(index: int) -> Vector3:
	return REGION_CENTERS[index]
