import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:fablebike/services/comment_service.dart';
import '../../models/comments.dart';
import 'package:provider/provider.dart';

const PAGE_SIZE = 10;

class CommentSection extends StatefulWidget {
  final ConnectivityResult connectionStatus;
  final BikeRoute bikeRoute;

  CommentSection({Key key, this.connectionStatus, this.bikeRoute}) : super(key: key);

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
  Widget previousContainer;
  bool forceRemake = false;
  int totalPages;
  @override
  void initState() {
    super.initState();
    totalPages = widget.bikeRoute.commentCount ~/ 5 + (widget.bikeRoute.commentCount % 5 == 0 ? 0 : 1);
    getComments = new CommentService().getComments(page: this.page, route: widget.bikeRoute.id);
    user = context.read<AuthenticatedUser>();
    print(totalPages.toString());
  }

  void _getNextPageComments() {
    if (this.page >= totalPages) return;
    setState(() {
      getComments = new CommentService().getComments(page: this.page, route: widget.bikeRoute.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;
    return Container(
        height: height * 0.8,
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
                        Navigator.of(context).pop(12);
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
                              onTap: () async {
                                var result = await CommentService().addComment(route: widget.bikeRoute.id, message: commentController.text);
                                if (result != null) {
                                  this.comments.insert(0, result);
                                  this.setState(() {
                                    forceRemake = true;
                                    widget.bikeRoute.commentCount += 1;
                                  });
                                }
                                commentController.text = '';
                              },
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
                        previousContainer = null;
                      } else if (previousContainer != null && !forceRemake) {
                        return previousContainer;
                      }

                      forceRemake = false;
                      previousContainer = Container(
                          height: height * 0.6,
                          child: Padding(
                            child: ListView.separated(
                                itemBuilder: (context, index) => _buildComment(
                                    context,
                                    index < this.comments.length ? this.comments[index] : null,
                                    index == this.comments.length,
                                    index == this.comments.length
                                        ? () {
                                            _getNextPageComments();
                                          }
                                        : null),
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    indent: 0,
                                    thickness: 0,
                                  );
                                },
                                itemCount: this.comments.length + 1),
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          ));

                      return previousContainer;
                    } else {
                      return previousContainer != null ? previousContainer : CircularProgressIndicator();
                    }
                  } else {
                    return previousContainer != null ? previousContainer : CircularProgressIndicator();
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
    if (imageName.isEmpty) return null;
    return blobImage.first['blob'];
  }
}

Widget _buildComment(BuildContext context, Comment comment, bool moreButton, VoidCallback onTap) {
  var user = context.read<AuthenticatedUser>();

  if (moreButton) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Center(
            child: ElevatedButton(
          onPressed: onTap,
          child: Icon(Icons.add_circle_outline),
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(12),
          ),
        )));
  } else {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: ListTile(
        minVerticalPadding: 10,
        horizontalTitleGap: 025,
        leading: !user.lowDataUsage
            ? FutureBuilder<Uint8List>(
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(48.0),
                      child: snapshot.data == null
                          ? Image.asset('assets/icons/user.png', width: 48, height: 48)
                          : Image.memory(snapshot.data, width: 48, height: 48),
                    );
                  } else {
                    return Image.asset('assets/icons/user.png', width: 48, height: 48);
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
}
