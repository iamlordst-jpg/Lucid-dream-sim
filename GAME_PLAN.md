# Lucid Dream Sim — Game Plan

## Vision
A surreal, explorable dream world for iPhone. The player gradually learns to influence reality: changing the dream's mood, manifesting impossible objects, and finding fragments of memory in a world that rearranges itself.

## Prototype features
- Native iOS app using SwiftUI and SpriteKit; no desktop editor needed.
- Procedurally generated, effectively unbounded top-down dream terrain.
- Tap controls for movement, designed for phone screens.
- Two dream states: Calm and Flux, with distinct palettes.
- Manifest a glowing crystal into the world.
- Memory discoveries, counters, ambient particles, and saved progress.

## Planned milestones
1. **Playable foundation:** movement, procedural world, reality shift, manifesting, discoveries, cloud build.
2. **Persistence:** save player coordinates, manifested objects, discovered memory locations, and world seed.
3. **World systems:** biomes (liminal city, flooded mall, floating islands, endless school, quiet forest), portals, landmarks, and dream events.
4. **Building mode:** place, rotate, recolor, and remove dream structures; resource-free creative mode.
5. **Dream powers:** flight, slow fall, teleport, time control, gravity shift, and environment editing.
6. **Narrative:** memory fragments, recurring characters, optional quests, and an evolving dream journal.
7. **Polish:** accessibility, settings, haptics, soundscapes, performance tuning for iPhone 11.

## Design principles
- Exploration and creativity over combat.
- Surreal, atmospheric, strange-but-beautiful spaces.
- No required internet connection during gameplay.
- Respect battery and thermal limits on iPhone 11.
- Save locally; no account required.

## Build pipeline
GitHub Actions uses a macOS runner and XcodeGen to create an Xcode project, compile the iOS app, and package an unsigned IPA. Installation on a physical iPhone requires a valid signature and provisioning/sideloading method; the workflow does not bypass Apple's signing requirements.
