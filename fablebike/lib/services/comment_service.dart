import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:fablebike/services/database_service.dart';
import 'package:http/http.dart' as http;
import '../models/comments.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'storage_service.dart';

//const SERVER_IP = '192.168.100.24:8080';
const SERVER_IP = 'lighthousestudio.ro/api/fablebike';
const API_ENDPOINT = '/comment';

class CommentService {
  Future<CommentsPlate> getComments({int route, int page}) async {
    try {
      dynamic commentsJson;
      var connectivity = await (Connectivity().checkConnectivity());
      if (connectivity == ConnectivityResult.none) {
        var dbOfflineRouteData = await DatabaseService().query('route', where: 'id = ?', whereArgs: [route], columns: ['page_0', 'page_1', 'page_2']);

        if (dbOfflineRouteData.length == 0 || page > 2 || dbOfflineRouteData.first['page_' + page.toString()] == null) return null;

        commentsJson = jsonDecode(dbOfflineRouteData.first['page_' + page.toString()]);
      } else {
        var client = http.Client();
        var storage = new StorageService();

        var token = await storage.readValue('token');
        var queryParameters = {'page': page.toString(), 'route_id': route.toString()};

        var response = await client.get(Uri.https(SERVER_IP, API_ENDPOINT, queryParameters),
            headers: {HttpHeaders.authorizationHeader: 'Bearer ' + token}).timeout(const Duration(seconds: 5), onTimeout: () {
          throw TimeoutException('Connection timed out!');
        });
        commentsJson = jsonDecode(response.body);

        if (page <= 2) {
          var obj = page == 0
              ? {'page_0': response.body}
              : page == 1
                  ? {'page_1': response.body}
                  : {'page_2': response.body};
          await DatabaseService().update('route', obj, where: 'id = ?', args: [route]);
        }
      }

      List<Comment> comments = [];
      for (var comment in commentsJson["comments"]) {
        comments.add(Comment.fromJson(comment));
      }

      if (page == 0) {
        var db = await DatabaseService().database;

        var pinnedRouteRow = await db.query('routepinnedcomment', where: 'route_id = ?', whereArgs: [route]);
        if (pinnedRouteRow.length > 0) {
          var pinnedRouteComment = pinnedRouteRow.first;
          await db.update('routepinnedcomment', {'username': comments[0].user, 'comment': comments[0].text},
              where: 'id = ?', whereArgs: [pinnedRouteComment['id']]);
        } else if (comments.length > 0) {
          await db
              .insert('routepinnedcomment', {'username': comments[0].user, 'comment': comments[0].text, 'route_id': route, 'usericon_id': comments[0].userId});
        }
      }

      return CommentsPlate(comments: comments, page: page);
    } on SocketException {
      return null;
    } on Exception {
      return null;
    }
  }

  Future<Comment> addComment({String message, int route}) async {
    try {
      var client = http.Client();
      var storage = new StorageService();

      var token = await storage.readValue('token');

      var response = await client.post(Uri.https(SERVER_IP, API_ENDPOINT),
          body: {'text': message, 'route_id': route.toString()},
          headers: {HttpHeaders.authorizationHeader: 'Bearer ' + token}).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timed out!');
      });

      if (response.statusCode == 201) {
        var comment = Comment.fromJson(jsonDecode(response.body));
        return comment;
      }
      return null;
    } on SocketException {
      return null;
    } on Exception {
      return null;
    }
  }
}
