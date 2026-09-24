extends Node

var world_origin := Vector3.ZERO
var player_world_position := Vector3.ZERO

func update_player_position(position: Vector3) -> void:
	player_world_position = position

func world_to_region(position: Vector3) -> String:
	var best_name := "Castillo del Cosmos"
	var best_distance := INF
	for i in EclipseWorldConstants.REGION_NAMES.size():
		var center := region_center(i)
		var distance := position.distance_squared_to(center)
		if distance < best_distance:
			best_distance = distance
			best_name = EclipseWorldConstants.REGION_NAMES[i]
	return best_name

func region_center(index: int) -> Vector3:
	var centers := [
		Vector3(0, 1800, -6500),
		Vector3(6000, 1200, -4200),
		Vector3(6200, 400, 0),
		Vector3(4200, -200, 5200),
		Vector3(0, -1800, 3000),
		Vector3(-6000, 200, 5000),
		Vector3(-6200, 700, 0),
		Vector3(-5000, 1500, -4200),
		Vector3(500, 900, 0)
	]
	return centers[index]
