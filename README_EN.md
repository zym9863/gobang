# Gobang (Five in a Row)

[中文](README.md) | English

A modern Gobang (Five in a Row) game application developed with Flutter.

## Features

- Standard 15x15 board
- Player vs AI mode
- AI supports multiple difficulty levels (Easy/Medium/Hard)
- Undo move functionality
- Real-time game status display
- Elegant visual design
  - Rice paper texture board
  - Smooth animation effects
  - Material Design 3 style interface

## Technical Implementation

### Project Structure

```
lib/
├── main.dart          # Application entry
├── models/            # Data models
│   └── game_model.dart # Game core logic
├── screens/           # Pages
│   └── game_screen.dart # Game main interface
└── widgets/           # Components
    └── game_board.dart  # Game board component
```

### Core Features

- **Game Logic**: Implements complete Gobang rules, including win/loss determination and draw detection
- **AI Opponent**: Uses scoring strategy to implement intelligent AI with different difficulty levels
- **State Management**: Uses Flutter's state management mechanism to ensure UI synchronization with game state
- **Adaptive Layout**: Supports different screen sizes for optimal gaming experience

## Development Environment

- Flutter SDK: ^3.7.0
- Dart SDK: ^3.7.0

## Getting Started

1. Ensure Flutter development environment is installed
2. Clone the project to your local machine
3. Run the following command to install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

## Contribution

Issues and Pull Requests are welcome to help improve this project.

## License

This project is licensed under the MIT License.