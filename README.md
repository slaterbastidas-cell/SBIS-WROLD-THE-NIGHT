# Eclipse World — Children of the Storm

Aethermoor world-first browser prototype. Characters are intentionally excluded from this phase.

## Goal
Build a large online-scale explorable world with nine principal regions, vertical geography, streaming/LOD, and a Web export path.

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

## Development rule
Do not add player characters, Echo models, enemies, weapons, or combat until the world foundation is stable.

## Current state
The repository contains the initial Aethermoor macro terrain generator and world coordinate layout. The next milestone is an explorable camera/build plus chunk/LOD/streaming foundation and Web export preparation.

## AI development
This repository is designed to be usable by autonomous coding agents such as Google Jules. Jules can work directly against GitHub repositories and execute multi-file coding tasks asynchronously. Use the project requirements above as the source of truth and verify changes before merging.

## Local test
Open the project in Godot 4.x and run the main scene. Web deployment requires a Godot Web export and a static hosting target such as Vercel.
