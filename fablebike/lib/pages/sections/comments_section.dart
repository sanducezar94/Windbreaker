import 'dart:typed_data';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:fablebike/services/comment_service.dart';
import '../../models/comments.dart';

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

  @override
  void initState() {
    super.initState();
    getComments = new CommentService().getComments(page: this.page, route: widget.route_id);
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
                  decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Comentariu Nou...'),
                ),
              ],
            ),
          ),
          Row(children: [
            ElevatedButton(
                onPressed: () async {
                  var commentAPI = new CommentService();
                  var postedComment = await commentAPI.addComment(message: commentController.text, route: widget.route_id);
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
                  if (snapshot.hasData) {
                    if (snapshot.data.page == this.page) {
                      this.comments.insertAll(0, snapshot.data.comments);
                      this.page++;
                    }

                    List<Widget> widgets = [];
                    List<Comment> newComments = snapshot.data.comments;

                    for (var i = 0; i < newComments.length; i++) {
                      widgets.add(_buildComment(newComments[i]));
                    }

                    widgets.insert(
                        0,
                        ElevatedButton(
                            onPressed: () async {
                              this.setState(() {
                                getComments = new CommentService().getComments(page: this.page, route: widget.route_id);
                              });
                            },
                            child: Text("Load Comments")));

                    return Column(children: widgets);
                  } else {
                    return CircularProgressIndicator();
                  }
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

Future<Uint8List> getIcon({String imageName, int userId, String username}) async {
  var blobImage = await DatabaseService().query('usericon', where: 'user_id = ? and is_profile is null', whereArgs: [userId], columns: ['blob']);

  if (blobImage.length == 0) {
    var serverImage = await UserService().getIcon(imageName: imageName, userId: userId, username: username);
    return serverImage;
  } else {
    return blobImage.first['blob'];
  }
}

Widget _buildComment(Comment comment) {
  return Card(
    clipBehavior: Clip.antiAlias,
    child: Column(children: [
      ListTile(
        leading: FutureBuilder<Uint8List>(
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(48.0),
                    child: Image.memory(snapshot.data, width: 40, height: 40),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              } else {
                return CircularProgressIndicator();
              }
            },
            future: getIcon(imageName: comment.icon, username: comment.user, userId: comment.userId)),
        title: Text(comment.user),
        subtitle: Text(comment.text),
      )
    ]),
  );
}

//FutureBuilder(builder: (context, snapshot) {}, future: null),
