import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioPlayerManager extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  List<String> playlist = [];
  int currentIndex = 0;
  List<String> playedTracks = [];

  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isPlaying = false;

  AudioPlayer get player => _player;

  AudioPlayerManager() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());

    _player.positionStream.listen((pos) {
      position = pos;
      notifyListeners();
    });

    _player.playerStateStream.listen((state) {
      isPlaying = state.playing;
      notifyListeners();

      if (state.processingState == ProcessingState.completed) {
        playNext();
      }
    });
  }

  Future<void> loadPlaylist(List<String> files, int startIndex) async {
    playlist = files;
    currentIndex = startIndex;
    await _loadCurrentTrack();
  }

  Future<void> _loadCurrentTrack() async {
    if (currentIndex >= 0 && currentIndex < playlist.length) {
      String currentTrack = playlist[currentIndex];
      await _player.setFilePath(currentTrack);
      duration = await _player.duration ?? Duration.zero;

      if (!playedTracks.contains(currentTrack)) {
        playedTracks.add(currentTrack);
      }

      _player.play();
      notifyListeners();
    }
  }

  void togglePlayPause() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
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

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}



// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:audio_session/audio_session.dart';

// class AudioPlayerManager extends ChangeNotifier {
//   final AudioPlayer _player = AudioPlayer();
//   List<String> playlist = [];
//   int currentIndex = 0;
//   List<String> playedTracks = [];

//   Duration duration = Duration.zero;
//   Duration position = Duration.zero;
//   bool isPlaying = false;

//   AudioPlayer get player => _player;

//   AudioPlayerManager() {
//     _init();
//   }

//   Future<void> _init() async {
//     final session = await AudioSession.instance;
//     await session.configure(AudioSessionConfiguration.music());

//     _player.positionStream.listen((pos) {
//       position = pos;
//       notifyListeners();
//     });

//     _player.playerStateStream.listen((state) {
//       isPlaying = state.playing;
//       notifyListeners();

//       if (state.processingState == ProcessingState.completed) {
//         playNext();
//       }
//     });
//   }

//   Future<void> loadPlaylist(List<String> files, int startIndex) async {
//     playlist = files;
//     currentIndex = startIndex;
//     await _loadCurrentTrack();
//   }

//   Future<void> _loadCurrentTrack() async {
//     if (currentIndex >= 0 && currentIndex < playlist.length) {
//       String currentTrack = playlist[currentIndex];
//       await _player.setFilePath(currentTrack);
//       duration = await _player.duration ?? Duration.zero;

//       if (!playedTracks.contains(currentTrack)) {
//         playedTracks.add(currentTrack);
//       }

//       _player.play();
//       notifyListeners();
//     }
//   }

//   void togglePlayPause() {
//     if (_player.playing) {
//       _player.pause();
//     } else {
//       _player.play();
//     }
//   }

//   void playNext() {
//     if (currentIndex < playlist.length - 1) {
//       currentIndex++;
//       _loadCurrentTrack();
//     }
//   }

//   void playPrevious() {
//     if (currentIndex > 0) {
//       currentIndex--;
//       _loadCurrentTrack();
//     }
//   }

//   @override
//   void dispose() {
//     _player.dispose();
//     super.dispose();
//   }
// }
