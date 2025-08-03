import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'audio_player.dart'; // <-- IMPORTANT : Assure-toi que le fichier s'appelle bien comme ça

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Folder Picker',
      home: FolderPickerPage(),
    );
  }
}

class FolderPickerPage extends StatefulWidget {
  @override
  _FolderPickerPageState createState() => _FolderPickerPageState();
}

class _FolderPickerPageState extends State<FolderPickerPage> {
  String? selectedDirectory;
  List<FileSystemEntity> musicFiles = [];

  Future<void> pickFolder() async {
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      print("Permission refusée");
      return;
    }

    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath != null) {
      setState(() {
        selectedDirectory = directoryPath;
        musicFiles = _listMusicFiles(directoryPath);
      });
    }
  }

  List<FileSystemEntity> _listMusicFiles(String path) {
    final dir = Directory(path);
    return dir.listSync().where((file) {
      final extension = file.path.split('.').last.toLowerCase();
      return ['mp3', 'wav', 'flac', 'aac'].contains(extension);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sélectionner un dossier')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: pickFolder,
            child: Text('Choisir un dossier'),
          ),
          if (selectedDirectory != null) ...[
            Text('Dossier : $selectedDirectory'),
            Expanded(
              child: ListView.builder(
                itemCount: musicFiles.length,
                itemBuilder: (context, index) {
                  final file = musicFiles[index];
                  final fileName = file.path.split('/').last;
                  return ListTile(
                    title: Text(fileName),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AudioPlayerScreen(filePath: file.path),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ]
        ],
      ),
    );
  }
}
