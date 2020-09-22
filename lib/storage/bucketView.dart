import 'dart:io';
import 'package:flutter/material.dart';

import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_core/amplify_core.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_tutorial/auth/login.dart';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';

class BucketViewer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BucketViewerState();
  }
}

class BucketViewerState extends State<BucketViewer> {
  // used to color the upload button
  bool uploading = false;

  @override
  void initState() {
    super.initState();
  }

  logout() async {
    try {
      Amplify.Auth.signOut();

      // destroy this page and head back to the login screen
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));

    } on AuthError catch (e) {
      Alert(
          context: context,
          type: AlertType.error,
          desc: "Error Logging Out: " + e.toString()).show();
    }
  }

  Future<bool> checkPermission() async {
    final status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      final result = await Permission.storage.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  void downloadFile(StorageItem item) async {
    try {
      var dir = await DownloadsPathProvider.downloadsDirectory;
      var url = await Amplify.Storage.getUrl(
          key: item.key, options: GetUrlOptions(expires: 3600));

      await checkPermission();

      await FlutterDownloader.enqueue(
        url: url.url,
        fileName: item.key.split('/').last,
        savedDir: dir.path,
        showNotification: true,
        openFileFromNotification: true,
      );
    } catch (e) {
      print(e.toString());
    }
  }

  void deleteFile(StorageItem item) async {
    try {
      await Amplify.Storage.remove(
        key: item.key,
      );
    } catch (e) {
      Alert(
              context: context,
              type: AlertType.error,
              desc: "Error Deleting File: " + e.toString())
          .show();
    }
  }

  void uploadFile() async {
    File file = await FilePicker.getFile();
    AuthUser user = await Amplify.Auth.getCurrentUser();

    try {
      if (file.existsSync()) {
        setState(() {
          uploading = true;
        });

        // create <username>/<filename> as the file key
        final key = user.username + '/' + file.path.split('/').last;

        await Amplify.Storage.uploadFile(key: key, local: file);

        // log an upload event, tracking the amount of bytes uploaded
        AnalyticsEvent event = AnalyticsEvent("file_upload_event");

        event.properties.addStringProperty("user", user.username);
        event.properties.addIntProperty("file_size", file.lengthSync());

        Amplify.Analytics.recordEvent(event: event);

        // sends the events to pinpoint (in practice, trigger this on an interval)
        Amplify.Analytics.flushEvents();

        setState(() {
          uploading = false;
        });
      }
    } catch (e) {
      Alert(
          context: context,
          type: AlertType.error,
          desc: "Error Uploading File: " + e.toString());
    }
  }

  Future<List<StorageItem>> listFiles() async {
    try {
      ListResult res = await Amplify.Storage.list();
      AuthUser user = await Amplify.Auth.getCurrentUser();

      // filter list to select only items with our username
      List<StorageItem> items = res.items
          .where((e) => e.key.split('/').first.contains(user.username))
          .toList();

      return items;
    } catch (e) {
      Alert(
          context: context,
          type: AlertType.error,
          desc: "Error Listing Files: " + e.toString());

      // return an empty list if something fails
      return List<StorageItem>(0);
    }
  }

  Widget fileViewer(StorageItem file) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              flex: 3,
              child: Row(
                children: [
                  getFileIcon(file.key.split('/').last),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(file.key.split('/')[1]),
                  )
                ],
              )),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.cloud_download),
                  onPressed: () {
                    downloadFile(file);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    deleteFile(file);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getFileIcon(name) {
    String extension = '.' + name.split('.').last;

    if ('.jpg, .jpeg, .png'.contains(extension)) {
      return Icon(Icons.image, color: Colors.blue);
    }
    return Icon(Icons.archive);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doogle Grive"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            tooltip: 'Logout',
            onPressed: logout,
          )
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: FutureBuilder(
              future: listFiles(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return fileViewer(snapshot.data[index]);
                    },
                    itemCount: snapshot.data.length,
                  );
                } else {
                  return ListView();
                }
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: uploading ? Colors.deepOrange : Colors.blueAccent,
        onPressed: () {
          if (!uploading) uploadFile();
        },
        child: Icon(uploading ? Icons.watch_later : Icons.cloud_upload),
      ),
    );
  }
}
