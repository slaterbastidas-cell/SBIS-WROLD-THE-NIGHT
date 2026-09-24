# Eclipse World — World Foundation

## Objective

Build Aethermoor as a persistent online-scale world, not as a downloadable monolithic PC level.

## Scale

Each principal region uses roughly 450 km² as its design reference, comparable in order of magnitude to Caracas. This is a design scale, not a requirement that every region be a perfect circle.

The world is vertically layered. The current architectural reference reserves roughly 4 km of usable vertical range.

## Streaming

The world is authored as terrain chunks rather than one giant scene. Initial chunk reference: 500 m. Runtime streaming will load detailed terrain and gameplay content around the active player while distant regions use simplified representations.

## Regions

1. Villa Eclipse — northern highlands
2. La Antigua Ciudadela — northeastern monumental region
3. Cleopatt — eastern ancient/desert region
4. Valle Desierto — southeastern archipelago/valley transition
5. Refugio de los Caídos — lower vertical realm
6. Isla de la Paz — southwestern volcanic/jungle region
7. La Biblioteca — western knowledge region
8. El Cosmos — northwestern cosmic/anomalous region
9. Castillo del Cosmos — central narrative and navigation nexus

## Design rule

The Castle is the narrative/navigation center, not necessarily the geometric center of the world.

## Current phase

This commit intentionally contains no player, enemies, weapons, HUD, factions, combat, or final terrain. The first deliverable is the world foundation and coordinate system.

## Next phases

1. Master blockout of Aethermoor.
2. Region boundaries and elevations.
3. Chunk/LOD/streaming implementation.
4. Atmosphere, ocean/void and large-scale landmarks.
5. Regional terrain.
6. Traversal and flight.
7. Life, NPCs and gameplay systems.
