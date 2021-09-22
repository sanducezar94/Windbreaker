import 'package:fablebike/bloc/objective_bloc.dart';
import 'package:fablebike/models/comments.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/pages/objective.dart';
import 'package:fablebike/pages/route_map.dart';
import 'package:fablebike/services/connectivity_helper.dart';
import 'package:fablebike/services/route_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:provider/provider.dart';
import 'database_service.dart';
import 'objective_service.dart';

class NavigatorHelper {
  bool isGuestUser(BuildContext context) {
    var user = context.read<AuthenticatedUser>();
    if (user.username == 'GUEST') return true;
    return false;
  }

  buildTimeoutSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(milliseconds: 1500),
        backgroundColor: Theme.of(context).errorColor,
        content: Container(
          height: 32,
          width: 999,
          child: Align(
            alignment: Alignment.center,
            child: Text('Conexiunea nu a putut fi realizata.'),
          ),
        )));
  }

  goToObjective(BuildContext context, Objective objective, Function callBack) async {
    try {
      Loader.show(context, progressIndicator: CircularProgressIndicator(color: Theme.of(context).primaryColor));
      var database = await DatabaseService().database;
      var connectionStatus = ConnectionStatusSingleton.getInstance();

      if (!isGuestUser(context) && connectionStatus.hasConnection) {
        var serverObjective = await ObjectiveService().getObjective(objective_id: objective.id);

        if (serverObjective != null) {
          await database.update('objective', {'rating': serverObjective.rating, 'rating_count': serverObjective.ratingCount},
              where: 'id = ?', whereArgs: [objective.id]);
          objective.rating = serverObjective.rating;
          objective.ratingCount = serverObjective.ratingCount;
          objective.userRating = serverObjective.userRating;
        }
      } else {
        objective.rating = 0;
        objective.ratingCount = 0;
        objective.userRating = 0;
      }

      var objectiveInfo = new ObjectiveInfo(objective: objective, fromRoute: ModalRoute.of(context).settings.name);
      Navigator.of(context).pushNamed(ObjectiveScreen.route, arguments: objectiveInfo).then((newRating) {
        callBack(newRating);
      });
      Loader.hide();
    } on Exception catch (e) {
      Loader.hide();
    }
  }

  goToRoute(BikeRoute route, BuildContext context) async {
    try {
      var connectionStatus = ConnectionStatusSingleton.getInstance();
      Loader.show(context, progressIndicator: CircularProgressIndicator(color: Theme.of(context).primaryColor));
      var database = await DatabaseService().database;
      var routes = await database.query('route', where: 'id = ?', whereArgs: [route.id]);

      var coords = await database.query('coord', where: 'route_id = ?', whereArgs: [route.id]);

      var objToRoutes = await database.query('objectivetoroute', where: 'route_id = ?', whereArgs: [route.id]);

      List<Objective> objectives = [];
      for (var i = 0; i < objToRoutes.length; i++) {
        var objRow = await database.query('objective', where: 'id = ?', whereArgs: [objToRoutes[i]['objective_id']]);
        if (objRow.length > 1 || objRow.length == 0) continue;
        objectives.add(Objective.fromJson(objRow.first));
      }

      var bikeRoute = new BikeRoute.fromJson(routes.first);
      bikeRoute.coordinates = List.generate(coords.length, (i) {
        return Coordinates.fromJson(coords[i]);
      });
      bikeRoute.rtsCoordinates = List.generate(coords.length, (i) => bikeRoute.coordinates[i].toLatLng());
      bikeRoute.elevationPoints = List.generate(coords.length, (i) => bikeRoute.coordinates[i].toElevationPoint());
      bikeRoute.objectives = objectives;

      if (!isGuestUser(context) && connectionStatus.hasConnection) {
        var serverRoute = await RouteService().getRoute(route_id: bikeRoute.id);
        if (serverRoute != null) {
          await database.update('route', {'rating': serverRoute.rating, 'rating_count': serverRoute.ratingCount}, where: 'id = ?', whereArgs: [bikeRoute.id]);
          bikeRoute.rating = serverRoute.rating;
          bikeRoute.ratingCount = serverRoute.ratingCount;
          bikeRoute.commentCount = serverRoute.commentCount;
          bikeRoute.userRating = serverRoute.userRating;
        }

        var db = await DatabaseService().database;

        var pinnedRouteRow = await db.query('routepinnedcomment', where: 'route_id = ?', whereArgs: [bikeRoute.id]);
        if (pinnedRouteRow.length > 0) {
          bikeRoute.pinnedComment = RoutePinnedComment.fromMap(pinnedRouteRow.first);
        }
      } else {
        bikeRoute.rating = 0;
        bikeRoute.ratingCount = 0;
        bikeRoute.commentCount = 0;
        bikeRoute.userRating = 0;
      }
      if (ModalRoute.of(context).settings.name == RouteMapScreen.route) {
        Navigator.of(context).pushReplacementNamed(RouteMapScreen.route, arguments: bikeRoute);
      } else {
        Navigator.of(context).pushNamed(RouteMapScreen.route, arguments: bikeRoute);
      }
      Loader.hide();
    } on Exception catch (e) {
      Loader.hide();
    }
  }
}
