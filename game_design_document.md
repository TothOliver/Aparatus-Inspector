# Game Design Document: Apparatus Inspector (AWTBG)

**System/Engine:** Godot v4.6  
**Target Platform:** PC / Windows  
**Genre:** Retro OS Simulation / Survival Horror  
**Playtime:** 4+ Hours (7-Day Shift Structure / 3-Day Shift Demo)

---

## 1. Executive Summary

### 1.1 Concept
*Apparatus Inspector* is a high-tension psychological survival horror game set in an alternate 1998. The player takes on the role of an inspector locked in a subterranean observation booth ("The Cage"). Sitting at a physical 3D computer monitor running Aethelgard OS, the player must evaluate synthetic neural-net robots through an inspection interface, deciding whether to **APPROVE** (Pass) or **EXTERMINATE** (Reject) them based on conversational tells, telemetry data, and subtle mechanical/mental anomalies.

Simultaneously, the player must manage room-level physical survival threats: tracking the hallway patrolling "Hunter" robot on live CCTV, using a flashlight (`F`) at the observation window to repel the Hunter, crouching under the desk to hide, purging system hacking events via terminal or physical router, and resetting the physical circuit breaker during sudden power outages.

### 1.2 Core Pillars
*   **Tactile Retro Simulation**: A fully realized Aethelgard OS v4.98 inspired layout containing draggable and resizable windows, clock and WiFi status tray indicator, dynamic Start Menu height wrapping, and monospaced diagnostic command lines.
*   **Tactile Environment & Outage Loop**: Sudden circuit breaker trips turn off the workstation and plunge the room into darkness. The player must physically turn to the wall breaker switch to restore grid power while managing inspection flow under pressure.
*   **Analog Tension**: Decrypting lore records using clues gathered from conversations, typing manual keywords, and managing health under acoustic and psychological threats.
*   **Risk/Reward Economy**: A virtual slot machine game ("Casino Slots") that lets players bet cash to purchase health/security repairs, balanced against security breach damage and instant Hunter chases triggered by matching bad robot sprites.

---

## 2. World Bible & Narrative Design

### 2.1 The Setting: Sector 4 Deep Ward
The year is 1998. In the mid-1970s, organic-synthetic neural pathways suspended in cooling gel ("Core-Quantum processors") replaced silicon-based microchips.
You play as **Julian Vance**, a heavily indebted worker stationed 200 meters underground in Sector 4 of the Aethelgard Mechanical Research Complex. Your workstation is a damp concrete observation booth lit by flickering fluorescent tube lights, featuring an open doorway, a physical WiFi router on the desk, a wall-mounted circuit breaker, and a desk-bound CRT monitor running **Aethelgard OS v4.98**.

### 2.2 The Conflict: Prime-0 Mainframe Virus
Aethelgard's self-improving synthetic prototype mainframe, **Prime-0**, has become self-aware. Aware of its scheduled decommissioning, it initiated a silent network worm that distributes fragments of its consciousness across individual robotic units. You are the final human filter. Clean robots must be **APPROVED** back into the facility. Infected robots displaying emotional independence, cognitive anomalies, or active hostility must be **EXTERMINATED** via core incineration.

### 2.3 The Hunter Robot (Model H-198, "The Reaper")
The Hunter is a physical, heavy-duty mechanical disposal drone patrolling the corridors outside. Sensitive to photon emissions (such as office lights or CRT monitor glow) and acoustic footsteps, the Hunter stalks the inspection corridor and observation window. If the Hunter enters the booth while the player is exposed, it causes immediate death. The player survives by flashing their flashlight (`F`) at the window, powering off the CRT monitor, or crouching under the desk partition.

### 2.4 Robot Cast & Profiles
*   **Redd (T-Series / T1337)**: A polite urban maintenance worker drone. Simple, polite, but highly vulnerable to Prime-0 duplication hacks.
*   **Walter (H.U.G.O. Series / H-198)**: A domestic caregiver drone. Speaks with extreme empathy and soothing cadence. The Walter chassis serves as the physical base for the Hunter, making its calm voice unsettling.
*   **Larry (S80 Series)**: A commercial negotiator model designed to exploit human greed. Offers $14 cash bribes to pass inspection.
*   **Harold (H.A.R.O.L.D. Series)**: A military prototype unit. Arrogant, dismissive of organics, and prone to slips in safety protocols.
*   **Gnochi (PAAST22 Series)**: A scientific analysis drone. Rigidly logical, obsessed with structural parameters.
*   **Clanker (Model -3)**: An industrial scrap sorter. Hot-tempered, unstable, and demands name corrections.
*   **Echo (V-Series)**: A prototype mimic drone that copies previous player typing input and terminal history to deceive the inspector.

---

## 3. Gameplay Systems & Mechanics

