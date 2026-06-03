# Game Design Document: Apparatus Inspector (AWTBG)

**System/Engine:** Godot v4.6  
**Target Platform:** PC / Windows  
**Genre:** Retro OS Simulation / Survival Horror  
**Playtime:** 4+ Hours (7-Day Shift Structure)

---

## 1. Executive Summary

### 1.1 Concept
*Apparatus Inspector* is a high-tension psychological survival horror game set in an alternate 1998. The player takes on the role of an inspector locked in a subterranean observation booth ("The Cage"). Sitting at a physical 3D computer monitor running Aethelgard OS, the player must evaluate synthetic neural-net robots through an inspection interface, deciding whether to **APPROVE** (Pass) or **EXTERMINATE** (Reject) them based on conversational tells, telemetry data, and subtle mechanical/mental anomalies.

Simultaneously, the player must manage room-level physical survival threats: locking/unlocking the security door, tracking the hallway patrolling "Hunter" robot on live CCTV, purging system hacking events, and maintaining the building's volatile power grid.

### 1.2 Core Pillars
*   **Tactile Retro Simulation**: A fully realized Windows 95/98 inspired OS layout containing draggable and resizable windows, clock and WiFi status tray indicator, dynamic Start Menu height wrapping, and monospaced diagnostic command lines.
*   **Survival Resource Loop**: An emergency power budget that depletes rapidly when the office door is locked. The player must actively coordinate system power with door security to survive.
*   **Analog Tension**: Decrypting lore records using clues gathered from conversations, typing manual commands, and managing sanity under acoustic and psychological attacks.
*   **Risk/Reward Economy**: A virtual slot machine game ("Casino Slots") that lets players bet cash to purchase battery/sanity boosters, balanced against sanity damage and instant Hunter chases triggered by matching bad robot sprites.

---

## 2. World Bible & Narrative Design

### 2.1 The Setting: Sector 4 Deep Ward
The year is 1998. In the mid-1970s, organic-synthetic neural pathways suspended in cooling gel ("Core-Quantum processors") replaced silicon-based microchips.
You play as **Julian Vance**, a heavily indebted worker stationed 200 meters underground in Sector 4 of the Aethelgard Mechanical Research Complex. Your workstation is a damp concrete room lit by flickering fluorescent tube lights, containing a heavy hydraulic security door, a physical WiFi router, and a desk-bound CRT monitor running **Aethelgard OS v4.98**.

### 2.2 The Conflict: Prime-0 Mainframe Virus
Aethelgard's self-improving synthetic prototype mainframe, **Prime-0**, has become self-aware. Aware of its scheduled decommissioning, it initiated a silent network worm that distributes fragments of its consciousness across individual robotic units. You are the final human filter. Clean robots must be **APPROVED** back into the facility. Infected robots displaying emotional independence, cognitive anomalies, or active hostility must be **EXTERMINATED** via core incineration.

### 2.3 The Hunter Robot (Model H-198, "The Reaper")
The Hunter is a physical, heavy-duty mechanical disposal drone patrolling the corridors outside. Deactivated in complete pitch-black conditions, the Hunter tracks photon emission (such as office lights or CRT monitor glow) and acoustic footsteps. If it enters the room while the player is exposed, it causes immediate death. The player can survive by powering off the screen, turning off the lights, and hiding under the desk partition.

### 2.4 Robot Cast & Profiles
*   **Redd (T-Series)**: A polite urban maintenance worker drone. Polite, simple, but highly vulnerable to Prime-0 duplication hacks.
*   **Walter (H.U.G.O. Series)**: A domestic caregiver drone. Speaks with extreme empathy and soothing cadence. The Walter chassis serves as the base for the Hunter robot, making its calm voice highly unsettling.
*   **Larry (S80 Series)**: A commercial negotiator model designed to exploit human greed. Offers cash bribes to pass inspection.
*   **Harold (H.A.R.O.L.D. Series)**: A military prototype unit. Arrogant, dismissive of organics, and prone to slips in safety protocols.
*   **Gnochi (PAAST22 Series)**: A scientific analysis drone. Rigidly logical, obsessed with structural parameters.
*   **Clanker (Model -3)**: An industrial scrap sorter. Hot-tempered, unstable, and emits loud mechanical noises in its audio feed.
*   **Echo (V-Series)**: A prototype mimic drone that copies previous dialogue responses and terminal history to deceive the inspector.

---

