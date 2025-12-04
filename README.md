# SpotiFly - Spotify Clone

A high-fidelity Spotify clone built with Flutter, focusing on UI/UX and Clean Architecture.

## Features

- **Authentic Design**: Closely mimics Spotify's color scheme, typography, and layout.
- **Clean Architecture**: Separated into Presentation, Domain, and Data layers.
- **Mock Data**: Realistic data simulation for songs, playlists, and artists.
- **Navigation**: Bottom navigation with persistent state.
- **Player**: Mini player and immersive full-screen player with controls.

## Screens

1.  **Home**: Recently played, sections like "Your 2021 in review", "Editor's picks".
2.  **Search**: Browse categories (Pop, Indie, etc.) with vibrant cards.
3.  **Library**: Filterable list of playlists, artists, and albums.
4.  **Player**: Full-screen playback view with adaptive background (mocked).

## Tech Stack

-   **Flutter**: UI Toolkit.
-   **Provider**: State Management.
-   **Google Fonts**: Typography (Inter).
-   **Cached Network Image**: Image caching.

## Getting Started

1.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

2.  **Run the App**:
    ```bash
    flutter run
    ```

## Directory Structure

```
lib/
├── core/
│   ├── theme/          # App colors and theme data
│   └── constants/
├── data/
│   └── repositories/   # Mock data source
├── domain/
│   └── entities/       # Data models (Song, Album, etc.)
├── presentation/
│   ├── pages/          # Screen widgets (Home, Search, Library)
│   ├── widgets/        # Reusable components (Cards, Player, Shell)
│   └── providers/      # State management (PlayerProvider)
└── main.dart           # Entry point
```
