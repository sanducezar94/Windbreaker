import 'dart:io';
import 'dart:ui';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:fablebike/services/authentication_service.dart';
import 'package:fablebike/services/user_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart' as imgPicker;
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

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
    final pickedFile = await picker.getImage(source: imgPicker.ImageSource.gallery, imageQuality: 60);

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
    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Scaffold(
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
                                final sample = await ImageCrop.sampleImage(file: pickedImage, preferredSize: (2000 / scale).round());

                                final croppedImage = await ImageCrop.cropImage(file: sample, area: area);

                                sample.delete();

                                final compressedProfilePic =
                                    await FlutterImageCompress.compressWithList(croppedImage.readAsBytesSync(), minHeight: 200, minWidth: 200, quality: 90);

                                final compressedFile =
                                    await FlutterImageCompress.compressWithList(croppedImage.readAsBytesSync(), minHeight: 48, minWidth: 48, quality: 80);

                                Database db = await DatabaseService().database;
                                var dateNow = DateTime.now().toUtc().toString();
                                var filename = user.username + extension(croppedImage.path);

                                await db.delete('usericon', where: 'user_id = ?', whereArgs: [user.id]);

                                await db.insert('usericon', {'user_id': user.id, 'name': user.username, 'created_on': dateNow, 'blob': compressedFile});

                                await db.insert('usericon',
                                    {'user_id': user.id, 'name': user.username, 'created_on': dateNow, 'blob': compressedProfilePic, 'is_profile': 1});

                                await UserService().uploadProfileImage(compressedFile, filename);

                                setState(() {
                                  imageCache.clear();
                                  Navigator.pop(context);
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
        ));
  }
}
