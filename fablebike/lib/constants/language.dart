import 'package:flutter/material.dart';

class LanguageManager {
  String language = 'RO';

  String get appHome => language == 'RO' ? 'Acasa' : 'Home';
  String get appSignUp => language == 'RO' ? 'Creeaza cont' : 'Create account';
  String get appExplore => language == 'RO' ? 'Exploreaza' : 'Explore';
  String get appRoutes => language == 'RO' ? 'Rute' : 'Routes';
  String get appSettings => language == 'RO' ? 'Contul meu' : 'My account';

  String get homeDistance => language == 'RO' ? 'Distanta parcursa' : 'Distance travelled';
  String get homeRoutes => language == 'RO' ? 'Rute finalizate' : 'Routes finished';
  String get homeObjectives => language == 'RO' ? 'Obiective vizitate' : 'Objectives visited';
  String get homeBookmarks => language == 'RO' ? 'Obiective marcate' : 'Bookmarks';
  String get homeNearbyObjectives => language == 'RO' ? 'Obiective aflate in apropiere' : 'Nearby objectives';
  String get homeSeeAllObjectives => language == 'RO' ? 'Vezi toate obiectivele pe harta' : 'See all objective on map';
  String get homeSeeAllSavedObjectives => language == 'RO' ? 'Vezi toate obiectivele salvate' : 'See all bookmarks';

  String get routeDistance => language == 'RO' ? 'Distanta' : 'Distance';
  String get routeAvailable => language == 'RO' ? 'Lista rutelor disponibile' : 'All routes';
  String get routeObjectives => language == 'RO' ? 'Obiective pe aceasta ruta' : 'Objectives on the route';
  String get routeEvaluate => language == 'RO' ? 'Evalueaza ruta' : 'Evaluate this route';
  String get routeAbout => language == 'RO' ? 'Despre Ruta' : 'About route';
  String get routeSeeAllComments => language == 'RO' ? 'Vezi toate comentariile' : 'See all comments';

  String get settingPhoto => language == 'RO' ? 'Schimba fotografia de profil' : 'Change profile picture';
  String get settingGDPR => language == 'RO' ? 'Citeste clauze GDPR' : 'Read GDPR clauses';
  String get settingDataUsageNormal => language == 'RO' ? 'Consum de date normal' : 'Normal data usage';
  String get settingDataUsageLow => language == 'RO' ? 'Consum de date redus' : 'Low data usage';
  String get settingCache => language == 'RO' ? 'Goleste datele de cache' : 'Empty cache';
  String get settingLanguage => language == 'RO' ? 'Schimba limba' : 'Change language';
  String get settingPresentation => language == 'RO' ? 'Prezentare aplicatie' : 'Presentation';
  String get settingLogout => language == 'RO' ? 'Logout' : 'Logout';
  String get settingAccount => language == 'RO' ? 'Cont' : 'Account';
  String get settingPreferences => language == 'RO' ? 'Preferinte' : 'Preferences';

  String get routeObjectiveTab => language == 'RO' ? 'Obiective' : 'Objectives';
  String get routeElevationTab => language == 'RO' ? 'Elevatie' : 'Elevation';
  String get routeObjectiveOn => language == 'RO' ? 'Obiectivele de pe aceasta ruta' : 'Objectives on the route';
  String get routeElevation => language == 'RO' ? 'Graficul de elevatia al rutei' : 'Elevation graph';
  String get routeInformation => language == 'RO' ? 'Informatii despre ruta' : 'Route information';
  String get routeRating => language == 'RO' ? 'Evalueaza ruta' : 'Evaluate route';

  String get searchObjective => language == 'RO' ? 'Cauta obiectiv...' : 'Search objective...';

  String get login => language == 'RO' ? 'Logare' : 'Login';
  String get email => language == 'RO' ? 'Introdu e-mail' : 'Email';
  String get password => language == 'RO' ? 'Parola' : 'Password';
  String get loginWith => language == 'RO' ? 'Sau logheaza-te cu' : 'Or login with';
  String get noAccount => language == 'RO' ? 'Nu am cont.' : "I don't have an account.";
  String get createOne => language == 'RO' ? ' Creeaza unul!' : ' Create one!';
  String get pickImage => language == 'RO' ? 'Adauga fotografie!' : 'Pick Image!';
  String get name => language == 'RO' ? 'Introdu nume' : 'Name';
  String get createAccount => language == 'RO' ? 'Creeaza cont' : 'Create account';
  String get details => language == 'RO' ? 'Vezi detalii' : 'Details';
  String get routes => language == 'RO' ? 'Rute' : 'Routes';
  String get objective => language == 'RO' ? 'Obiective' : 'Objectives';
  String get search => language == 'RO' ? 'Cauta' : 'Search';
  String get info => language == 'RO' ? 'Informatii' : 'Informations';
  String get distance => language == 'RO' ? 'Distanta' : 'Distance';
  String get duration => language == 'RO' ? 'Durata' : 'Duration';
  String get difficulty => language == 'RO' ? 'Dificultate' : 'Difficulty';

  String get back => language == 'RO' ? 'Inapoi' : 'Back';
  String get description => language == 'RO' ? 'Descriere' : 'Description';
}
