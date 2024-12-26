
# Brick Breaker ASMx86

## Overview
Brick Breaker ASMx86 is a retro-style arcade game built using assembly language for x86 architecture. It offers exciting features such as multiplayer support via serial communication, a chat feature in the main menu, and unique power-ups to enhance gameplay.

## Features

### 1. Multiplayer Mode
- Play against a friend using serial communication.
- Synchronize gameplay for an engaging competitive experience.

### 2. Chat Feature
- Use the chat feature in the main menu to communicate with your opponent before starting the game.
- Supports basic text messaging over serial communication.

### 3. Power-Up System
- Hit a special red block to gain an additional life point, giving you an edge in challenging levels.

### 4. Classic Brick Breaker Gameplay
- Control the paddle to bounce the ball and break all the bricks.
- Progressive levels with increasing difficulty.

---

## Installation

### Requirements
- An x86-compatible computer or emulator.
- Serial communication hardware or virtual COM ports (if running on real hardware).
- [DOSBox](https://www.dosbox.com/) or equivalent for emulation.

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/AmrSamy59/Brick-Breaker-ASMx86.git
   ```
2. Copy the required executable files:
   - Copy the `.exe` files from the `8086` folder (e.g., `tasm`, `link`, etc.) into the project folder.
3. Edit the `mount` folder:
   - Modify the path in the `run.py` script to point to your project folder.
4. Edit the DOSBox path:
   - Update the DOSBox path in the `run.py` script to match your DOSBox installation directory.
5. Run the `run.py` script:
   ```bash
   python run.py
   ```

---

## Controls
- **Arrow Keys**: Move the paddle left and right.
- **Enter**: Start the game in main menu.
- **C**: Start the chat in main menu.
- **Esc**: exit the game/chat synchronously for both players.

---

## Gameplay
Watch the gameplay in action:

![Gameplay GIF](https://github.com/AmrSamy59/Brick-Breaker-ASMx86/blob/main/readme-assets/gameplay.gif)

---

## Multiplayer Setup
1. Connect two computers using a serial cable or set up virtual COM ports.
2. Launch the game on both systems.
3. Use the chat feature in the main menu to ensure proper connection.
4. Start the multiplayer game and enjoy!

---

## Development

### Power-Up Mechanism
- The game features a unique power-up: hit the red block to gain an extra life point.

### Serial Communication
- Multiplayer and chat features rely on serial communication protocols.
- Ensure proper hardware setup or emulation for seamless communication.

---

## Future Enhancements
- Add more power-ups (e.g., wider paddle, speed control).
- Introduce new brick designs and level layouts.
- Enhance chat functionality with emojis or predefined messages.

---

## Credits
- **Developers**: [Amr Samy](https://github.com/AmrSamy59), [Anas Magdy](https://github.com/Mag-D-Anas), [Shady Mohamed](https://github.com/shady-2004), [Tasneem Mohamed](https://github.com/Tasneemmohammed0)

---

## Screenshots
### Main Menu
![Main Menu](https://github.com/AmrSamy59/Brick-Breaker-ASMx86/blob/main/readme-assets/MainMenu.png)
### Multiplayer Chat
![Chat Screen](https://github.com/AmrSamy59/Brick-Breaker-ASMx86/blob/main/readme-assets/Chat.png)

---
