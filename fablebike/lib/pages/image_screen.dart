import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fablebike/services/authentication_service.dart';
import 'package:fablebike/services/user_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart' as imgPicker;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

class FilePicker extends StatefulWidget {
  static const route = '/map';
  FilePicker({Key key, this.user}) : super(key: key);

  final AuthenticatedUser user;

  @override
  _FilePickerState createState() => _FilePickerState();
}

class _FilePickerState extends State<FilePicker> {
  String userImagesDir = "";
  File pickedImage = null;
  final picker = imgPicker.ImagePicker();
  final cropKey = GlobalKey<CropState>();
  Future getImage() async {
    final pickedFile = await picker.getImage(
        source: imgPicker.ImageSource.gallery, imageQuality: 60);

    setState(() {
      if (pickedFile != null) {
        pickedImage = File(pickedFile.path);
      } else {
        print('NO');
      }
    });
  }

  File createFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }

    return file;
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthenticatedUser>(context);
    return Container(
        child: Column(
      children: [
        ElevatedButton(onPressed: getImage, child: Icon(Icons.add_a_photo)),
        pickedImage != null
            ? Container(
                color: Colors.black,
                height: 500,
                width: 500,
                padding: const EdgeInsets.all(20.0),
                child: Crop.file(
                  pickedImage,
                  key: cropKey,
                  aspectRatio: 1.0,
                ),
              )
            : Text('no image'),
        ElevatedButton(
            onPressed: () async {
              try {
                final crop = cropKey.currentState;
                final scale = crop.scale;
                final area = crop.area;

                if (area == null) {
                  return;
                }

                final sample = await ImageCrop.sampleImage(
                    file: pickedImage, preferredSize: (2000 / scale).round());

                final file =
                    await ImageCrop.cropImage(file: sample, area: area);
                final compressedFile =
                    await FlutterImageCompress.compressWithList(
                        file.readAsBytesSync(),
                        minHeight: 48,
                        minWidth: 48,
                        quality: 60);

                sample.delete();

                var docDir = await getApplicationDocumentsDirectory();
                String path = docDir.path + '/user_images';
                String extension = p.extension(file.path);
                String fileName = user.username + extension;
                String finalPath = '$path/' + fileName;
                File fifi = createFile(finalPath);
                fifi.writeAsBytesSync(compressedFile);

                var req =
                    await UserService().uploadProfileImage(fifi, fileName);
                setState(() {
                  pickedImage = file;
                });
              } on Exception catch (e) {
                print(e.toString());
              }
            },
            child: Text('Save'))
      ],
    ));
  }
}
