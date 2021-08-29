import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:fablebike/constants/language.dart';
import 'package:fablebike/models/comments.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/services/route_service.dart';
import 'package:fablebike/widgets/card_builder.dart';
import 'package:fablebike/widgets/carousel.dart';
import 'package:flutter/material.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:fablebike/pages/sections/comments_section.dart';

class RouteMapScreen extends StatefulWidget {
  static const route = '/map';
  final BikeRoute bikeRoute;
  RouteMapScreen({Key key, @required this.bikeRoute}) : super(key: key);

  @override
  _RouteMapScreenState createState() => _RouteMapScreenState();
}

LatLng myLocation = LatLng(46.45447, 27.72501);

class _RouteMapScreenState extends State<RouteMapScreen> {
  final ScrollController listViewController = ScrollController();
  bool isLoading = false;
  String currentRoute = "poi";
  double rotation = 0;
  double size = 12.0;
  bool init = false;
  int currentPoint = 0;
  MapController mapController = MapController();
  double kmTraveled = 0;
  var hoverPoint = LatLng(0, 0);
  var currentTab = 'poi';
  LatLng center = LatLng(0, 0);
  List<Objective> objectives = [];

  Future<List<Objective>> _getObjectives() async {
    var database = await DatabaseService().database;
    var objectiveRows = await database.query('objective');

    List<Objective> objectives = List.generate(objectiveRows.length, (i) {
      return Objective.fromJson(objectiveRows[i]);
    });
    List<Objective> returnList = [];
    for (var i = 0; i < objectives.length; i++) {
      var objToRoutesRow =
          await database.query('objectivetoroute', where: 'objective_id = ? and route_id = ?', whereArgs: [objectives[i].id, widget.bikeRoute.id]);

      if (objToRoutesRow.length > 0) {
        returnList.add(objectives[i]);
      }
    }
    return returnList;
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 3000);

