# SpotiFly 🎵

A high-fidelity **Spotify Clone** built with **Flutter**, designed to demonstrate pixel-perfect UI/UX implementation and **Clean Architecture** principles.

![SpotiFly Banner](https://via.placeholder.com/1200x500.png?text=SpotiFly+Banner+Placeholder)

## ✨ Features

- **Authentic Spotify Experience**: meticulous attention to detail in mimicking Spotify's design system, typography (Inter), and animations.
- **Audio Caching & Offline Support**: Smart caching system using `Hive` and `Dio` to allow offline playback of previously streamed songs.
- **Android Auto Support**: Seamless integration with Android Auto for listening on the go.
- **Advanced Playlist Management**: Create, edit, and manage playlists with owner verification.
- **Persistent Player**: Robust audio player handling background playback, lock screen controls, and a draggable mini-player.
- **Clean Architecture & SOLID**: Built with maintainability and scalability in mind, strictly following separation of concerns.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) & [Dart](https://dart.dev/)
- **State Management**: [Bloc / Cubit](https://pub.dev/packages/flutter_bloc)
- **Architecture**: Clean Architecture (Presentation, Domain, Data)
- **Dependency Injection**: [GetIt](https://pub.dev/packages/get_it)
- **Audio Engine**: [just_audio](https://pub.dev/packages/just_audio) & [audio_service](https://pub.dev/packages/audio_service)
- **Local Storage**: [Hive CE](https://pub.dev/packages/hive_ce) (Community Edition)
- **Networking**: [Dio](https://pub.dev/packages/dio) & [Retrofit](https://pub.dev/packages/retrofit)
- **UI Components**: [Shimmer](https://pub.dev/packages/shimmer), [Lottie](https://pub.dev/packages/lottie), [Google Fonts](https://pub.dev/packages/google_fonts)

## 📁 Project Structure

The project follows a feature-first Clean Architecture approach:

```
lib/
├── core/                   # Core utilities, constants, and global configs
│   ├── theme/              # App branding and theme configurations
│   ├── errors/             # Global error handling (Failures, Exceptions)
│   └── usecase/            # Base UseCase definitions
├── features/               # Feature-based modules
│   ├── music_player/       # Music Player logic & UI
│   ├── playlists/          # Playlist management
│   └── home/               # Home screen and discovery
│       ├── data/           # Repositories implementations & Data Sources
│       ├── domain/         # Entities, Repository Interfaces & UseCases
│       └── presentation/   # BLoCs/Cubits, Pages & Widgets
└── main.dart               # App Entry point & Service Locator setup
```

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10.1 or higher)
- Android Studio or VS Code with Flutter extensions.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/nirmalyohannan/spotifly.git
    cd spotifly
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the app:**
    ```bash
    flutter run
    ```

## 🤝 Contributing

Contributions are welcome! Please check out the [issues](https://github.com/nirmalyohannan/spotifly/issues) or submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
*Disclaimer: This is a clone project for educational purposes only. All design rights and trademarks belong to Spotify AB.*
