import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:fablebike/services/comment_service.dart';
import '../../models/comments.dart';
import 'package:provider/provider.dart';

const PAGE_SIZE = 10;

class CommentSection extends StatefulWidget {
  final int route_id;
  final ConnectivityResult connectionStatus;
  final bool canPost;

  CommentSection({Key key, this.route_id, this.connectionStatus, this.canPost}) : super(key: key);

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  int page = 0;
  final TextEditingController commentController = TextEditingController();
  Future<CommentsPlate> getComments;
  List<Comment> comments = [];
  List<Widget> commentWidgets = [];
  bool loadingComments = false;
  AuthenticatedUser user;

  @override
  void initState() {
    super.initState();
    getComments = new CommentService().getComments(page: this.page, route: widget.route_id);
    user = context.read<AuthenticatedUser>();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;
    return Container(
        height: height * 0.75,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: Row(
                  children: [
                    SizedBox(width: 5),
                    InkWell(
                      child: Icon(Icons.arrow_back),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(width: 20),
                    Text(
                      'Comentarii',
                      style: Theme.of(context).textTheme.headline3,
                    )
                  ],
                )),
            Container(
              width: width,
              child: Column(
                children: [
                  Padding(
                    child: Material(
                      child: TextFormField(
                        controller: commentController,
                        decoration: InputDecoration(
                            suffixIcon: InkWell(
                              child: Icon(Icons.send),
                              onTap: () {},
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                            hintText: 'Comentariu nou...'),
                      ),
                      shadowColor: Theme.of(context).accentColor.withOpacity(0.35),
                      borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
                      elevation: 10.0,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 14),
                  )
                ],
              ),
            ),
            FutureBuilder(
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      if (snapshot.data.page == this.page) {
                        this.comments.addAll(snapshot.data.comments);
                        this.page++;
                      }

                      return Container(
                          height: height * 0.6,
                          child: Padding(
                            child: ListView.separated(
                                itemBuilder: (context, index) => _buildComment(context, this.comments[index]),
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    indent: 0,
                                    thickness: 0,
                                  );
                                },
                                itemCount: this.comments.length),
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          ));
                    } else {
                      return commentWidgets.length == 0 ? CircularProgressIndicator() : Column(children: commentWidgets);
                    }
                  } else {
                    return commentWidgets.length == 0 ? CircularProgressIndicator() : Column(children: commentWidgets);
                  }
                },
                future: this.getComments),
          ],
        ));
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

Widget _buildComment(BuildContext context, Comment comment) {
  var user = context.read<AuthenticatedUser>();
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
    child: ListTile(
      minVerticalPadding: 10,
      horizontalTitleGap: 25,
      leading: user.normalDataUsage
          ? FutureBuilder<Uint8List>(
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(48.0),
                      child: Image.memory(snapshot.data, width: 48, height: 48),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                } else {
                  return CircularProgressIndicator();
                }
              },
              future: getIcon(imageName: comment.icon, username: comment.user, userId: comment.userId))
          : Image(image: AssetImage('assets/icons/user.png')),
      title: Text(
        comment.user,
        style: Theme.of(context).textTheme.headline5,
      ),
      subtitle: Text(
        comment.text,
        style: Theme.of(context).textTheme.headline4,
      ),
    ),
  );
}