  @override
  Widget build(BuildContext context) {
    objectives.add(new Objective(id: 1, name: 'Test', description: 'Test'));
    double width = MediaQuery.of(context).size.width;
    double height = max(656, MediaQuery.of(context).size.height - 80);
    var user = Provider.of<AuthenticatedUser>(context);
    double smallDivider = 10.0;
    double bigDivider = 20.0;

    var markers = <Marker>[];
    markers.add(Marker(
        width: 64,
        height: 64,
        builder: (ctx) =>
            Transform.rotate(angle: -this.rotation * 3.14159 / 180, child: Container(child: Image(image: AssetImage('assets/icons/ruin_ppin.png')))),
        point: hoverPoint));
    for (var i = 0; i < widget.bikeRoute.objectives.length; i++) {
      markers.add(Marker(
          width: i == currentPoint ? 40 : 32,
          height: i == currentPoint ? 40 : 32,
          builder: (ctx) => Transform.rotate(
              angle: -this.rotation * 3.14159 / 180,
              child: Container(child: Image(image: AssetImage('assets/icons/' + widget.bikeRoute.objectives[i].icon + '_pin.png')))),
          point: widget.bikeRoute.objectives[i].coords));
    }

    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: SingleChildScrollView(
                child: Column(children: [
              Container(
                height: height * 0.65,
                width: 999,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                        child: ClipRRect(
                      child: Hero(
                          child: Container(
                            height: height * 0.6,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(0.0), bottomRight: Radius.circular(0.0)),
                                image: new DecorationImage(
                                  image: Image.asset('assets/icons/route.png').image,
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.025), spreadRadius: 3, blurRadius: 4, offset: Offset(0, 3))
                                ]),
                            width: width,
                          ),
                          tag: 'route-hero' + widget.bikeRoute.name),
                    )),
                    Container(
                      height: height * 0.6,
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
                          boxShadow: [
                            BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.025), spreadRadius: 2, blurRadius: 6, offset: Offset(0, 0))
                          ]),
                      width: width,
                    ),
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
                          onTap: () => Navigator.pop(context),
                        )),
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
                          onTap: () => Navigator.pop(context),
                        )),
                    Positioned(
                        child: Hero(
                            child: Container(
                              width: width,
                              height: 96,
                              child: Column(children: [
                                Spacer(flex: 1),
                                Expanded(
                                    child: Row(
                                      children: [
                                        Text(widget.bikeRoute.name,
                                            style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, fontFamily: 'Nunito', color: Colors.white)),
                                      ],
                                    ),
                                    flex: 8),
                                Expanded(
                                    child: Row(
                                      children: [
                                        CardBuilder.buildStars(context, widget.bikeRoute.rating, true, opacity: 1, size: 24),
                                        SizedBox(width: 5),
                                        Align(
                                          child: Text(widget.bikeRoute.rating.toStringAsFixed(1) + ' (' + widget.bikeRoute.ratingCount.toString() + ')',
                                              style: TextStyle(fontSize: 12.0, color: Colors.white)),
                                          alignment: Alignment.center,
                                        )
                                      ],
                                    ),
                                    flex: 4),
                              ]),
                            ),
                            tag: 'route-desc' + widget.bikeRoute.name),
                        bottom: 32,
                        left: 20),
                  ],
                ),
              ),
              Stack(
                children: [
                  /* Positioned(
                      child: Opacity(
                        child: Container(
                          width: width * 1.2,
                          height: height * 0.15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(0.0), bottomRight: Radius.circular(0.0)),
                            image: new DecorationImage(
                              image: Image.asset('assets/icons/bg_finish.png').image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        opacity: 0.2,
                      ),
                      bottom: 0,
                      left: -40),*/
                  Padding(
                      child: Column(
                        children: [
                          SizedBox(
                            height: smallDivider,
                          ),
                          Row(children: [
                            Text(
                              "Descriere",
                              style: Theme.of(context).textTheme.headline2,
                              textAlign: TextAlign.start,
                            )
                          ]),
                          SizedBox(
                            height: smallDivider,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: TextSpan(
                                  text:
                                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequa',
                                  style: Theme.of(context).textTheme.subtitle2),
                              maxLines: 15,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          SizedBox(height: bigDivider),
                          Row(children: [
                            Text(
                              "Harta",
                              style: Theme.of(context).textTheme.headline2,
                              textAlign: TextAlign.start,
                            )
                          ]),
                          SizedBox(height: smallDivider),
                          ClipRRect(
                              child: Container(
                                width: width,
                                height: height * 0.25,
                                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                                  BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.05), spreadRadius: 12, blurRadius: 16, offset: Offset(0, 3))
                                ]),
                                child: Stack(
                                  children: [
                                    FlutterMap(
                                      mapController: this.mapController,
                                      options: MapOptions(
                                          center: widget.bikeRoute.center,
                                          minZoom: 10.0,
                                          maxZoom: 10.0,
                                          zoom: 10.0,
                                          swPanBoundary: LatLng(46.2318, 27.3077),
                                          nePanBoundary: LatLng(46.9708, 28.1942),
                                          plugins: []),
                                      layers: [
                                        TileLayerOptions(
                                          tileProvider: AssetTileProvider(),
                                          maxZoom: 10.0,
                                          urlTemplate: 'assets/map/{z}/{x}/{y}.png',
                                        ),
                                        /* PolylineLayerOptions(
                                                  polylines: [
                                                    Polyline(points: widget.bikeRoute.rtsCoordinates, strokeWidth: 8, color: Colors.blue),
                                                  ],
                                                ),*/
                                        //LocationMarkerLayerOptions(),
                                        // MarkerLayerOptions(markers: markers),
                                      ],
                                    ),
                                    Positioned(
                                        bottom: 16,
                                        right: 16,
                                        child: InkWell(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(128.0)),
                                                color: Theme.of(context).primaryColor,
                                                border: Border.all(color: Colors.white, width: 1),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Theme.of(context).shadowColor.withOpacity(0.15),
                                                      spreadRadius: 3,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 3))
                                                ]),
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: Icon(Icons.fullscreen, color: Colors.white),
                                                )
                                              ],
                                            ),
                                            width: 32,
                                            height: 32,
                                          ),
                                          onTap: () {
                                            // Navigator.of(context).pushNamed(FullScreenMap.route, arguments: widget.bikeRoute);
                                          },
                                        ))
                                  ],
                                ),
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(16.0),
                              )),
                          SizedBox(height: bigDivider),
                          Row(children: [
                            Text(
                              "Obiective de pe traseu",
                              style: Theme.of(context).textTheme.headline2,
                              textAlign: TextAlign.start,
                            )
                          ]),
                          SizedBox(height: smallDivider),
                          FutureBuilder<List<Objective>>(
                            builder: (BuildContext context, AsyncSnapshot<List<Objective>> snapshot) {
                              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                return Container(
                                  child: Carousel(
                                    context: context,
                                    objectives: snapshot.data,
                                    width: width * 0.75,
                                  ),
                                  height: height * 0.25,
                                  width: 999,
                                );
                              } else {
                                return Container(
                                  child: Carousel(
                                    context: context,
                                    objectives: snapshot.data,
                                    width: width * 0.75,
                                    isShimmer: true,
                                  ),
                                  height: height * 0.25,
                                  width: 999,
                                );
                              }
                            },
                            future: _getObjectives(),
                          ),
                          SizedBox(
                            height: bigDivider,
                          ),
                          Row(children: [
                            Text(
                              "Poze",
                              style: Theme.of(context).textTheme.headline2,
                              textAlign: TextAlign.start,
                            )
                          ]),
                          SizedBox(height: bigDivider),
                          Container(
                            child: Row(
                              children: [
                                Expanded(
                                    child: Padding(
                                        child: Column(
                                          children: [
                                            Container(
                                              child: ClipRRect(
                                                  child: Image.asset('assets/icons/route.png', width: width * 0.5, height: height * 0.175, fit: BoxFit.cover),
                                                  borderRadius: BorderRadius.circular(12.0)),
                                              decoration: BoxDecoration(boxShadow: [
                                                BoxShadow(
                                                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                                                    spreadRadius: 6,
                                                    blurRadius: 12,
                                                    offset: Offset(0, 0))
                                              ]),
                                            ),
                                            SizedBox(height: bigDivider),
                                            Container(
                                              child: ClipRRect(
                                                  child: Image.asset('assets/icons/route.png', width: width * 0.5, height: height * 0.35, fit: BoxFit.cover),
                                                  borderRadius: BorderRadius.circular(12.0)),
                                              decoration: BoxDecoration(boxShadow: [
                                                BoxShadow(
                                                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                                                    spreadRadius: 6,
                                                    blurRadius: 12,
                                                    offset: Offset(0, 0))
                                              ]),
                                            ),
                                          ],
                                        ),
                                        padding: EdgeInsets.fromLTRB(0, 4, 16, 0))),
                                Expanded(
                                    child: Padding(
                                        child: Column(
                                          children: [
                                            SizedBox(height: bigDivider * 2),
                                            Container(
                                              child: ClipRRect(
                                                  child: Image.asset('assets/icons/route.png', width: width * 0.5, height: height * 0.35, fit: BoxFit.cover),
                                                  borderRadius: BorderRadius.circular(12.0)),
                                              decoration: BoxDecoration(boxShadow: [
                                                BoxShadow(
                                                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                                                    spreadRadius: 6,
                                                    blurRadius: 12,
                                                    offset: Offset(0, 0))
                                              ]),
                                            ),
                                            SizedBox(height: bigDivider),
                                            Container(
                                              child: ClipRRect(
                                                  child: Stack(
                                                    children: [
                                                      Image.asset('assets/icons/route.png', width: width * 0.5, height: height * 0.175, fit: BoxFit.cover),
                                                      Container(
                                                        height: height * 0.175,
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.all(Radius.circular(12)),
                                                            color: Colors.white,
                                                            gradient:
                                                                LinearGradient(begin: FractionalOffset.topCenter, end: FractionalOffset.bottomCenter, colors: [
                                                              Colors.black.withOpacity(0.25),
                                                              Colors.black.withOpacity(0.75),
                                                            ], stops: [
                                                              0,
                                                              1
                                                            ]),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                  color: Theme.of(context).shadowColor.withOpacity(0.025),
                                                                  spreadRadius: 2,
                                                                  blurRadius: 6,
                                                                  offset: Offset(0, 0))
                                                            ]),
                                                        width: width,
                                                      ),
                                                      Container(
                                                        height: height * 0.175,
                                                        width: width * 0.5,
                                                        child: Align(
                                                          alignment: Alignment.center,
                                                          child: Text(
                                                            '+6 Poze',
                                                            style: Theme.of(context).textTheme.headline3,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  borderRadius: BorderRadius.circular(12.0)),
                                              decoration: BoxDecoration(boxShadow: [
                                                BoxShadow(
                                                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                                                    spreadRadius: 6,
                                                    blurRadius: 12,
                                                    offset: Offset(0, 0))
                                              ]),
                                            ),
                                          ],
                                        ),
                                        padding: EdgeInsets.fromLTRB(16, 4, 0, 0)))
                              ],
                            ),
                            width: 999,
                            height: bigDivider * 1 + height * 0.65,
                          ),
                          Row(children: [
                            Text(
                              context.read<LanguageManager>().routeEvaluate,
                              style: Theme.of(context).textTheme.headline2,
                              textAlign: TextAlign.start,
                            )
                          ]),
                          SizedBox(height: smallDivider),
                          Container(
                              child: CardBuilder.buildInteractiveStars(context, widget.bikeRoute.rating, 48.0, callBack: (int rating) async {
                            Loader.show(context, progressIndicator: CircularProgressIndicator(color: Theme.of(context).primaryColor));
                            var newRating = await RouteService().rateRoute(rating: rating, route_id: widget.bikeRoute.id);

                            if (newRating == null || newRating == 0.0) {
                              Loader.hide();
                              return;
                            }
                            widget.bikeRoute.rating = newRating;
                            if (widget.bikeRoute.userRating == 0) widget.bikeRoute.ratingCount += 1;

                            var db = await DatabaseService().database;
                            await db.update('route', {'rating': newRating, 'rating_count': widget.bikeRoute.ratingCount},
                                where: 'id = ?', whereArgs: [widget.bikeRoute.id]);
                            Loader.hide();
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                duration: const Duration(milliseconds: 800),
                                backgroundColor: Theme.of(context).primaryColor,
                                content: Text('Votul a fost inregistrat cu succes!')));
                            setState(() {});
                          })),
                          SizedBox(height: bigDivider),
                          Row(children: [
                            Text(
                              "Despre ruta",
                              style: Theme.of(context).textTheme.headline2,
                              textAlign: TextAlign.start,
                            )
                          ]),
                          SizedBox(height: bigDivider),
                          //if (widget.bikeRoute.pinnedComment != null)
                          Container(
                            height: 80,
                            width: 999,
                            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16.0)), color: Colors.white, boxShadow: [
                              BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.1), spreadRadius: 4, blurRadius: 12, offset: Offset(0, 3))
                            ]),
                            child: Column(
                              children: [
                                Expanded(
                                  child: _buildComment(
                                      context,
                                      Comment(
                                          userId: 0,
                                          id: 0,
                                          text:
                                              'Scris scris scris scris scris scris scris scris scris scris scris scris scris scris scris scris', // widget.bikeRoute.pinnedComment.comment,
                                          user: 'User', //widget.bikeRoute.pinnedComment.username,
                                          icon: ''),
                                      false,
                                      null),
                                  flex: 1,
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: bigDivider),
                          //if (widget.bikeRoute.pinnedComment != null)
                          Row(children: [
                            Expanded(
                              flex: 1,
                              child: Align(
                                  alignment: Alignment.center,
                                  child: InkWell(
                                    child: Text(
                                      'Vezi toate comentariile (' +
                                          (widget.bikeRoute.commentCount != null ? widget.bikeRoute.commentCount : 0).toString() +
                                          ')',
                                      style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColorDark),
                                      textAlign: TextAlign.start,
                                    ),
                                    onTap: () {
                                      showModalBottomSheet(
                                          isScrollControlled: true,
                                          context: context,
                                          isDismissible: true,
                                          backgroundColor: Colors.white.withOpacity(0),
                                          builder: (context) {
                                            return CommentSection(bikeRoute: widget.bikeRoute);
                                          }).then((value) => () {
                                            setState(() {});
                                          });
                                    },
                                  )),
                            ),
                          ]),
                          /* SizedBox(height: height * 0.15),*/
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0))
                ],
              )
            ]))));
  }
}

Widget _buildComment(BuildContext context, Comment comment, bool moreButton, VoidCallback onTap) {
  var user = context.read<AuthenticatedUser>();
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    child: ListTile(
      minVerticalPadding: 10,
      horizontalTitleGap: 15,
      leading: !user.lowDataUsage
          ? FutureBuilder<Uint8List>(
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: snapshot.data == null
                        ? Image.asset('assets/icons/user.png', width: 80, height: 80)
                        : Image.memory(snapshot.data, width: 80, height: 80),
                  );
                } else {
                  return Image.asset('assets/icons/user.png', width: 80, height: 80);
                }
              },
              future: getIcon(imageName: comment.icon, username: comment.user, userId: comment.userId))
          : Image(image: AssetImage('assets/icons/user.png')),
      title: Text(
        comment.user,
        style: Theme.of(context).textTheme.bodyText1,
      ),
      subtitle: Text(
        comment.text,
        style: Theme.of(context).textTheme.bodyText2,
      ),
    ),
  );
}
