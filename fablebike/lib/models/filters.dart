import 'package:flutter/material.dart';

class SearchFilter {}

class RouteFilter extends SearchFilter {
  RangeValues distance;
  RangeValues rating;
  RangeValues difficulty;
  RangeValues poiCount;

  RouteFilter() {
    distance = RangeValues(0.0, 500.0);
    rating = RangeValues(0.0, 5.0);
    difficulty = RangeValues(0.0, 5.0);
    poiCount = RangeValues(0.0, 30.0);
  }
}

class BookmarkFilter extends SearchFilter {
  RangeValues distance;
  RangeValues rating;
  RangeValues difficulty;
  RangeValues poiCount;

  BookmarkFilter() {
    distance = RangeValues(0.0, 500.0);
    rating = RangeValues(0.0, 5.0);
    difficulty = RangeValues(0.0, 5.0);
    poiCount = RangeValues(0.0, 30.0);
  }
}
