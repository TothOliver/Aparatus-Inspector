# Game Design Document: Apparatus Inspector (AWTBG)

**System/Engine:** Godot v4.6  
**Target Platform:** PC  
**Genre:** Retro OS Simulation / Survival Horror  

---

## 1. Executive Summary

### 1.1 Concept
*Apparatus Inspector* (AWTBG) is a high-tension psychological horror game. The player plays as an inspector locked in a retro 3D office space. Sitting at a physical 3D computer monitor, the player must evaluate AI robots through a Windows 98-style desktop simulator, deciding whether to **APPROVE** (Pass) or **EXTERMINATE** (Reject) them based on conversation, diagnostic specs, and anomalies.

Simultaneously, the player must survive physical room threats by managing the office door lock, monitoring live CCTV feeds, purging terminal hacks, and balancing the building's limited power grid.

### 1.2 Core Pillars
*   **Tactile Nostalgia**: Fully simulated retro operating system (Start Menu, Taskbar tabs, custom window positioning, mini-games, and text utilities).
*   **Survival Resource Loop**: Power grid limits physical defenses; players must balance door locking against total blackouts.
*   **Analog Tension**: Decrypting lore secrets, typing manual terminal commands, and managing sanity level under pressure.
*   **Risk/Reward Economy**: A virtual slot machine game ("Casino Slots") that lets players earn funds to buy battery/sanity boosters, at the cost of potential sanity damage from matching robot threats.

---

## 2. Gameplay & Mechanics

### 2.1 The Daily Inspection Loop
*   Each shift (Day 1 to 3) has a quota of robots that must be successfully inspected and processed.
*   **Robot Diagnostics**: The player evaluates the robot's name, model, manufacturer, and status.
*   **Converse & Judge**: Players choose dialog choices in the diagnostic software. If anomalies or threatening behaviors are detected, they must click **EXTERMINATE**. If they are stable, click **ACCEPT**.
*   **Consequences**: Incorrectly passing a dangerous robot or rejecting an innocent one drains player sanity or health.

### 2.2 3D Room Survival
*   **Office Door & Locks**: A heavy security door separates the office from the corridor. The player must type `lock` or `unlock` in the MS-DOS Prompt terminal.
*   **Door Light**: A physical light mesh glows Green (unlocked), Red (locked), or Black (blackout).
*   **The Hallway Threat**: A roaming Hunter Robot patrols the outer corridor. If it finds the door unlocked, it enters and kills the player. If locked, it bangs on the door frame and patrols away.
*   **Power Grid**: Keeping the door locked drains the power percentage. Power consumption scales and drains faster on later days.
*   **Blackouts**: If power hits `0%`, all lights shut down, the computer monitor goes black, the player is kicked out of computer view, and the door unlocks automatically. Power slowly recharges to 10% to reboot the system.

### 2.3 Operating System Desktop (2D Apps)
The desktop runs a simulated OS featuring:
1.  **Apparatus Inspector**: The core diagnostic tool displaying robot models, manufacturers, dialogue choices, and final judgment buttons.
2.  **Notepad**: A text file editor to read and store notes.
3.  **MS-DOS Prompt (Terminal)**: Command line utility supporting files navigation, light toggles, door locking/unlocking, hacking countermeasures, and lore decryption.
4.  **Minesweeper / Snake**: Draggable classic mini-games.
5.  **Security Feed (CCTV)**: Live-streamed video viewport of the corridor camera to track the Hunter Robot.
6.  **Casino Slots**: Virtual slot machine where players bet cash to spin. Features a virtual shop to buy survival boosters. Matching three robot symbols triggers sanity damage.

### 2.4 Hacking Countermeasures
*   In Days 2 & 3, random network intrusions popup focus-locking error dialogs.
*   The player must open the terminal and type `purge [random-code]` (e.g. `purge K9X2`) within 12 seconds to clear the intrusion, otherwise they face a 20-second keyboard lockout.

### 2.5 Lore Decryption
*   Terminal directory contains encrypted files (e.g. `classified_01.enc`).
*   Lore keys are hidden in dialogue choices from specific robots (e.g., specific numbers or developer names).
*   Players decrypt files using the command `decrypt [file] [key]` to unlock classified files about Project Apparatus.

---

## 3. UI/UX & Art Style

### 3.1 3D Physical Space
*   Low-poly, gritty office interior with realistic lighting and physical elements (switches, desk lamps, door lights, and computer monitor).
*   Dynamic camera transitions when sitting at the computer screen or looking around.

### 3.2 2D Windows 98 Simulation
*   Clean light-gray bevel styles and layouts.
*   Retro custom pixel-art icons (48x48) with transparent backgrounds.
*   M 8pt retro pixel typography for extreme readability.
*   High-contrast taskbar elements (black text on light gray tabs, bevel Start button with classic Windows logo flag).
