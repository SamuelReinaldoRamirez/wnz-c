import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioPlayerScreen extends StatefulWidget {
  final String filePath;

  const AudioPlayerScreen({required this.filePath});

  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final _player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());

    await _player.setFilePath(widget.filePath);

    _duration = await _player.duration ?? Duration.zero;

    _player.positionStream.listen((pos) {
      setState(() {
        _position = pos;
      });
    });

    _player.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lecture : ${widget.filePath.split('/').last}")),
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


// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:audio_session/audio_session.dart';

// class AudioPlayerScreen extends StatefulWidget {
//   final String filePath;

//   const AudioPlayerScreen({required this.filePath});

//   @override
//   _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
// }

// class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
//   final _player = AudioPlayer();
//   Duration _duration = Duration.zero;
//   Duration _position = Duration.zero;
//   bool _isPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     _init();
//   }

//   Future<void> _init() async {
//     final session = await AudioSession.instance;
//     await session.configure(AudioSessionConfiguration.music());

//     // Charge ton fichier audio ici
//     await _player.setFilePath(widget.filePath);
    
//     _duration = _player.duration ?? Duration.zero;

//     _player.positionStream.listen((pos) {
//       setState(() {
//         _position = pos;
//       });
//     });

//     _player.playerStateStream.listen((state) {
//       setState(() {
//         _isPlaying = state.playing;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _player.dispose();
//     super.dispose();
//   }

//   void _togglePlayPause() {
//     if (_player.playing) {
//       _player.pause();
//     } else {
//       _player.play();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Audio Player")),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             IconButton(
//               icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
//               iconSize: 64,
//               onPressed: _togglePlayPause,
//             ),
//             Slider(
//               value: _position.inSeconds.toDouble(),
//               max: _duration.inSeconds.toDouble(),
//               onChanged: (value) {
//                 _player.seek(Duration(seconds: value.toInt()));
//               },
//             ),
//             Text(
//               "${_formatDuration(_position)} / ${_formatDuration(_duration)}",
//               style: TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return "$minutes:$seconds";
//   }
// }
