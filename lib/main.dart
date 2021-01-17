import 'package:flutter/material.dart';
import 'dart:html';

import 'package:firebase/firebase.dart' as fb;

int noImages = 0;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meter One',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Meter One Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  fb.UploadTask _uploadTask;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE4EAFF),
      appBar: AppBar(
        leading: new Padding(
          padding: const EdgeInsets.all(1.0),
          child: Image.asset(
            "crop.jpg",
          ),
        ),
        backgroundColor: Colors.white,
        title: Text(
          "Meter One Demo",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton.extended(
              heroTag: 'picker',
              elevation: 5,
              backgroundColor: Color(0XFF69A3FF),
              hoverElevation: 0,
              label: Row(
                children: <Widget>[
                  Icon(Icons.file_upload),
                  SizedBox(width: 10),
                  Text('Upload Video')
                ],
              ),
              onPressed: () => uploadImage(),
            ),
            StreamBuilder<fb.UploadTaskSnapshot>(
              stream: _uploadTask?.onStateChanged,
              builder: (context, snapshot) {
                final event = snapshot?.data;

                // Default as 0
                double progressPercent = event != null
                    ? event.bytesTransferred / event.totalBytes * 100
                    : 0;

                if (progressPercent == 100) {
                  return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text('Video Uploaded'));
                } else if (progressPercent == 0) {
                  return SizedBox();
                } else {
                  return Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          0,
                          15,
                          0,
                          0,
                        ),
                        child: Text(
                          '${(progressPercent).toStringAsFixed(2)} % ',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(80, 15, 80, 0),
                        child: LinearProgressIndicator(
                          value: progressPercent,
                        ),
                      )
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// A "select file/folder" window will appear. User will have to choose a file.
  /// This file will be then read, and uploaded to firebase storage;
  uploadImage() async {
    // HTML input element
    InputElement uploadInput = FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen(
      (changeEvent) {
        final file = uploadInput.files.first;
        final reader = FileReader();
        // The FileReader object lets web applications asynchronously read the
        // contents of files (or raw data buffers) stored on the user's computer,
        // using File or Blob objects to specify the file or data to read.
        // Source: https://developer.mozilla.org/en-US/docs/Web/API/FileReader

        reader.readAsDataUrl(file);
        // The readAsDataURL method is used to read the contents of the specified Blob or File.
        //  When the read operation is finished, the readyState becomes DONE, and the loadend is
        // triggered. At that time, the result attribute contains the data as a data: URL representing
        // the file's data as a base64 encoded string.
        // Source: https://developer.mozilla.org/en-US/docs/Web/API/FileReader/readAsDataURL

        reader.onLoadEnd.listen(
          // After file finiesh reading and loading, it will be uploaded to firebase storage
          (loadEndEvent) async {
            uploadToFirebase(file);
          },
        );
      },
    );
  }

  uploadToFirebase(File imageFile) async {
    final filePath = '$noImages.mp4';
    setState(() {
      noImages += 1;
      _uploadTask = fb
          .storage()
          .refFromURL('gs://hack-the-north-adc4b.appspot.com')
          .child(filePath)
          .put(imageFile);
    });
  }
}
