import 'package:flutter/material.dart';
import '../../domain/entities/song.dart';
import '../../data/repositories/mock_data.dart';

class PlayerProvider extends ChangeNotifier {
  Song? _currentSong = MockData.songs[0]; // Default start with first song
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = MockData.songs[0].duration;

  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;

  void play() {
    _isPlaying = true;
    notifyListeners();
  }

  void pause() {
    _isPlaying = false;
    notifyListeners();
  }
  
  void togglePlay() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void setSong(Song song) {
    _currentSong = song;
    _duration = song.duration;
    _position = Duration.zero;
    _isPlaying = true;
    notifyListeners();
  }

  void seek(Duration position) {
    _position = position;
    notifyListeners();
  }
}
