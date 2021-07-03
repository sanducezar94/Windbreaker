import 'dart:ui';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ObjectiveScreen extends StatefulWidget {
  static const route = 'objective';
  final String fromRoute;

  final Objective objective;
  ObjectiveScreen({Key key, @required this.objective, this.fromRoute}) : super(key: key);

  @override
  _ObjectiveScreenState createState() => _ObjectiveScreenState();
}

class _ObjectiveScreenState extends State<ObjectiveScreen> {
  bool is_bookmarked = false;
  Future<bool> _getObjectiveData(int userId, int objectiveId) async {
    var db = await DatabaseService().database;

    var rows = await db.query('objectivebookmark', where: 'user_id = ? and objective_id = ?', whereArgs: [userId, objectiveId]);
    this.is_bookmarked = rows.length > 0;
    return rows.length > 0;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;
    var user = Provider.of<AuthenticatedUser>(context);

    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Expanded(
                      flex: 7,
                      child: Text(
                        "Inapoi",
                        style: Theme.of(context).textTheme.headline3,
                      )),
                  Expanded(
                      child: InkWell(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [Icon(Icons.bookmark_add_outlined, color: Colors.black)]),
                        onTap: () async {},
                      ),
                      flex: 1),
                ],
              ),
              iconTheme: IconThemeData(color: Colors.black),
              shadowColor: Colors.white54,
              backgroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Container(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Column(
                        children: [
                          RichText(
                            maxLines: 3,
                            text: TextSpan(text: "Statuia ecvestră a lui Ștefan cel Mare de la Podul Înalt", style: Theme.of(context).textTheme.headline6),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Container(
                        child: ClipRRect(
                          child: ImageSlideshow(
                            width: double.infinity,
                            height: 200,
                            indicatorColor: Theme.of(context).primaryColor,
                            indicatorBackgroundColor: Colors.white,
                            initialPage: 0,
                            children: [
                              Image.asset('assets/images/podu_001.jpg', fit: BoxFit.cover),
                              Image.asset('assets/images/podu_002.jpg', fit: BoxFit.cover),
                            ],
                            onPageChanged: (value) {
                              print('Page changed: $value');
                            },
                            autoPlayInterval: 3000,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        height: height * 0.275,
                        width: width,
                      ),
                      SizedBox(height: 15),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.0),
                        child: Row(children: [
                          Text(
                            'Descriere',
                            style: TextStyle(fontSize: 18.0, color: Color.fromRGBO(37, 14, 19, 1).withOpacity(0.87), fontWeight: FontWeight.bold),
                            textAlign: TextAlign.start,
                          )
                        ]),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              maxLines: 15,
                              text: TextSpan(
                                  text:
                                      " Lupta de la Vaslui – ,,Podu’ Înalt La 10 ianurie 1475 s-a desfăşurat celebra bătălie de la Vaslui, mai cunoscută ca fiind de la Podu’ Înalt, moldovenilor lui Ştefan cel Mare alăturându-se secui, maghiari şi polonezi, reuşind o mare victorie împotriva trupelor otomane conduse de Soliman Paşa. Lupta a avut loc într-un loc ales de Ştefan, o zonă îngustă, mlăştinoasă, în care numărul mare de turci nu se putea desfăşura. Atacaţi din mai multe părţi, otomanii au sfârşit prin a intra în panică şi au ales să fugă, lăsând în urmă mii de morţi şi aproximativ 100 de steaguri.\n\n Victoria obţinută de domnitorul Moldovei a fost elogiată de cronicarii vremii şi recunoscută de marile curţi ale Europei, papa de la Roma numindu-l pe Ştefan cel Mare „Atlet al credinţei creştine”.",
                                  style: Theme.of(context).textTheme.bodyText2),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 5),
                      ),
                      SizedBox(height: 15),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.0),
                        child: Row(children: [
                          Text(
                            'Contact',
                            style: TextStyle(fontSize: 18.0, color: Color.fromRGBO(37, 14, 19, 1).withOpacity(0.87), fontWeight: FontWeight.bold),
                            textAlign: TextAlign.start,
                          )
                        ]),
                      ),
                      SizedBox(height: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Image.asset('assets/icons/fb.png'),
                                  ),
                                  flex: 1),
                              Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Image.asset('assets/icons/web_h.png'),
                                  ),
                                  flex: 1),
                              Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Image.asset('assets/icons/phone.png'),
                                  ),
                                  flex: 1),
                              Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Image.asset('assets/icons/mail.png'),
                                  ),
                                  flex: 1),
                              Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Image.asset('assets/icons/insta.png'),
                                  ),
                                  flex: 1),
                              Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Image.asset('assets/icons/yt.png'),
                                  ),
                                  flex: 1),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )));
  }
}
