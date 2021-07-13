import 'dart:convert';

import 'package:collection/collection.dart';

class Comment {
  int id;
  int userId;
  String user;
  String text;
  String icon;
  Comment({
    this.userId,
    this.id,
    this.text,
    this.user,
    this.icon,
  });

  Comment copyWith({
    int id,
    int userId,
    String text,
    String user,
    String icon,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      user: user ?? this.user,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'id': id,
      'text': text,
      'user': user,
      'icon': icon,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      userId: map['user_id'] ?? 0,
      icon: map['icon'] ?? '',
      text: map['text'] ?? '',
      user: map['user'] ?? '',
      id: map['id'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Comment.fromJson(Map<String, dynamic> source) => Comment.fromMap(source);

  @override
  String toString() {
    return 'Comment(id: $id, userId: $userId, text: $text, user: $user, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Comment && other.id == id && other.userId == userId && other.text == text && other.user == user && other.icon == icon;
  }
}

class CommentsPlate {
  List<Comment> comments;
  int page;

  CommentsPlate({
    this.comments,
    this.page,
  }) {
    this.comments = comments;
    this.page = page;
  }

  CommentsPlate copyWith({
    List<Comment> comments,
    int page,
  }) {
    return CommentsPlate(
      comments: comments ?? this.comments,
      page: page ?? this.page,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'comments': comments?.map((x) => x.toMap())?.toList(),
      'page': page,
    };
  }

  factory CommentsPlate.fromMap(Map<String, dynamic> map) {
    return CommentsPlate(
      comments: List<Comment>.from(map['comments']?.map((x) => Comment.fromMap(x) ?? Comment()) ?? const []),
      page: map['page'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory CommentsPlate.fromJson(String source) => CommentsPlate.fromMap(json.decode(source));

  @override
  String toString() => 'CommentsPlate(comments: $comments, page: $page)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is CommentsPlate && listEquals(other.comments, comments) && other.page == page;
  }
}
