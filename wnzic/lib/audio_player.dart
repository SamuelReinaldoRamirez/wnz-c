import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioPlayerScreen extends StatefulWidget {
  final String? previous;
  final String current;
  final String? next;

  final Future<String?> Function()? loadNext;
  final Future<String?> Function()? loadPrevious;

  const AudioPlayerScreen({
    required this.previous,
    required this.current,
    required this.next,
    this.loadNext,
    this.loadPrevious,
  });

  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final _player = AudioPlayer();

  List<String> _previousStack = [];
  String _current = "";
  List<String> _nextQueue = [];

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _current = widget.current;

    if (widget.previous != null) _previousStack.add(widget.previous!);
    if (widget.next != null) _nextQueue.add(widget.next!);

    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
    await _loadCurrentTrack();

    _player.positionStream.listen((pos) {
      setState(() {
        _position = pos;
      });
    });

    _player.playerStateStream.listen((state) async {
      setState(() {
        _isPlaying = state.playing;
      });

      if (state.processingState == ProcessingState.completed) {
        await _playNextTrack();
      }
    });
  }

  Future<void> _loadCurrentTrack() async {
    await _player.setFilePath(_current);
    _duration = _player.duration ?? Duration.zero;
    _player.play();
  }

  Future<void> _playNextTrack() async {
    if (_nextQueue.isEmpty) return;

    _previousStack.add(_current);
    _current = _nextQueue.removeAt(0);

    if (widget.loadNext != null) {
      final next = await widget.loadNext!();
      if (next != null) {
        _nextQueue.add(next);
      }
    }

    await _loadCurrentTrack();
  }

  Future<void> _playPreviousTrack() async {
    if (_previousStack.isEmpty) return;

    _nextQueue.insert(0, _current);
    _current = _previousStack.removeLast();

    if (widget.loadPrevious != null) {
      final prev = await widget.loadPrevious!();
      if (prev != null) {
        _previousStack.insert(0, prev);
      }
    }

    await _loadCurrentTrack();
  }

  void _togglePlayPause() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currentFileName = _current.split('/').last;

    return Scaffold(
      appBar: AppBar(title: Text("Lecture : $currentFileName")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous),
                  iconSize: 48,
                  onPressed: _previousStack.isNotEmpty ? _playPreviousTrack : null,
                ),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 64,
                  onPressed: _togglePlayPause,
                ),
                IconButton(
                  icon: Icon(Icons.skip_next),
                  iconSize: 48,
                  onPressed: _nextQueue.isNotEmpty ? _playNextTrack : null,
                ),
              ],
            ),
            Slider(
              value: _position.inSeconds.toDouble(),
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



// AUDIO player grippé : mauvais chargement des musiques
//
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:audio_session/audio_session.dart';

// class AudioPlayerScreen extends StatefulWidget {
//   final String? previous;
//   final String current;
//   final String? next;

//   final Future<String?> Function()? loadNext;
//   final Future<String?> Function()? loadPrevious;

//   const AudioPlayerScreen({
//     required this.previous,
//     required this.current,
//     required this.next,
//     this.loadNext,
//     this.loadPrevious,
//   });

//   @override
//   _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
// }

// class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
//   final _player = AudioPlayer();
//   String? _previous;
//   String _current = "";
//   String? _next;

//   Duration _duration = Duration.zero;
//   Duration _position = Duration.zero;
//   bool _isPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     _previous = widget.previous;
//     _current = widget.current;
//     _next = widget.next;
//     _init();
//   }

//   Future<void> _init() async {
//     final session = await AudioSession.instance;
//     await session.configure(AudioSessionConfiguration.music());
//     await _loadCurrentTrack();

//     _player.positionStream.listen((pos) {
//       setState(() {
//         _position = pos;
//       });
//     });

//     _player.playerStateStream.listen((state) async {
//       setState(() {
//         _isPlaying = state.playing;
//       });

//       if (state.processingState == ProcessingState.completed) {
//         await _playNextTrack();
//       }
//     });
//   }

//   Future<void> _loadCurrentTrack() async {
//     await _player.setFilePath(_current);
//     _duration = _player.duration ?? Duration.zero;
//     _player.play();
//   }

//   Future<void> _playNextTrack() async {
//     if (_next == null) return;

//     _previous = _current;
//     _current = _next!;

//     if (widget.loadNext != null) {
//       _next = await widget.loadNext!();
//     } else {
//       _next = null;
//     }

//     await _loadCurrentTrack();
//   }

//   Future<void> _playPreviousTrack() async {
//     if (_previous == null) return;

//     _next = _current;
//     _current = _previous!;

//     if (widget.loadPrevious != null) {
//       _previous = await widget.loadPrevious!();
//     } else {
//       _previous = null;
//     }

//     await _loadCurrentTrack();
//   }

//   void _togglePlayPause() {
//     if (_player.playing) {
//       _player.pause();
//     } else {
//       _player.play();
//     }
//   }

//   @override
//   void dispose() {
//     _player.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     String currentFileName = _current.split('/').last;

//     return Scaffold(
//       appBar: AppBar(title: Text("Lecture : $currentFileName")),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.skip_previous),
//                   iconSize: 48,
//                   onPressed: _previous != null ? _playPreviousTrack : null,
//                 ),
//                 IconButton(
//                   icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
//                   iconSize: 64,
//                   onPressed: _togglePlayPause,
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.skip_next),
//                   iconSize: 48,
//                   onPressed: _next != null ? _playNextTrack : null,
//                 ),
//               ],
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






//audioplayer sans le next

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

//     await _player.setFilePath(widget.filePath);

//     _duration = await _player.duration ?? Duration.zero;

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
//       appBar: AppBar(title: Text("Lecture : ${widget.filePath.split('/').last}")),
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
//               value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
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
