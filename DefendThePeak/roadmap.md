# Defend The Peak - Roadmap

This roadmap outlines the development plan for a roguelike tower defense game prototype. The prototype will focus on procedural map generation, tower defense mechanics, resource management, and modular code for easy feature expansion.

---

## Milestone 1: Project Setup
- [X] Set up a Git repository for version control.
- [X] Configure the Godot Engine project.
- [X] Define project structure and folders for:
  - [X] Scenes
  - [X] Scripts
  - [X] Assets (shapes, icons, etc.)
  - [X] Maps and nodes
- [X] Implement basic game loop structure.

---

## Milestone 2: Procedurally Generated Map
- [ ] Create a branching map system with the following node types:
  - [ ] Combat Nodes
  - [ ] Question Mark Nodes
  - [ ] Shop Nodes
  - [ ] Treasure Chest Nodes
  - [ ] Elite Nodes
  - [ ] Boss Nodes
- [ ] Add visual representation for the map using simple shapes.
- [ ] Implement navigation between nodes.

---

## Milestone 3: Tower Defense Mechanics
- [ ] Develop basic tower placement and removal mechanics.
- [ ] Create simple enemy waves and pathfinding on procedurally generated tracks.
- [ ] Implement tower attack patterns and basic stats (e.g., range, damage, cooldown).
- [ ] Introduce tower upgrade mechanics.

---

## Milestone 4: Resource Management
- [ ] Add resource systems:
  - [ ] Energy: Primary resource for tower placement and upgrades.
  - [ ] Sacrifice mechanics for unlocking abilities or generating bonuses.
  - [ ] Other layered resource systems to enable strategic gameplay.
- [ ] Design a UI for tracking resources.

---

## Milestone 5: Deckbuilding and Relics
- [ ] Implement a system to manage a deck of towers.
- [ ] Allow deck updates via rewards from combat, events, and shops.
- [ ] Introduce relics with unique passive bonuses or gameplay rules.
- [ ] Develop relic synergy mechanics with towers and resources.

---

## Milestone 6: Minimalist Visual Design
- [ ] Create basic placeholder art using shapes and colors for:
  - [ ] Towers
  - [ ] Enemies
  - [ ] Map elements
  - [ ] Resources
- [ ] Add simple animations for tower attacks and enemy movements.

---

## Milestone 7: Expandable Codebase
- [ ] Structure code for modularity:
  - [ ] Use Godot’s scene system for reusable components.
  - [ ] Implement a flexible data-driven system for towers, relics, and events.
  - [ ] Allow easy addition of new node types or mechanics.
- [ ] Write clear and consistent documentation for all systems.

---

## Milestone 8: Balancing and Playtesting
- [ ] Implement balancing tools (e.g., adjustable stats for towers and enemies).
- [ ] Conduct internal playtests to refine mechanics and difficulty.
- [ ] Gather feedback to iterate on gameplay.

---

## Milestone 9: Additional Features (Optional)
- [ ] Introduce deck archetypes to diversify strategic gameplay.
- [ ] Add achievements or challenges for replayability.
- [ ] Expand node variety with new encounters or mini-games.

---

## Milestone 10: Polishing and Delivery
- [ ] Refine all mechanics based on playtesting feedback.
- [ ] Polish visual elements and UI.
- [ ] Prepare prototype for showcasing or further development.

---

## Notes
- Development will use GDScript within the Godot Engine.
- The focus is on gameplay mechanics and modularity rather than detailed graphics.
- Future iterations may introduce advanced graphics, sound design, and additional content.

---

## Timeline
| Milestone                  | Estimated Completion |
|----------------------------|----------------------|
| Milestone 1: Project Setup | Week 1              |
| Milestone 2: Map Generation| Week 2              |
| Milestone 3: TD Mechanics  | Week 3-4            |
| Milestone 4: Resources     | Week 5              |
| Milestone 5: Deck & Relics | Week 6              |
| Milestone 6: Visual Design | Week 7              |
| Milestone 7: Expandable Code| Week 8             |
| Milestone 8: Playtesting   | Week 9              |
| Milestone 9: Additional Features | Week 10+     |
| Milestone 10: Polishing    | Week 11             |

--- 