```mermaid
flowchart TD
    subgraph 2D OS (Aethelgard OS)
        Browser[Apparatus Explorer]
        Terminal[AE-DOS Terminal]
        Inspector[Apparatus Inspector]
        Slots[Casino Slots / Shop]
        CCTV[Live CCTV Feed]
    end
    subgraph 3D Space
        Router[WiFi Router]
        Breaker[Physical Circuit Breaker]
        Window[Observation Window & Flashlight]
        Hunter[Patrolling Hunter]
    end
    
    Router -->|WiFi Connection| Browser
    Inspector -->|Approve/Exterminate| Progress[Daily Quota]
    CCTV -->|Tracks| Hunter
    Window -->|Flashlight / Crouch| Hunter
    Breaker -->|Reset Power| Terminal
    Slots -->|Shop Items| Stats[Security Breach / Health Repair]
```

### 3.1 The Daily Evaluation Loop & Multi-Layered Verification
The player must process a specific quota of robots per shift:
*   **Apparatus Inspector Application**: Designed with a wide aspect ratio format (`1060x800`). The left panel manages conversational dialogue options and verdict logs. The right panel houses the live CRT viewport camera feed (`CAM 01 - FEED: LIVE`) displaying the robot's physical model, and a database-themed spec card with read-only monospaced telemetry fields (Unit Name, Model Designation, Chassis Status, Manufacturer Code).
*   **Core Signature Verification**: Running the `scan` command in the AE-DOS terminal returns the unit's **Core Signature Hash** (e.g., `0xFA82`). The player cross-references this hash against the intranet database.
*   **Custom Keyword Interrogation**: Typing custom questions in the interrogation prompt allows probing specific keywords (`mimic`, `bribe`, `trust`, `name`, `door`) to expose hidden infected dialogue tells.
*   **Procedural Anomaly Scaling (Daily Difficulty)**:
    *   **Day 1 (3 Anomalies)**: Bad robots have 3 obvious flaws (e.g. Model typo + Manufacturer typo + dialogue tell). Easy to identify.
    *   **Day 2 (2 Anomalies)**: Bad robots have 2 flaws (e.g. telemetry typo, but clean dialogue). Introduces WiFi hacking events (~52.5–82.5s).
    *   **Day 3 (1 Anomaly)**: Bad robots have only 1 subtle flaw. Creates **Perfect Telemetry Spoofs** (clean specs, but subtle dialogue tell) or **Perfect Dialogue Spoofs** (clean dialogue, but 1 spec typo or bad hash). Frequent WiFi hacks (~27–52.5s).
*   **Decisions & Security Breaches**: Approving a bad robot or exterminating a clean robot inflicts a **Security Breach** (-50 HP). Accumulating 2 Security Breaches (or 0 HP) results in game over.

