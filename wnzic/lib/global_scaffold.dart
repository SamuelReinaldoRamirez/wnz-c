import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'audio_player_manager.dart';

class GlobalScaffold extends StatelessWidget {
  final Widget child;

  const GlobalScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          child,
          Align(
            alignment: Alignment.bottomCenter,
            child: Consumer<AudioPlayerManager>(
              builder: (context, manager, child) {
                if (manager.currentTrackPath == null) {
                  return SizedBox.shrink();
                }

                String trackName = manager.currentTrackPath!.split('/').last;

                return Container(
                  color: Colors.black.withOpacity(0.9),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Title + Play/Pause
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              manager.currentTitle,
                              style: TextStyle(color: Colors.white, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              manager.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: manager.togglePlayPause,
                          ),
                        ],
                      ),

                      // SizedBox(height: 8),

                      // Bottom Row: Prev | Slider | Next
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.skip_previous, color: Colors.white),
                            onPressed: manager.playPrevious,
                          ),

                          Expanded(
                            child: StreamBuilder<Duration>(
                              stream: manager.positionStream,
                              builder: (context, snapshot) {
                                final position = snapshot.data ?? Duration.zero;
                                final total = manager.totalDuration;

                                return Slider(
                                  value: position.inSeconds.toDouble().clamp(0.0, total.inSeconds.toDouble()),
                                  min: 0.0,
                                  max: total.inSeconds.toDouble(),
                                  onChanged: (value) {
                                    manager.seekTo(Duration(seconds: value.toInt()));
                                  },
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.white24,
                                );
                              },
                            ),
                          ),

                          IconButton(
                            icon: Icon(Icons.skip_next, color: Colors.white),
                            onPressed: manager.playNext,
                          ),
                        ],
                      ),
                      SizedBox(height: 30)
                    ],
                  ),
                );



              },
            ),
          ),
        ],
      ),
    );
  }
}
