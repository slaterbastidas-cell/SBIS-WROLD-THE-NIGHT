extends Node3D

const CHUNK_SIZE := EclipseWorldConstants.CHUNK_SIZE_M
const ACTIVE_RADIUS := EclipseWorldConstants.STREAM_RADIUS_CHUNKS

var active_chunks: Dictionary = {}
var last_chunk := Vector2i(999999, 999999)

func update_streaming(world_position: Vector3) -> void:
	var current_chunk := Vector2i(
		floori(world_position.x / CHUNK_SIZE),
		floori(world_position.z / CHUNK_SIZE)
	)
	if current_chunk == last_chunk:
		return
	last_chunk = current_chunk
	_update_active_set(current_chunk)

func _update_active_set(center: Vector2i) -> void:
	var wanted: Dictionary = {}
	for z in range(center.y - ACTIVE_RADIUS, center.y + ACTIVE_RADIUS + 1):
		for x in range(center.x - ACTIVE_RADIUS, center.x + ACTIVE_RADIUS + 1):
			wanted[Vector2i(x, z)] = true
	for key in wanted:
		if not active_chunks.has(key):
			active_chunks[key] = true
	for key in active_chunks.keys():
		if not wanted.has(key):
			active_chunks.erase(key)

func active_chunk_count() -> int:
	return active_chunks.size()

func chunk_for_position(position: Vector3) -> Vector2i:
	return Vector2i(floori(position.x / CHUNK_SIZE), floori(position.z / CHUNK_SIZE))
