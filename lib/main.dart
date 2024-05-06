import 'package:club_me/club_coupons/club_coupons_view.dart';
import 'package:club_me/club_events/club_events_view.dart';
import 'package:club_me/club_frontpage/club_front_page_view.dart';
import 'package:club_me/club_statistics/club_statistics_view.dart';
import 'package:club_me/provider/state_provider.dart';
import 'package:club_me/shared/club_detail_view.dart';
import 'package:club_me/shared/coupon_detail_view.dart';
import 'package:club_me/shared/event_detail_view.dart';
import 'package:club_me/user_clubs/user_clubs_view.dart';
import 'package:club_me/user_coupons/user_coupons_view.dart';
import 'package:club_me/user_events/user_events_view.dart';
import 'package:club_me/user_map/user_map_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'tabs_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Analytics Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: <NavigatorObserver>[observer],
      home: MyHomePage(
        title: 'Firebase Analytics Demo',
        analytics: analytics,
        observer: observer,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
    required this.title,
    required this.analytics,
    required this.observer,
  }) : super(key: key);

  final String title;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _message = '';

  void setMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  Future<void> _setDefaultEventParameters() async {
    if (kIsWeb) {
      setMessage(
        '"setDefaultEventParameters()" is not supported on web platform',
      );
    } else {
      // Only strings, numbers & null (longs & doubles for android, ints and doubles for iOS) are supported for default event parameters:
      await widget.analytics.setDefaultEventParameters(<String, dynamic>{
        'string': 'string',
        'int': 42,
        'long': 12345678910,
        'double': 42.0,
        'bool': true.toString(),
      });
      setMessage('setDefaultEventParameters succeeded');
    }
  }

  Future<void> _sendAnalyticsEvent() async {
    // Only strings and numbers (longs & doubles for android, ints and doubles for iOS) are supported for GA custom event parameters:
    // https://firebase.google.com/docs/reference/ios/firebaseanalytics/api/reference/Classes/FIRAnalytics#+logeventwithname:parameters:
    // https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics#public-void-logevent-string-name,-bundle-params
    await widget.analytics.logEvent(
      name: 'test_event',
      parameters: <String, dynamic>{
        'string': 'string',
        'int': 42,
        'long': 12345678910,
        'double': 42.0,
        // Only strings and numbers (ints & doubles) are supported for GA custom event parameters:
        // https://developers.google.com/analytics/devguides/collection/analyticsjs/custom-dims-mets#overview
        'bool': true.toString(),
      },
    );

    setMessage('logEvent succeeded');
  }

  Future<void> _testSetUserId() async {
    await widget.analytics.setUserId(id: 'some-user');
    setMessage('setUserId succeeded');
  }

  Future<void> _testSetAnalyticsCollectionEnabled() async {
    await widget.analytics.setAnalyticsCollectionEnabled(false);
    await widget.analytics.setAnalyticsCollectionEnabled(true);
    setMessage('setAnalyticsCollectionEnabled succeeded');
  }

  Future<void> _testSetSessionTimeoutDuration() async {
    await widget.analytics
        .setSessionTimeoutDuration(const Duration(milliseconds: 20000));
    setMessage('setSessionTimeoutDuration succeeded');
  }

  Future<void> _testSetUserProperty() async {
    await widget.analytics.setUserProperty(name: 'regular', value: 'indeed');
    setMessage('setUserProperty succeeded');
  }

  Future<void> _testSetConsent() async {
    await widget.analytics.setConsent(
      adStorageConsentGranted: true,
      adUserDataConsentGranted: true,
      adPersonalizationSignalsConsentGranted: true,
    );
    setMessage('setConsent succeeded');
  }

  Future<void> _testAppInstanceId() async {
    String? id = await widget.analytics.appInstanceId;
    if (id != null) {
      setMessage('appInstanceId succeeded: $id');
    } else {
      setMessage('appInstanceId failed, consent declined');
    }
  }

  Future<void> _testResetAnalyticsData() async {
    await widget.analytics.resetAnalyticsData();
    setMessage('resetAnalyticsData succeeded');
  }

  Future<void> _testInitiateOnDeviceConversionMeasurement() async {
    await widget.analytics
        .initiateOnDeviceConversionMeasurementWithEmailAddress('test@mail.com');
    setMessage('initiateOnDeviceConversionMeasurement succeeded');
  }

  AnalyticsEventItem itemCreator() {
    return AnalyticsEventItem(
      affiliation: 'affil',
      coupon: 'coup',
      creativeName: 'creativeName',
      creativeSlot: 'creativeSlot',
      discount: 2.22,
      index: 3,
      itemBrand: 'itemBrand',
      itemCategory: 'itemCategory',
      itemCategory2: 'itemCategory2',
      itemCategory3: 'itemCategory3',
      itemCategory4: 'itemCategory4',
      itemCategory5: 'itemCategory5',
      itemId: 'itemId',
      itemListId: 'itemListId',
      itemListName: 'itemListName',
      itemName: 'itemName',
      itemVariant: 'itemVariant',
      locationId: 'locationId',
      price: 9.99,
      currency: 'USD',
      promotionId: 'promotionId',
      promotionName: 'promotionName',
      quantity: 1,
    );
  }

  Future<void> _testAllEventTypes() async {
    await widget.analytics.logAddPaymentInfo();
    await widget.analytics.logAddToCart(
      currency: 'USD',
      value: 123,
      items: [itemCreator(), itemCreator()],
    );
    await widget.analytics.logAddToWishlist();
    await widget.analytics.logAppOpen();
    await widget.analytics.logBeginCheckout(
      value: 123,
      currency: 'USD',
      items: [itemCreator(), itemCreator()],
    );
    await widget.analytics.logCampaignDetails(
      source: 'source',
      medium: 'medium',
      campaign: 'campaign',
      term: 'term',
      content: 'content',
      aclid: 'aclid',
      cp1: 'cp1',
    );
    await widget.analytics.logEarnVirtualCurrency(
      virtualCurrencyName: 'bitcoin',
      value: 345.66,
    );

    await widget.analytics.logGenerateLead(
      currency: 'USD',
      value: 123.45,
    );
    await widget.analytics.logJoinGroup(
      groupId: 'test group id',
    );
    await widget.analytics.logLevelUp(
      level: 5,
      character: 'witch doctor',
    );
    await widget.analytics.logLogin(loginMethod: 'login');
    await widget.analytics.logPostScore(
      score: 1000000,
      level: 70,
      character: 'tiefling cleric',
    );
    await widget.analytics
        .logPurchase(currency: 'USD', transactionId: 'transaction-id');
    await widget.analytics.logSearch(
      searchTerm: 'hotel',
      numberOfNights: 2,
      numberOfRooms: 1,
      numberOfPassengers: 3,
      origin: 'test origin',
      destination: 'test destination',
      startDate: '2015-09-14',
      endDate: '2015-09-16',
      travelClass: 'test travel class',
    );
    await widget.analytics.logSelectContent(
      contentType: 'test content type',
      itemId: 'test item id',
    );
    await widget.analytics.logSelectPromotion(
      creativeName: 'promotion name',
      creativeSlot: 'promotion slot',
      items: [itemCreator()],
      locationId: 'United States',
    );
    await widget.analytics.logSelectItem(
      items: [itemCreator(), itemCreator()],
      itemListName: 't-shirt',
      itemListId: '1234',
    );
    await widget.analytics.logScreenView(
      screenName: 'tabs-page',
    );
    await widget.analytics.logViewCart(
      currency: 'USD',
      value: 123,
      items: [itemCreator(), itemCreator()],
    );
    await widget.analytics.logShare(
      contentType: 'test content type',
      itemId: 'test item id',
      method: 'facebook',
    );
    await widget.analytics.logSignUp(
      signUpMethod: 'test sign up method',
    );
    await widget.analytics.logSpendVirtualCurrency(
      itemName: 'test item name',
      virtualCurrencyName: 'bitcoin',
      value: 34,
    );
    await widget.analytics.logViewPromotion(
      creativeName: 'promotion name',
      creativeSlot: 'promotion slot',
      items: [itemCreator()],
      locationId: 'United States',
      promotionId: '1234',
      promotionName: 'big sale',
    );
    await widget.analytics.logRefund(
      currency: 'USD',
      value: 123,
      items: [itemCreator(), itemCreator()],
    );
    await widget.analytics.logTutorialBegin();
    await widget.analytics.logTutorialComplete();
    await widget.analytics.logUnlockAchievement(id: 'all Firebase API covered');
    await widget.analytics.logViewItem(
      currency: 'usd',
      value: 1000,
      items: [itemCreator()],
    );
    await widget.analytics.logViewItemList(
      itemListId: 't-shirt-4321',
      itemListName: 'green t-shirt',
      items: [itemCreator()],
    );
    await widget.analytics.logViewSearchResults(
      searchTerm: 'test search term',
    );
    setMessage('All standard events logged successfully');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            MaterialButton(
              onPressed: _sendAnalyticsEvent,
              child: const Text('Test logEvent'),
            ),
            MaterialButton(
              onPressed: _testAllEventTypes,
              child: const Text('Test standard event types'),
            ),
            MaterialButton(
              onPressed: _testSetUserId,
              child: const Text('Test setUserId'),
            ),
            MaterialButton(
              onPressed: _testSetAnalyticsCollectionEnabled,
              child: const Text('Test setAnalyticsCollectionEnabled'),
            ),
            MaterialButton(
              onPressed: _testSetSessionTimeoutDuration,
              child: const Text('Test setSessionTimeoutDuration'),
            ),
            MaterialButton(
              onPressed: _testSetUserProperty,
              child: const Text('Test setUserProperty'),
            ),
            MaterialButton(
              onPressed: _testAppInstanceId,
              child: const Text('Test appInstanceId'),
            ),
            MaterialButton(
              onPressed: _testResetAnalyticsData,
              child: const Text('Test resetAnalyticsData'),
            ),
            MaterialButton(
              onPressed: _testSetConsent,
              child: const Text('Test setConsent'),
            ),
            MaterialButton(
              onPressed: _setDefaultEventParameters,
              child: const Text('Test setDefaultEventParameters'),
            ),
            MaterialButton(
              onPressed: _testInitiateOnDeviceConversionMeasurement,
              child: const Text('Test initiateOnDeviceConversionMeasurement'),
            ),
            Text(
              _message,
              style: const TextStyle(color: Color.fromARGB(255, 0, 155, 0)),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<TabsPage>(
              settings: const RouteSettings(name: TabsPage.routeName),
              builder: (BuildContext context) {
                return TabsPage(widget.observer);
              },
            ),
          );
        },
        child: const Icon(Icons.tab),
      ),
    );
  }
}



