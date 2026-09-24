class_name EclipseWorldConstants
extends RefCounted

# Aethermoor is intentionally much larger than a single playable scene.
# These values define the streaming/grid contract, not a final polygon boundary.
const REGION_REFERENCE_AREA_KM2 := 450.0
const REGION_REFERENCE_DIAMETER_KM := 24.0
const WORLD_VERTICAL_RANGE_KM := 8.0
const CHUNK_SIZE_M := 500.0
const STREAM_RADIUS_CHUNKS := 2
const LOD_NEAR_DISTANCE_M := 2500.0
const LOD_FAR_DISTANCE_M := 9000.0

const REGION_NAMES := [
	"Villa Eclipse",
	"La Antigua Ciudadela",
	"Cleopatt",
	"Valle Desierto",
	"Refugio de los Caídos",
	"Isla de la Paz",
	"La Biblioteca",
	"El Cosmos",
	"Castillo del Cosmos"
]
