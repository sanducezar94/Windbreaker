class Comment {
  int id;
  String text;
  String user;
  String icon;

  Comment() {}

  Comment.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        text = json['text'],
        user = json['user'],
        icon = json['icon'];
}

class CommentsPlate {
  List<Comment> comments;
  int page;

  CommentsPlate({int page, List<Comment> comments}) {
    this.comments = comments;
    this.page = page;
  }
}
