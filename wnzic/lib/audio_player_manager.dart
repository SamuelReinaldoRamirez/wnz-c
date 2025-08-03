import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerManager extends ChangeNotifier {
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  final AudioPlayer player = AudioPlayer();
  List<String> playlist = [];
  int currentIndex = 0;
  String? currentTrackPath;
  bool isPlaying = false;

  Duration get currentPosition => player.position;
  Duration get totalDuration => player.duration ?? Duration.zero;
  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;


  factory AudioPlayerManager() {
    return _instance;
  }

  AudioPlayerManager._internal() {
    _init();
  }

  String get currentTitle => currentTrackPath?.split('/').last ?? 'Aucun titre';

  void _init() {
    player.playerStateStream.listen((state) {
      isPlaying = state.playing;
      notifyListeners();
    });

    player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        playNext();
      }
    });
  }

  void seekTo(Duration position) {
    player.seek(position);
    notifyListeners();
  }


  void loadPlaylist(List<String> tracks, {int startIndex = 0}) async {
    playlist = tracks;
    currentIndex = startIndex;
    await _loadCurrentTrack();
  }

  Future<void> _loadCurrentTrack() async {
    if (currentIndex >= 0 && currentIndex < playlist.length) {
      currentTrackPath = playlist[currentIndex];
      await player.setFilePath(currentTrackPath!);
      player.play();
      notifyListeners();
    }
  }

  void togglePlayPause() {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  void playNext() {
    if (currentIndex < playlist.length - 1) {
      currentIndex++;
      _loadCurrentTrack();
    }
  }

  void playPrevious() {
    if (currentIndex > 0) {
      currentIndex--;
      _loadCurrentTrack();
    }
  }
}
