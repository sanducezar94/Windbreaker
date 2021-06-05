import 'dart:io';

import 'package:fablebike/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:fablebike/services/authentication_service.dart';
import 'package:fablebike/services/user_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart' as imgPicker;
import 'package:provider/provider.dart';

class ImagePickerScreen extends StatefulWidget {
  static const route = '/image_picker';
  ImagePickerScreen({Key key}) : super(key: key);

  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  String userImagesDir = "";
  bool _initialized = false;
  File pickedImage = null;
  final picker = imgPicker.ImagePicker();
  final cropKey = GlobalKey<CropState>();
  Future getImage() async {
    if (_initialized) {
      return;
    }
    final pickedFile = await picker.getImage(
        source: imgPicker.ImageSource.gallery, imageQuality: 60);

    _initialized = true;
    setState(() {
      if (pickedFile != null) {
        pickedImage = File(pickedFile.path);
      } else {
        print('NO');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthenticatedUser>(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text('Alege poza de profil')),
      body: Container(
        child: FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Column(
                  children: [
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

                            var storage = new StorageService();

                            final sample = await ImageCrop.sampleImage(
                                file: pickedImage,
                                preferredSize: (2000 / scale).round());

                            final croppedImage = await ImageCrop.cropImage(
                                file: sample, area: area);
                            final compressedFile =
                                await FlutterImageCompress.compressWithList(
                                    croppedImage.readAsBytesSync(),
                                    minHeight: 48,
                                    minWidth: 48,
                                    quality: 80);

                            sample.delete();

                            var savedFile =
                                await storage.createUserIconWithUsername(
                                    croppedImage.path,
                                    user.username,
                                    compressedFile);

                            var req = await UserService()
                                .uploadProfileImage(savedFile);
                            setState(() {
                              pickedImage = savedFile;
                            });
                          } on Exception catch (e) {
                            print(e.toString());
                          }
                        },
                        child: Text('Salveaza')),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Anuleaza'))
                  ],
                );
              } else {
                return Column(
                  children: [CircularProgressIndicator()],
                );
              }
            },
            future: getImage()),
      ),
    );
  }
}
