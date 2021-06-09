import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';

class POIScreen extends StatelessWidget {
  static const route = 'poi';
  const POIScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
        overflowRules: OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [Image.asset('assets/images/bisericalemn_000.jpg', fit: BoxFit.cover)],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscinLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duig elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam duiLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper massa risus, in pretium felis finibus vel. Donec aliquam dui')
                ]),
              ),
            ],
          ),
        ));
  }
}
