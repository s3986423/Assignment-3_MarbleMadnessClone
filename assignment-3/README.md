
## Table of Contents
- [How to Compile and Run](#how-to-compile-and-run)
- [Game Controls](#game-controls)
- [Game Obstacles](#game-obstacles)
- [Project Structure](#project-structure)

## How to Compile and Run

### Prerequisites
- **Godot Engine 4.4** or later
- Download from [https://godotengine.org/download](https://godotengine.org/download)

### Steps to Run the Game

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd assignment-3-sgs-projectgroups2
   ```

2. **Open in Godot**
   - Launch Godot Engine
   - Click "Import" on the project manager
   - Navigate to the `assignment-3` folder
   - Select the `project.godot` file
   - Click "Import & Edit"

3. **Run the Game**
   - Press `F5` or click the "Play" button in the top-right corner
   - If prompted to select a main scene, choose the main scene file
   - The game will launch in a new window

### Alternative: Running from Command Line
```bash
# Navigate to the assignment-3 directory
cd assignment-3

# Run with Godot (if Godot is in your PATH)
godot --main-pack .
```

### Exporting the Game
1. Go to **Project > Export**
2. Add an export template for your target platform
3. Configure export settings
4. Click "Export Project" to create a standalone executable

## Game Controls
- **WASD** or **Arrow Keys**: Move player
- **Space**: Jump
- **Mouse**: Look around/Camera control

## Game Obstacles

The game features a variety of challenging obstacles designed to test the player's platforming skills:

### **Moving Platforms**
- **Straight Moving Platform**: Platforms that move back and forth along a defined path
- **Accelerate Platform**: Platforms that boost the player's speed when stepped on
- **Unstable Platform**: Platforms that collapse after a few seconds when the player stands on them, then restore after a delay

### **Deadly Hazards**
- **Swinging Axe**: Large axes that swing back and forth, dealing fatal damage on contact
- **Spike Roller**: Rolling spiked obstacles that instantly kill the player on contact
- **Spike Spinning Log**: Rotating logs covered in spikes that patrol areas
- **Death Plane**: Invisible kill zones that reset the player when fallen into

### **Dynamic Obstacles**
- **Spinning Log**: Rotating wooden logs that can knock players off course
- **Swiper**: Horizontal sweeping obstacles that move across the player's path
- **Double Swiper**: Two swipers working in tandem for increased difficulty
- **Bouncer**: Spring-loaded platforms that launch players in specific directions

### **Interactive Elements**
- **Checkpoint**: Save points that allow players to respawn at specific locations
- **Goal**: The finish line that players must reach to complete the level
- **Finish Area**: Designated completion zones for each stage


## Project Structure

```
assignment-3/
├── project.godot          # Main Godot project file
├── Assets/               # Game assets (models, textures, audio)
├── Characters/           # Player and character-related scripts
├── Components/           # Obstacle and interactive element scripts
├── Level Design/         # Level design files and scenes
├── Stages/              # Individual game stages/levels
├── System/              # Core game systems and managers
└── UI/                  # User interface elements
```