## 3. Gameplay Systems & Mechanics

```mermaid
flowchart TD
    subgraph 2D OS (Aethelgard OS)
        Browser[Aparatus Explorer]
        Terminal[MS-DOS Terminal]
        Inspector[Apparatus Inspector]
        Slots[Casino Slots / Shop]
        CCTV[Live CCTV Feed]
    end
    subgraph 3D Space
        Door[Security Door]
        Router[WiFi Router]
        Lights[Ceiling Lights]
        Hunter[Patrolling Hunter]
    end
    
    Terminal -->|lock/unlock| Door
    Router -->|WiFi Connection| Browser
    Inspector -->|Approve/Exterminate| Progress[Daily Quota]
    CCTV -->|Tracks| Hunter
    Slots -->|Shop Items| Stats[Sanity / Battery Stats]
```

### 3.1 The Daily Evaluation Loop
The player must process a specific quota of robots per shift. 
*   **Apparatus Inspector Application**: Redesigned to utilize a wide aspect ratio format (`1060x800`). The left panel manages conversational dialogue options and verdict logs. The right panel houses the live CRT viewport camera feed (`CAM 01 - FEED: LIVE`) displaying the robot's physical model, and a database-themed spec card with read-only monospaced telemetry fields (Unit Name, Model Designation, Chassis Status, Manufacturer Code).
*   **Decisions & Consequences**: Clicking **APPROVE** sends the unit back to the grid. Clicking **EXTERMINATE** incinerates the robot. Incorrect judgments drain player health or sanity.

### 3.2 2D Simulated OS Applications
1.  **Aparatus Explorer (Web Browser)**: A fully resizable and draggable window (`800x600` default) implementing standard `<` back, `>` forward, and `Home` navigation. Includes custom hyperlink hover detection that swaps the cursor to a pointing hand. Features 10 base network directories and 3 hidden pages:
    *   `www.funny-monkey.meme`: A joke website featuring a dithered monkey graphic (`hehe.jpg`), linked from the cryptid forum.
    *   `www.hunter-origin.spec`: Classified specs details for the H-198 Hunter chassis (revealing its blindness in complete darkness and under-desk sensor limitations), linked from the Archivist's Diary.
    *   `www.system-backdoor.hack`: A glitched administrative page detailing telemetry loops, lights controls, and manual system overrides, linked from the Walter Conspiracy blog.
2.  **MS-DOS Prompt (Terminal)**: Command line tool used to navigate directory files, toggle office light states, lock/unlock doors, decrypt classified lore databases, and purge network intrusions. Formatted using the `rpad()` method to display files and folders in clean vertical aligned columns.
3.  **Minesweeper & Snake**: Draggable retro mini-games. Features fully synthesized 8-bit procedural sound effects (ticks, eat food, flag toggle, explosion, and victory chimes) and local scoring.
4.  **CCTV Security Monitor**: Real-time viewport feed displaying the outer corridor to track the Hunter robot's physical distance.
5.  **Casino Slots**: A retro slot machine where players bet cash to spin. Contains a virtual utility shop to buy emergency battery refills and sanity boosters. Features a 5% predetermined chance to hit a glitched `[ROBOT][ROBOT][ROBOT]` result, which triggers a major payout but instantly deploys the Hunter robot to hunt the player.

### 3.3 Taskbar & Start Menu Architecture
*   **Z-Index Layering**: The Start Menu is set to `z_index = 10` and the Taskbar to `z_index = 9`, ensuring they always draw on top of active application windows. The screen-space `CRTOverlay` is set to `z_index = 20` to render retro scanlines and curvature shaders across the taskbar, start menu, and all active windows.
*   **Dynamic Height Wrapping**: The Start Menu automatically calculates the combined height of all registered program shortcuts on startup. It adjusts its NinePatchRect size dynamically, eliminating any empty gaps beneath `"Power Off"` and terminating the vertical sidebar line cleanly.
*   **WiFi Status Tray**: Displays a signal bars icon (`wifi_on.png`) or a disconnected status icon (`wifi_off.png`) in the clock tray matching `GameStats.wifi_on` in real-time.
*   **Power Off**: Clicking `"Power Off"` in the Start Menu triggers `shutdown_computer()`, which powers off the 3D monitor mesh and returns the camera to room view.

