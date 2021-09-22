import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

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

class RoutePinnedComment {
  int id;
  int routeId;
  String username;
  String comment;
  int userIcon;
  String icon_name;

  RoutePinnedComment({this.id, this.routeId, this.username, this.comment, this.userIcon, this.icon_name});

  RoutePinnedComment copyWith({
    int id,
    int routeId,
    String username,
    String comment,
    int userIcon,
  }) {
    return RoutePinnedComment(
        id: id ?? this.id,
        routeId: routeId ?? this.routeId,
        username: username ?? this.username,
        comment: comment ?? this.comment,
        userIcon: userIcon ?? this.userIcon,
        icon_name: icon_name ?? this.icon_name);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'routeId': routeId, 'username': username, 'comment': comment, 'userIcon': userIcon, 'icon_name': icon_name};
  }

  factory RoutePinnedComment.fromMap(Map<String, dynamic> map) {
    return RoutePinnedComment(
        id: map['id'] ?? 0,
        routeId: map['route_id'] ?? 0,
        username: map['username'] ?? '',
        comment: map['comment'] ?? '',
        userIcon: map['usericon_id'] ?? 0,
        icon_name: map['icon_name'] ?? '');
  }

  String toJson() => json.encode(toMap());

  factory RoutePinnedComment.fromJson(String source) => RoutePinnedComment.fromMap(json.decode(source));
}
