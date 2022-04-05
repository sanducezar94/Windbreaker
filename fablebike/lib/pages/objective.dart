import 'dart:math';
import 'dart:ui';
import 'package:fablebike/bloc/event_constants.dart';
import 'package:fablebike/bloc/main_bloc.dart';
import 'package:fablebike/constants/language.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/pages/sections/gradient_icon.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/services/navigator_helper.dart';
import 'package:fablebike/services/objective_service.dart';
import 'package:fablebike/widgets/card_builder.dart';
import 'package:fablebike/widgets/routes_carousel.dart';
import 'package:flutter/material.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class ObjectiveScreen extends StatefulWidget {
  static const route = 'objective';
  final String fromRoute;

  final Objective objective;
  ObjectiveScreen({Key key, @required this.objective, this.fromRoute}) : super(key: key);

  @override
  _ObjectiveScreenState createState() => _ObjectiveScreenState();
}

class _ObjectiveScreenState extends State<ObjectiveScreen> {
  Future<bool> _getObjectiveData(int userId, int objectiveId) async {
    var db = await DatabaseService().database;

    var rows = await db.query('objectivebookmark', where: 'user_id = ? and objective_id = ?', whereArgs: [userId, objectiveId]);
    return rows.length > 0;
  }

  Future<List<BikeRoute>> _getRoutes() async {
    var database = await DatabaseService().database;
    var routes = await database.query('route');

    List<BikeRoute> bikeRoutes = List.generate(routes.length, (i) {
      return BikeRoute.fromJson(routes[i]);
    });
    List<BikeRoute> returnList = [];
    for (var i = 0; i < bikeRoutes.length; i++) {
      var objToRoutesRow =
          await database.query('objectivetoroute', where: 'objective_id = ? and route_id = ?', whereArgs: [widget.objective.id, bikeRoutes[i].id]);

      if (objToRoutesRow.length > 0) {
        returnList.add(bikeRoutes[i]);
      }
    }

    return returnList;
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 3000);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);
    var user = Provider.of<AuthenticatedUser>(context);
    double smallDivider = 10.0;
    double bigDivider = 20.0;

    _buildEvaluateSection() {
      return Column(children: [
        Row(children: [
          Text(
            context.read<LanguageManager>().routeEvaluate,
            style: Theme.of(context).textTheme.headline2,
            textAlign: TextAlign.start,
          )
        ]),
        SizedBox(height: smallDivider),
        Container(
            child: CardBuilder.buildInteractiveStars(context, widget.objective.userRating, 48.0, callBack: (int rating) async {
          Loader.show(context, progressIndicator: CircularProgressIndicator(color: Theme.of(context).primaryColor));
          var newRating = await ObjectiveService().rateObjective(rating: rating, objective_id: widget.objective.id);

          if (newRating == null || newRating == 0.0) {
            Loader.hide();
            return;
          }
          widget.objective.rating = newRating;
          if (widget.objective.userRating == 0) widget.objective.ratingCount += 1;

          var db = await DatabaseService().database;
          await db.update('objective', {'rating': newRating, 'rating_count': widget.objective.ratingCount}, where: 'id = ?', whereArgs: [widget.objective.id]);
          Provider.of<MainBloc>(context, listen: false).objectiveEventSync.add(Constants.HomeRefreshBookmarks);
          Loader.hide();
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(milliseconds: 800),
              backgroundColor: Theme.of(context).primaryColor,
              content: Text('Votul a fost inregistrat cu succes!')));
          setState(() {
            widget.objective.userRating = rating;
          });
        })),
        SizedBox(height: smallDivider),
        Row(children: [
          Padding(
              child: Text(
                  widget.objective.userRating == null || widget.objective.userRating == 0.0
                      ? 'Nu ai evaluat inca obiectivul.'
                      : 'Ai acordat ' + widget.objective.userRating.toString() + (widget.objective.userRating == 1 ? ' stea' : ' stele') + ' acestui obiectiv!',
                  style: Theme.of(context).textTheme.subtitle1),
              padding: EdgeInsets.symmetric(horizontal: 16.0))
        ]),
        SizedBox(height: bigDivider),
      ]);
    }

    return ColorfulSafeArea(
      overflowRules: OverflowRules.all(true),
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                          child: ClipRRect(
                        child: Hero(
                            child: Container(
                              height: height * 0.75,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(0.0), bottomRight: Radius.circular(0.0)),
                                  image: new DecorationImage(
                                    image: Image.asset('assets/images/bisericalemn_000.jpg').image,
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.025), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))]),
                              width: width,
                            ),
                            tag: 'objective-hero' + widget.objective.name),
                      )),
                      Hero(
                          child: Container(
                            height: height * 0.75,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                color: Colors.white,
                                gradient: LinearGradient(begin: FractionalOffset.topCenter, end: FractionalOffset.bottomCenter, colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.black.withOpacity(0.5),
                                ], stops: [
                                  0.5,
                                  0.75
                                ]),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.025), spreadRadius: 2, blurRadius: 6, offset: Offset(0, 0))]),
                            width: width,
                          ),
                          tag: 'obj-layer' + widget.objective.name),
                      Positioned(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0))),
                        ),
                        height: 12,
                        width: width,
                        bottom: -6,
                      ),
                      Positioned(
                          top: 84,
                          left: 20,
                          child: InkWell(
                              child: Container(
                                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.45)),
                                width: 48,
                                height: 48,
                                child: Icon(Icons.arrow_back, color: Colors.white),
                              ),
                              onTap: () => Navigator.of(context).pop(widget.objective.rating))),
                      Positioned(
                          top: 84,
                          right: 20,
                          child: InkWell(
                              child: Container(
                                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.45)),
                                width: 48,
                                height: 48,
                                child: Icon(Icons.share, color: Colors.white),
                              ),
                              onTap: () => Navigator.of(context).pop(widget.objective.rating))),
                      Positioned(
                          top: 84,
                          right: 80,
                          child: FutureBuilder<bool>(
                              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                  widget.objective.is_bookmarked = snapshot.data;
                                  return InkWell(
                                      child: Container(
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.45)),
                                        width: 48,
                                        height: 48,
                                        child: Icon(widget.objective.is_bookmarked ? Icons.bookmark : Icons.bookmark_add_outlined, color: Colors.white),
                                      ),
                                      onTap: () async {
                                        try {
                                          var db = await DatabaseService().database;

                                          if (widget.objective.is_bookmarked) {
                                            await db.delete('objectivebookmark',
                                                where: 'user_id = ? and objective_id = ?', whereArgs: [user.id, widget.objective.id]);
                                          } else {
                                            await db.insert('objectivebookmark', {'user_id': user.id, 'objective_id': widget.objective.id},
                                                conflictAlgorithm: ConflictAlgorithm.replace);
                                          }

                                          Provider.of<MainBloc>(context, listen: false).objectiveEventSync.add(Constants.HomeRefreshBookmarks);
                                          widget.objective.is_bookmarked = !widget.objective.is_bookmarked;
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              duration: const Duration(milliseconds: 800),
                                              backgroundColor: widget.objective.is_bookmarked ? Theme.of(context).primaryColor : Theme.of(context).errorColor,
                                              content: widget.objective.is_bookmarked ? Text('Obiectivul a fost salvat.') : Text('Obiectivul a fost sters.')));
                                          setState(() {});
                                        } on Exception {}
                                      });
                                } else
                                  return CircularProgressIndicator();
                              },
                              future: _getObjectiveData(user.id, widget.objective.id))),
                      Positioned(
                          child: Container(
                            width: width,
                            height: 96,
                            child: Column(children: [
                              Spacer(flex: 1),
                              Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.cottage, color: Colors.white),
                                    ],
                                  ),
                                  flex: 6),
                              Expanded(
                                  child: Row(
                                    children: [
                                      Text(widget.objective.name,
                                          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, fontFamily: 'Nunito', color: Colors.white)),
                                    ],
                                  ),
                                  flex: 8),
                              if (!NavigatorHelper().isGuestUser(context))
                                Expanded(
                                    child: Row(
                                      children: [
                                        CardBuilder.buildStars(context, widget.objective.rating, true),
                                        SizedBox(width: 5),
                                        Text(widget.objective.rating.toStringAsFixed(1) + ' (' + widget.objective.ratingCount.toString() + ')',
                                            style: TextStyle(fontSize: 12.0, color: Colors.white))
                                      ],
                                    ),
                                    flex: 4),
                            ]),
                          ),
                          bottom: 32,
                          left: 20),
                    ],
                  ),
                  height: height * 0.75,
                  width: 999,
                ),
                Padding(
                    child: Column(
                      children: [
                        Row(children: [
                          Text(
                            "Descriere",
                            style: Theme.of(context).textTheme.headline2,
                            textAlign: TextAlign.start,
                          )
                        ]),
                        SizedBox(height: smallDivider),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                                text: widget.objective.description,
                                style: Theme.of(context).textTheme.subtitle2),
                            maxLines: 15,
                            textAlign: TextAlign.start,
                          ),
                        ),
                        SizedBox(height: bigDivider),
                        Row(children: [
                          Text(
                            "Trasee catre obiectiv",
                            style: Theme.of(context).textTheme.headline2,
                            textAlign: TextAlign.start,
                          )
                        ]),
                        SizedBox(height: smallDivider),
                        FutureBuilder<List<BikeRoute>>(
                          builder: (BuildContext context, AsyncSnapshot<List<BikeRoute>> snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              return Container(
                                child: RouteCarousel(
                                  context: context,
                                  routes: snapshot.data,
                                  width: width * 0.4,
                                ),
                                height: height * 0.35,
                                width: 999,
                              );
                            } else
                              return Container(
                                child: RouteCarousel(
                                  context: context,
                                  routes: snapshot.data,
                                  width: width * 0.44,
                                  isShimer: true,
                                ),
                                height: height * 0.35,
                                width: 999,
                              );
                          },
                          future: _getRoutes(),
                        ),
                        SizedBox(height: bigDivider),
                        if (!NavigatorHelper().isGuestUser(context)) _buildEvaluateSection(),
                        Row(children: [
                          Text(
                            "Contact",
                            style: Theme.of(context).textTheme.headline2,
                            textAlign: TextAlign.start,
                          )
                        ]),
                        SizedBox(height: bigDivider),
                        Row(
                          children: [
                            SizedBox(width: 16),
                            GradientIcon(Icons.phone, 36),
                            SizedBox(width: 20),
                            Text(
                              "+(40) 75 111 2233",
                              style: TextStyle(fontSize: 18.0, color: Theme.of(context).primaryColorDark),
                              textAlign: TextAlign.start,
                            )
                          ],
                        ),
                        SizedBox(height: smallDivider * 1.5),
                        Row(
                          children: [
                            SizedBox(width: 16),
                            GradientIcon(Icons.facebook, 36),
                            SizedBox(width: 20),
                            Text(
                              "Biserica de pe deal",
                              style: TextStyle(fontSize: 18.0, color: Theme.of(context).primaryColorDark),
                              textAlign: TextAlign.start,
                            )
                          ],
                        ),
                        SizedBox(height: smallDivider * 1.5),
                        Row(
                          children: [
                            SizedBox(width: 16),
                            GradientIcon(Icons.mail, 36),
                            SizedBox(width: 20),
                            Text(
                              "bisericadeal@gmail.com",
                              style: TextStyle(fontSize: 18.0, color: Theme.of(context).primaryColorDark),
                              textAlign: TextAlign.start,
                            )
                          ],
                        ),
                        SizedBox(
                          height: bigDivider,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0)),
              ],
            ),

            /*SliverList(
                    delegate: SliverChildListDelegate([

                    ]),
                  )*/
          )),
    );
  }
}
