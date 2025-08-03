import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'audio_player_manager.dart';

class AudioPlayerScreen extends StatefulWidget {
  final List<String> playlist;
  final int initialIndex;

  const AudioPlayerScreen({
    required this.playlist,
    this.initialIndex = 0,
  });

  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _player;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  int _currentIndex = 0;
  List<String> playedTracks = [];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayerManager().player;
    _currentIndex = widget.initialIndex;
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());

    await _loadCurrentTrack();

    _player.positionStream.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
        });
      }
    });

    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }

      if (state.processingState == ProcessingState.completed) {
        _playNext();
      }
    });
  }

  Future<void> _loadCurrentTrack() async {
    if (_currentIndex >= 0 && _currentIndex < widget.playlist.length) {
      String currentTrack = widget.playlist[_currentIndex];
      await _player.setFilePath(currentTrack);
      _duration = await _player.duration ?? Duration.zero;

      if (!playedTracks.contains(currentTrack)) {
        playedTracks.add(currentTrack);
        print("Historique : $playedTracks");
      }

      _player.play(); // Auto play after loading
    }
  }

  void _togglePlayPause() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void _playNext() {
    if (_currentIndex < widget.playlist.length - 1) {
      _currentIndex++;
      _loadCurrentTrack();
    } else {
      print("Fin de la playlist.");
    }
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _loadCurrentTrack();
    } else {
      print("Déjà au début de la playlist.");
    }
  }

  @override
  void dispose() {
    // Ne plus dispose le player ici !
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currentTrackName = widget.playlist[_currentIndex].split('/').last;

    return Scaffold(
      appBar: AppBar(title: Text("Lecture : $currentTrackName")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              iconSize: 64,
              onPressed: _togglePlayPause,
            ),
            Slider(
              value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
              max: _duration.inSeconds.toDouble(),
              onChanged: (value) {
                _player.seek(Duration(seconds: value.toInt()));
              },
            ),
            Text(
              "${_formatDuration(_position)} / ${_formatDuration(_duration)}",
              style: TextStyle(fontSize: 16),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _playPrevious,
                  child: Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: _playNext,
                  child: Text('Next'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text("Historique :"),
            Expanded(
              child: ListView.builder(
                itemCount: playedTracks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(playedTracks[index].split('/').last),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