// void main() {
//   runApp(
//
//     MultiProvider(providers: [
//       ChangeNotifierProvider<StateProvider>(create: (context) => StateProvider())
//     ],
//       child: const MyApp()
//   ));
// }
//
// /// The route configuration.
// final GoRouter _router = GoRouter(
//   routes: <RouteBase>[
//
//     // INIT VIEW
//     GoRoute(
//       path: '/',
//       builder: (BuildContext context, GoRouterState state) {
//         return UserEventsView();
//       },
//     ),
//
//     // USER VIEWS
//     GoRoute(
//       path: '/user_events',
//       pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
//         context: context,
//         state: state,
//         child: const UserEventsView(),
//       ),
//     ),
//     GoRoute(
//       path: '/user_clubs',
//       pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
//         context: context,
//         state: state,
//         child: const UserClubsView(),
//       ),
//     ),
//     GoRoute(
//       path: '/user_map',
//       pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
//         context: context,
//         state: state,
//         child: const UserMapView(),
//       ),
//     ),
//     GoRoute(
//       path: '/user_coupons',
//       pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
//         context: context,
//         state: state,
//         child: const UserCouponsView(),
//       ),
//     ),
//
//     // CLUB VIEWS
//     GoRoute(
//       path: '/club_events',
//       pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
//         context: context,
//         state: state,
//         child: ClubEventsView(),
//       ),
//     ),
//     GoRoute(
//       path: '/club_stats',
//       pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
//         context: context,
//         state: state,
//         child: ClubStatisticsView(),
//       ),
//     ),
//     GoRoute(
//       path: '/club_coupons',
//       pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
//         context: context,
//         state: state,
//         child: ClubCouponsView(),
//       ),
//     ),
//     GoRoute(
//       path: '/club_frontpage',
//       pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
//         context: context,
//         state: state,
//         child: ClubFrontPageView(),
//       ),
//     ),
//
//     // DETAIL VIEWS
//     GoRoute(
//       path: '/coupon_details',
//       pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
//         context: context,
//         state: state,
//         child: CouponDetailView(),
//       ),
//     ),
//     GoRoute(
//         path: '/event_details',
//       pageBuilder: (context, state) => buildPageWithDefaultTransition(
//           context: context,
//           state: state,
//           child: const EventDetailView()
//       )
//     ),
//     GoRoute(
//         path: '/club_details',
//         pageBuilder: (context, state) => buildPageWithDefaultTransition(
//             context: context,
//             state: state,
//             child: const ClubDetailView()
//         )
//     ),
//   ],
// );
//
// CustomTransitionPage buildPageWithDefaultTransition<T>({
//   required BuildContext context,
//   required GoRouterState state,
//   required Widget child,
// }) {
//   return CustomTransitionPage<T>(
//     key: state.pageKey,
//     child: child,
//     transitionDuration: const Duration(milliseconds: 600),
//     transitionsBuilder: (context, animation, secondaryAnimation, child) =>
//         FadeTransition(opacity: animation, child: child),
//   );
// }
//
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//
//       routerConfig: _router,
//
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//             seedColor: Colors.deepPurple,
//           brightness: Brightness.dark
//         ),
//         useMaterial3: true,
//
//         textTheme: TextTheme(
//             displayLarge: const TextStyle(
//                 fontSize: 72,
//                 fontWeight: FontWeight.bold
//             ),
//             titleLarge: GoogleFonts.oswald(
//             ),
//           bodyMedium: GoogleFonts.merriweather(),
//           displaySmall: GoogleFonts.pacifico()
//         ),
//       ),
//     );
//   }
// }