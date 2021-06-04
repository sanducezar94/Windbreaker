import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comments.dart';

import 'storage_service.dart';

const SERVER_IP = '192.168.100.24:8080';
//const SERVER_IP = 'lighthousestudio.ro';
const API_ENDPOINT = '/comment';

class CommentService {
  Future<CommentsPlate> getComments({int route, int page}) async {
    try {
      var client = http.Client();
      var storage = new StorageService();

      var token = await storage.readValue('token');
      var queryParameters = {
        'page': page.toString(),
        'route_id': route.toString()
      };

      var response = await client
          .get(Uri.http(SERVER_IP, API_ENDPOINT, queryParameters), headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + token
      }).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timed out!');
      });

      List<Comment> comments = [];

      var bodyJSON = jsonDecode(response.body);

      for (var comment in bodyJSON["comments"]) {
        comments.add(Comment.fromJson(comment));
      }

      return CommentsPlate(comments: comments, page: page);
    } on SocketException catch (e) {
      return null;
    } on Exception catch (e) {
      return null;
    }
  }

  Future<Comment> addComment({String message, int route}) async {
    try {
      var client = http.Client();
      var storage = new StorageService();

      var token = await storage.readValue('token');

      var response = await client.post(Uri.http(SERVER_IP, API_ENDPOINT),
          body: {
            'text': message,
            'route_id': route.toString()
          },
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer ' + token
          }).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timed out!');
      });

      if (response.statusCode == 201) {
        var comment = Comment.fromJson(jsonDecode(response.body));
        return comment;
      }
      return null;
    } on SocketException catch (e) {
      return null;
    } on Exception catch (e) {
      return null;
    }
  }
}
