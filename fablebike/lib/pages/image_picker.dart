import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/services/user_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart' as imgPicker;
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class ImagePickerScreen extends StatefulWidget {
  static const route = '/image_picker';
  final String fileUrl;
  final File file;
  ImagePickerScreen({Key key, this.fileUrl = "", this.file}) : super(key: key);

  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  String userImagesDir = "";
  bool _initialized = false;
  File pickedImage = null;
  final picker = imgPicker.ImagePicker();
  final cropKey = GlobalKey<CropState>();
  Future<void> _getImage;

  Future<void> getImage(BuildContext context) async {
    if (_initialized) {
      return;
    }

    if (widget.file == null) {
      final pickedFile = await picker.getImage(source: imgPicker.ImageSource.gallery, imageQuality: 60);
      if (pickedFile != null) {
        pickedImage = File(pickedFile.path);
      } else {
        Navigator.of(context).pop();
        return;
      }
      setState(() {});
    } else {
      final pickedFile = widget.file;
      if (pickedFile != null) {
        pickedImage = File(pickedFile.path);
      } else {
        Navigator.of(context).pop();
        return;
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_getImage == null) {
      _getImage = getImage(context);
    }

    var user = Provider.of<AuthenticatedUser>(context);

    _saveCroppedImage() async {
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

        final compressedProfilePic = await FlutterImageCompress.compressWithList(croppedImage.readAsBytesSync(), minHeight: 200, minWidth: 200, quality: 90);
        final compressedFile = await FlutterImageCompress.compressWithList(croppedImage.readAsBytesSync(), minHeight: 48, minWidth: 48, quality: 80);

        Database db = await DatabaseService().database;
        var dateNow = DateTime.now().toUtc().toString();

        if (user != null && user.username != 'none') {
          var filename = user.username + extension(croppedImage.path);
          await db.delete('usericon', where: 'user_id = ?', whereArgs: [user.id]);

          await db.insert('usericon', {'user_id': user.id, 'name': user.username, 'created_on': dateNow, 'blob': compressedFile});

          await db.insert('usericon', {'user_id': user.id, 'name': user.username, 'created_on': dateNow, 'blob': compressedProfilePic, 'is_profile': 1});

          await UserService().uploadProfileImage(compressedFile, filename);
        } else {
          await db.delete('usericon', where: 'name = ?', whereArgs: ['profile_pic_registration']);

          await db.insert('usericon', {'name': 'profile_pic_registration', 'created_on': dateNow, 'is_profile': 0, 'blob': compressedFile});

          await db.insert('usericon', {'name': 'profile_pic_registration', 'created_on': dateNow, 'blob': compressedProfilePic, 'is_profile': 1});
        }

        setState(() {
          imageCache.clear();
          Navigator.pop(context);
        });
      } on Exception catch (e) {
        print(e.toString());
      }
    }

    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    'Alege poza de profil',
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  flex: 10,
                ),
                Expanded(
                  child: InkWell(
                    child: Icon(Icons.save),
                    onTap: () async {
                      await _saveCroppedImage().then((value) {
                        setState(() {});
                      });
                    },
                  ),
                  flex: 1,
                )
              ],
            ),
            shadowColor: Colors.white54,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
          ),
          body: Container(
            child: FutureBuilder(
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (!_initialized && (user == null || user.email == 'none')) {
                      _initialized = true;
                      Timer(Duration(milliseconds: 500), () {
                        setState(() {});
                      });
                    }
                    return Column(
                      children: [
                        Expanded(
                          child: pickedImage != null
                              ? Container(
                                  color: Colors.black,
                                  padding: const EdgeInsets.all(20.0),
                                  child: Crop.file(
                                    pickedImage,
                                    key: cropKey,
                                    aspectRatio: 1.0,
                                  ),
                                )
                              : Container(
                                  color: Colors.black,
                                  padding: const EdgeInsets.all(20.0),
                                ),
                          flex: 1,
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [CircularProgressIndicator()],
                    );
                  }
                },
                future: widget.file == null ? _getImage : getImage(context)),
          ),
        ));
  }
}