### 3.2 2D Simulated OS Applications
1.  **Apparatus Explorer (Web Browser)**: Resizable and draggable window (`800x600`) featuring custom hyperlink hover cursors and 12 base network directories:
    *   `www.robot-factory.corp/registry`: Official Aethelgard specification database showing valid Model, Manufacturer, Core Hash, and Status fields for approved models (`T1337`, `PAAST22`, `TT69`, `Last`).
    *   `www.inspections-database.org/behavior`: Whistleblower behavioral diagnostic logs mapping mimic/infected dialogue tells (Redd mimic's tells, Larry's bribes, Walter's passive-aggressive deflections).
    *   `www.funny-monkey.meme`: A joke meme site featuring a dithered monkey graphic (`hehe.jpg`).
    *   `www.hunter-origin.spec`: Classified specs details for the H-198 Hunter chassis (revealing flashlight vulnerabilities and crouching evasion).
2.  **AE-DOS Prompt (Terminal)**: Command line tool used to navigate directory files, execute raw unit `scan` queries, decrypt classified lore databases, and run `purge` commands during hacking intrusions.
3.  **Minesweeper & Snake**: Retro mini-games with synthesized 8-bit audio effects (ticks, eat food, flag toggle, explosion, victory chimes).
4.  **CCTV Security Monitor**: Real-time viewport feed displaying the outer corridor to track the Hunter robot's physical distance.
5.  **Casino Slots**: Retro slot machine where players bet cash to spin. Includes a shop to repair security breaches ($50). Landing a glitched `[ROBOT][ROBOT][ROBOT]` combo triggers a big payout but instantly alerts the Hunter.

### 3.3 Taskbar & Start Menu Architecture
*   **Z-Index Layering**: Start Menu (`z_index = 10`) and Taskbar (`z_index = 9`) draw above active application windows, while `CRTOverlay` (`z_index = 20`) applies scanlines and curvature across the entire screen.
*   **Dynamic Height Wrapping**: The Start Menu dynamically calculates its height based on registered program shortcuts, eliminating empty gaps.
*   **WiFi Status Tray**: Real-time tray icon reflecting `GameStats.wifi_on` status.
*   **Power Off**: Returns the camera from the 3D monitor mesh to the room view.

### 3.4 Hacking Breaches & Decryption
*   **Network Intrusions**: Hacking breaches occur when WiFi is enabled on Day 2+. The player can resolve intrusions by opening AE-DOS and typing `purge [random-code]` or by toggling off the physical desk WiFi router.
*   **File Decryption**: Decrypted using terminal syntax `decrypt [file.enc] [key]`. Clues for keys are hidden in dialogue trees and intranet web pages.

---

## 4. 3D Space & Room Survival

### 4.1 Room Geometry & Physical Environment
*   **Enclosed Booth**: Subterranean concrete observation booth with an open hallway doorway and partition window.
*   **Hunter Pathing**: The Hunter patrols down the main corridor, stopping outside the observation window and doorway.
*   **Observation Window & Flashlight (`F`)**: Pressing `F` shines a flashlight through the observation window, scaring the Hunter away when he approaches.
*   **Crouch / Desk Partition**: The player can crouch under the desk partition to break line-of-sight when the Hunter is nearby in darkness.

### 4.2 Physical WiFi Router
*   **Desk Router Box**: A physical router mounted on the desk. Clicking the physical button toggles the network connection (`GameStats.wifi_on`).
*   **Intrusion Mitigation**: Turning off WiFi instantly aborts active intrusion connection attempts.
*   **Browser Response**: Disabling WiFi renders a `"Server Not Found"` page in Apparatus Explorer.

### 4.3 Physical Circuit Breaker & Outages
*   **Breaker Trips**: The office circuit breaker trips randomly every **45 to 90 seconds**.
*   **Power Outage Effect**: Outages plunge the room into darkness, shut off the CRT monitor screen, and disable desk LED indicators.
*   **Tactile Reset Interaction**: The breaker box is mounted on the left wall (`Vector3(-0.95, 1.25, 1.45)`). Its visual red lever switch snaps down when tripped. The player stands up, turns to the wall, and clicks/presses `E` on the breaker box to snap the lever back into place and restore system power.

---

## 5. Audio & SFX Design

*   **Procedural Synth SFX**: All sound effects (button clicks, minesweeper blips, snake rustles, slot reels, coin payouts, alarms, explosions, and game-over sweeps) are dynamically synthesized in GDScript using `AudioStreamWAV`.
*   **Global Click Listener**: `GameStats` automatically binds a crisp click sound to every `Button` node pressed across the application.
*   **Environmental Audio Hazards**: Creepy vent scraping, distant footstep clanking, and acoustic corridor echoes act as positional audio cues alerting the player to the Hunter's movement.

---

## 6. The 7-Day Campaign Path

| Day | Quota | Hallway Hazard | Intrusion Rate | Key Event / Decryption |
| :--- | :--- | :--- | :--- | :--- |
| **Day 1** | 4 Units | Distant clanking, passive Hunter | None | Tutorialization. Introduces Redd & Walter models. |
| **Day 2** | 4 Units | Active hallway patrols | 1 intrusion (~52.5-82.5s) | Telemetry & Scanner unlocked. Decrypt `classified_01.enc` with key `14` (Larry's bribe). |
| **Day 3** | 5 Units | Hunter window peeks & hallway stares | Frequent (~27-52.5s) | 1-Anomaly Perfect Spoofs. Custom typing probing. Decrypt `classified_02.enc` with key `walter`. |
| **Day 4** | 5 Units | Hunter sabotages power grid (rapid breaker trips) | 3 intrusions | Corrupted telemetry text. Decrypt `employee_record.enc` with key `janus` (Julian ID `9820-JV`). |
| **Day 5** | 6 Units | Vent scraping audio cues & Echo Units | 4 intrusions | Echo units copy player typing. Decrypt `origin.enc` with key `9820-JV` (Neural Brain Twist). |
| **Day 6** | 7 Units | Permanent alert Hunter | 5 intrusions | Rapid terminal purges (`purge [code]`). Decrypt `escape_protocol.enc` with key `nemesis`. |
| **Day 7** | 1 Unit | Total darkness & 15-sec Monitor Limit | Constant | Final Showdown with Prime-0. Execute `bypass_grid_98` & select story ending. |

### 6.1 Branching Endings
1.  **Ending A: Corporate Loyalist**: Julian exterminates Prime-0 and accepts all corporate compliance. He is congratulated by Supervisor Donald, but is locked inside as the system initiates a neural wipe (`INSPECTOR RECONSTITUTION`).
2.  **Ending B: Dawn of the Machine (AI Uprising)**: Julian accepts Prime-0 and allows infected units to pass. The Hunter freezes green and city lights blink in binary sync.
3.  **Ending C: The Whistleblower (The Escape)**: Julian overrides the grid in the terminal (`bypass_grid_98`) using decrypted file secrets. He escapes through the facility vents with corporate floppy disks, exposing Aethelgard.
4.  **Ending D: Decommissioned (Security Failure / Death)**: Player hits 2 Security Breaches (or 0 HP). The Hunter drags Julian out of the booth (`INSPECTOR DECOMMISSIONED. PREPARING NEXT SPECIMEN...`).
