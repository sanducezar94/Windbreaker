import 'dart:convert';
import 'dart:io';

import 'package:fablebike/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:fablebike/services/comment_service.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/comments.dart';
import 'package:path/path.dart' as p;

const PAGE_SIZE = 10;

class CommentSection extends StatefulWidget {
  final int route_id;

  CommentSection({Key key, this.route_id}) : super(key: key);

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  int page = 0;
  final TextEditingController commentController = TextEditingController();
  Future<CommentsPlate> getComments;
  List<Comment> comments = [];

  String userImagesPath = "";

  @override
  void initState() {
    super.initState();
    getComments = new CommentService()
        .getComments(page: this.page, route: widget.route_id);
    setPath();
  }

  void setPath() async {
    await getApplicationDocumentsDirectory().then((directory) {
      userImagesPath = directory.path + '/user_images';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            child: Column(
              children: [
                TextField(
                  controller: this.commentController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Comentariu Nou...'),
                ),
              ],
            ),
          ),
          Row(children: [
            ElevatedButton(
                onPressed: () async {
                  var commentAPI = new CommentService();
                  var postedComment = await commentAPI.addComment(
                      message: commentController.text, route: widget.route_id);
                  if (postedComment != null) {
                    this.setState(() {
                      this.comments.insert(0, postedComment);
                    });
                  }
                },
                child: Text("Posteaza")),
          ]),
          FutureBuilder(
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  snapshot = snapshot.inState(ConnectionState.none);
                  if (snapshot.data.page == this.page) {
                    this.comments.insertAll(0, snapshot.data.comments);
                    this.page++;
                  }

                  List<Widget> widgets = [];
                  List<Comment> newComments = snapshot.data.comments;

                  for (var i = 0; i < newComments.length; i++) {
                    var filePath = p.join(userImagesPath, newComments[i].icon);
                    var fileExists = File(filePath).existsSync();
                    if (fileExists) {
                      widgets
                          .add(_buildComment(newComments[i], File(filePath)));
                    } else {
                      widgets.add(_buildComment(newComments[i], null));
                    }
                  }

                  widgets.insert(
                      0,
                      ElevatedButton(
                          onPressed: () async {
                            this.setState(() {
                              getComments = new CommentService().getComments(
                                  page: this.page, route: widget.route_id);
                            });
                          },
                          child: Text("Load Comments")));

                  return Column(children: widgets);
                } else {
                  return CircularProgressIndicator();
                }
              },
              future: this.getComments),
        ],
      ),
    );
  }
}

Future<String> getIcon({String imageName}) async {
  var userService = new UserService();
  var filePath = new UserService().getIcon(imageName: imageName);
  return filePath;
}

Widget _buildComment(Comment comment, File image) {
  return Card(
    clipBehavior: Clip.antiAlias,
    child: Column(children: [
      ListTile(
        leading: image != null
            ? Image.file(image)
            : comment.icon == null
                ? Icon(Icons.account_box)
                : FutureBuilder(
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return Image.file(File(snapshot.data));
                        } else {
                          return CircularProgressIndicator();
                        }
                      }
                    },
                    future: getIcon(imageName: comment.icon)),
        title: Text(comment.user),
        subtitle: Text(comment.text),
      )
    ]),
  );
}

//FutureBuilder(builder: (context, snapshot) {}, future: null),
