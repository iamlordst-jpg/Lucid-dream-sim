# Lucid Dream Sim — Game Plan

## Vision
A first-person 3D lucid-dream sandbox for iPhone. Explore surreal places, experiment with impossible abilities, and turn thoughts into a world that obeys dream logic.

## Current milestone: 3D playable prototype
- Native iOS app using SwiftUI and SceneKit; no desktop editor needed.
- First-person camera and procedural 3D tile terrain.
- Night-sky stars, glowing dream landmarks, emissive crystals, and atmospheric lighting.
- Tap controls for forward/back/strafe movement.
- Calm/Flux reality shift with different colors.
- Manifest a glowing crystal into the world.
- Teleport to a nearby memory point.
- Prototype abilities: flight toggle, ascend/descend, slow time, gravity reversal, phase-walk mode, world bending, and dream-logic messages.
- GitHub Actions builds an unsigned IPA on a cloud macOS runner.

## Ability catalogue and roadmap

### Core / popular dream powers
- Fly, hover, super-jump, fall slowly, teleport, become invisible, walk through walls, breathe underwater.
- Spawn and delete objects; resize, rotate, recolor, duplicate, or animate objects.
- Time stop, slow motion, rewind a short moment, day/night control.
- Change gravity, walk on walls/ceilings, create portals, open doors to new biomes.
- Change weather, summon fog, rain, snow, auroras, or a storm.
- Transform into simple forms, summon a companion, create a safe zone.

### Surreal / niche dream powers
- Perspective bending: make a distant room larger than a nearby one.
- Recursive doors: enter a door and arrive in a version of the same room.
- Non-Euclidean corridors that connect to unexpected places.
- Make shadows act independently; make reflections show another location.
- Turn sound into visible shapes and color.
- Make memories appear as floating scenes or objects.
- Change the world's rules with dream commands.
- Reverse object behavior, invert colors, fold a landscape, or make a staircase loop.
- Create an echo of a place, revisit it later, and leave messages for your future self.
- Dream weather and biome blending; islands that orbit, rain that rises, and oceans suspended in the sky.
- Lucidity meter, dream journal, recurring landmarks, dream signs, and optional guided exploration.

### Build order
1. **3D foundation:** camera, terrain, touch controls, lighting, reality shift, cloud build.
2. **Movement polish:** drag-to-look, smooth movement, collision rules, flight controls, optional sensitivity settings.
3. **Ability framework:** ability definitions, cooldown-free creative toggles, active-state indicators, effects that truly alter the world.
4. **World generation:** biome families (liminal city, flooded mall, floating islands, endless school, quiet forest), landmarks, portals, and dream events.
5. **Creation tools:** place, rotate, recolor, scale, duplicate, and remove structures; local save/load.
6. **Dream logic:** recursive rooms, perspective tricks, living shadows/reflections, gravity puzzles, and reality rules.
7. **Narrative:** memory fragments, recurring characters, optional quests, and an evolving dream journal.
8. **Polish:** accessibility, haptics, soundscapes, graphics settings, performance tuning for iPhone 11.

## Design principles
- Exploration and creativity over combat.
- Surreal, atmospheric, strange-but-beautiful spaces.
- No required internet connection during gameplay.
- Respect battery and thermal limits on iPhone 11; target a stable 30 FPS first.
- Save locally; no account required.
- Keep every ability optional and discoverable instead of overwhelming the screen.

## Important implementation notes
- This is an early 3D prototype. Some current buttons are first-pass approximations; for example, phase walk currently changes the dream-view mode rather than implementing a full collision system, and gravity reversal currently changes altitude rather than simulating a complete inverted-physics world.
- SceneKit is used to keep the first 3D milestone native and buildable from a Swift project. A larger world can be optimized incrementally.
- Installation on a physical iPhone requires a valid signature and provisioning/sideloading method; the workflow does not bypass Apple's signing requirements.