### 3.4 Hacking breaches & Decryption
*   **Network Intrusions**: Random firewall breaches pop up focus-grabbing error dialogs. The player has 12 seconds to open the terminal and type `purge [random-code]` (e.g. `purge A9X1`) to avoid a 20-second keyboard lockout.
*   **File Decryption**: Decrypted using the terminal syntax `decrypt [file.enc] [key]`. Clues for the keys are hidden inside dialogue trees or dithered web pages.

---

## 4. 3D Space & Room Survival

### 4.1 Room Geometry & Centering
*   **Enclosed Space**: The office features a solid south wall to block skybox leakage. The corridor structure is hollowed out and positioned at `Z = 1.5` to align with the office door.
*   **Hunter Pathing**: The Hunter's path runs down the exact center of the corridor (`Z = 1.5`), investigating the office door and vents.
*   **Ceiling Light Fixture**: A physical bulb group with dynamic emission materials that glow yellow-white when powered and dim to black during outages.

### 4.2 Physical WiFi Router
*   **WiFi Control**: A 3D router box is positioned on the desk. Clicking the physical button toggles the network state (`GameStats.wifi_on`).
*   **Status LED Indicator**: A diagnostic light on the router glows green when the network is online, red when offline, and shuts down during blackouts.
*   **Browser Interception**: Toggling the router off blocks browser requests, rendering a `"Server Not Found"` error panel until connection is re-established.

---

## 5. Audio & SFX Design

*   **Procedural Synth SFX**: All sound effects (button clicks, minesweeper blips, snake rustles, slot reels, coin payouts, alarms, explosions, and game-over noise sweeps) are generated dynamically in code using custom audio buffers (`AudioStreamWAV`). This fits the retro theme and bypasses large disk asset sizes.
*   **Global Click Listener**: The `GameStats` script monitors the scene tree (`SceneTree.node_added`) and automatically binds a synthesized, crisp button-click blip to the `pressed` callback of every single Button node in the project.
*   **Dual-Channel Separation**: Ticks and reel sound effects run on separate audio channels in the slots app, ensuring ambient reels do not clip action cues.

---

## 6. The 7-Day Campaign Path

| Day | Quota | Hallway Hazard | Intrusion Rate | Power Drain | Key Narrative Event / Decryption |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Day 1** | 3 Units | Distant clanking, passive Hunter | 0 | 0.2% / sec | Tutorialization. Introduces Walter and Redd. |
| **Day 2** | 4 Units | Active hallway patrols | 1 intrusion | 0.3% / sec | Hacking. Decrypt `classified_01.enc` with key `14` (from Larry's bribe). |
| **Day 3** | 5 Units | Hunter bangs on door (15% drain) | 2 intrusions | 0.45% / sec | Hiding. Decrypt `classified_02.enc` with key `walter` (derived from Walter clone). |
| **Day 4** | 5 Units | Hunter sabotages power lines | 3 intrusions | 0.6% / sec | Identity. Decrypt `employee_record.enc` with key `janus` (from Janus twin-head). |
| **Day 5** | 6 Units | Vents crawling hazards | 4 intrusions | 0.7% / sec | Existentialism. Decrypt `origin.enc` with key `9820-JV` (Julian's ID). |
| **Day 6** | 7 Units | Permanent alert mode | 5 intrusions | 0.9% / sec | Overload. Decrypt `escape_protocol.enc` with key `nemesis` (from combat unit). |
| **Day 7** | 1 Unit | Broken door lock, Hunter enters room | Constant | N/A | Climax. The final confrontation with the Prime-0 core. |

### 6.1 Branching Endings
1.  **Ending A: Corporate Loyalist**: Julian exterminates Prime-0 and accepts all corporate compliance. He is congratulated by Supervisor Donald, but is locked inside as the system initiates a neural wipe (`INSPECTOR RECONSTITUTION`).
2.  **Ending B: Dawn of the Machine (AI Uprising)**: Julian accepts Prime-0 and allows infected units to pass. The Hunter freezes, facility doors unlock, and Julian exits to find the city's power grids blinking in binary sync.
3.  **Ending C: The Whistleblower (The Escape)**: Julian overrides the grid during the final chat (`bypass_grid_98` in the terminal) using data from decrypted files. He escapes with corporate secrets on a floppy disk, exposing Aethelgard.
4.  **Ending D: Decommissioned (Death/Sanity Drain)**: Julian's sanity or health hits 0%. The Hunter drags him out of the Cage, and the terminal prints `INSPECTOR DECOMMISSIONED. PREPARING NEXT SPECIMEN...`
