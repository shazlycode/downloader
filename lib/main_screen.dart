import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _linkController = TextEditingController();

  Future downloadFile(String url) async {
    final permissionStatus = await Permission.storage.status;
    if (!permissionStatus.isGranted) {
      await Permission.storage.request();
    }

    final dir = await getExternalStorageDirectory();
    final dirFolder = Directory('${dir!.path}/shazlycodeFolder');
    if (dirFolder.existsSync()) {
      print(dirFolder.path);
    } else {
      await dirFolder.create();
    }

    final response = await Dio().get(url,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            receiveTimeout: 0));
    final file = File('${dirFolder.path}/${DateTime.now().toString()}.jpg');
    final raf = file.openSync(mode: FileMode.write);
    raf.writeFromSync(response.data);
    raf.close();
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your downloader'),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              controller: _linkController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                labelText: 'Enter url',
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            ElevatedButton.icon(
                onPressed: () {
                  _linkController.text.isEmpty
                      ? null
                      : downloadFile(_linkController.text);
                },
                icon: Icon(Icons.download),
                label: Text('Download'))
          ],
        ),
      ),
    );
  }
}
