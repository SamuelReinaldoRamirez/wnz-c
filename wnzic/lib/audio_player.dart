import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'audio_player_manager.dart';

class AudioPlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final playerManager = context.watch<AudioPlayerManager>();

    String currentTrackName = playerManager.playlist.isNotEmpty
        ? playerManager.playlist[playerManager.currentIndex].split('/').last
        : 'Aucune piste';

    return Scaffold(
      appBar: AppBar(title: Text("Lecture : $currentTrackName")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(playerManager.isPlaying ? Icons.pause : Icons.play_arrow),
              iconSize: 64,
              onPressed: playerManager.togglePlayPause,
            ),
            Slider(
              value: playerManager.position.inSeconds.toDouble().clamp(0, playerManager.duration.inSeconds.toDouble()),
              max: playerManager.duration.inSeconds.toDouble(),
              onChanged: (value) {
                playerManager.player.seek(Duration(seconds: value.toInt()));
              },
            ),
            Text(
              "${_formatDuration(playerManager.position)} / ${_formatDuration(playerManager.duration)}",
              style: TextStyle(fontSize: 16),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: playerManager.playPrevious,
                  child: Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: playerManager.playNext,
                  child: Text('Next'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text("Historique :"),
            Expanded(
              child: ListView.builder(
                itemCount: playerManager.playedTracks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(playerManager.playedTracks[index].split('/').last),
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

