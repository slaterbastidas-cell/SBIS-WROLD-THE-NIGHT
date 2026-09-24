# Eclipse World — Children of the Storm

Aethermoor world-first browser prototype. Characters are intentionally excluded from this phase.

## Goal

Build a large online-scale explorable world with nine principal regions, strong vertical geography, landmark silhouettes, streaming/LOD foundations, atmosphere, and a Web export path.

## Regions

- Villa Eclipse
- La Antigua Ciudadela
- Cleopatt
- Valle Desierto
- Refugio de los Caídos
- Isla de la Paz
- La Biblioteca
- El Cosmos
- Castillo del Cosmos

Each major region uses a reference area of roughly 450 km². The world coordinate system is deliberately much larger than a single traditional game scene so that islands, vertical layers, and future streaming can coexist.

## Development rule

Do not add player characters, Echo models, enemies, weapons, or combat until the world foundation is stable.

## Current milestone

The repository now contains:

- Aethermoor macro terrain generation for all nine regions.
- Region-specific terrain scale, height and procedural surface variation.
- Landmark silhouettes for each region to establish long-distance visual identity.
- A large world coordinate layout with vertical separation.
- A free-flight exploration camera for world inspection.
- Runtime chunk-grid streaming state with a 500 m chunk contract.
- Aethermoor sky, fog, ambient lighting and long-distance camera range.
- A debug overlay showing region, world position and current chunk.

This is still a **blockout/foundation**, not final art. The next engineering pass should replace the placeholder terrain with real chunk-owned terrain, LOD tiers, region-specific generation rules, landmark systems, and actual visibility/streaming activation.

## Explorer controls

- `WASD` — move horizontally
- `Q / E` — descend / ascend
- `Shift` — boost speed
- Hold `Right Mouse` — free look
- `Esc` — release mouse capture

## Architecture direction

The intended deployment is online/browser/cloud rather than a conventional downloadable PC game. The client should render nearby world detail while the world layer remains compatible with persistent server state and future multiplayer synchronization.

## AI development

The repository is designed to be usable by autonomous coding agents such as Google Jules. AI agents should treat this README and the world design documents as constraints, preserve the world-first rule, and verify changes before merging.

## Local test

Open the project in Godot 4.x and run `res://world/world.tscn`.

No claim is made here that runtime validation has been performed in this environment. The project should be opened in Godot and tested before the next structural milestone is considered complete.

Web deployment will require a Godot Web export and a static hosting target such as Vercel.
