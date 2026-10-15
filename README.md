# Lucid Dream Sim

A native iOS lucid-dream exploration prototype built for iPhone, with a surreal procedural world and reality-bending abilities.

## Current build: first playable foundation

- Native SwiftUI + SpriteKit app.
- Procedurally generated, effectively unbounded dream landscape.
- On-screen movement controls designed for touch.
- **Shift Reality** toggles between calm and flux palettes.
- **Manifest** creates a glowing dream crystal in the world.
- **Memory** guides the player toward a hidden memory point.
- Ambient dream particles, glowing landmarks, discovery counters.
- Local saving for dream counters and reality state.

## Build from an iPhone using GitHub

The project is designed to be edited in GitHub's website on iPhone and compiled by a cloud macOS runner.

1. Open **Actions** in this repository.
2. Select **Build Lucid Dream Sim for iOS**.
3. Tap **Run workflow** on the `main` branch.
4. Open the completed workflow run and download the `LucidDreamSim-unsigned-IPA` artifact.

The workflow uses XcodeGen to generate an Xcode project, then builds for generic iOS device and packages the app as an unsigned IPA.

### Installation note

The IPA produced by this workflow is **unsigned**. It cannot be installed on a physical iPhone just by tapping it. Installation requires a valid signing/provisioning setup or a compatible on-device sideloading workflow. This repository does not store signing certificates, private keys, or Apple account passwords.

## Controls

- Direction buttons: move around the dream.
- **SHIFT REALITY**: switch the dream's visual state.
- **MANIFEST**: create a glowing crystal nearby.
- **MEMORY**: move toward a nearby hidden memory and record a discovery.

## Roadmap

1. Persist the world seed, player position, manifested objects, and discovered locations.
2. Add build mode: place, remove, rotate, and recolor dream structures.
3. Add distinct biomes: endless school, liminal mall, flooded city, floating islands, and quiet forest.
4. Add portals, dream events, and recurring characters.
5. Add flight, teleportation, gravity shifts, time control, and world-editing powers.
6. Add optional story fragments, quests, a dream journal, soundscapes, and settings.
7. Optimize performance and battery use on iPhone 11.

## Technical choices

- **SwiftUI** for the mobile interface.
- **SpriteKit** for lightweight 2D rendering and effects.
- **XcodeGen + GitHub Actions** for a Mac-free development workflow from the user's side.
- Offline-first gameplay; no account or server required.

This is an early prototype. The workflow and source are committed, but a successful build and on-device installation still need to be confirmed by running Actions and completing signing.
