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
  runApp(

      MultiProvider(providers: [
        ChangeNotifierProvider<StateProvider>(create: (context) => StateProvider())
      ],
          child: const MyApp()
      ));
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
/// The route configuration.
final GoRouter _router = GoRouter(
  routes: <RouteBase>[

    // INIT VIEW
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return UserEventsView();
      },
    ),

    // USER VIEWS
    GoRoute(
      path: '/user_events',
      pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
        context: context,
        state: state,
        child: const UserEventsView(),
      ),
    ),
    GoRoute(
      path: '/user_clubs',
      pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
        context: context,
        state: state,
        child: const UserClubsView(),
      ),
    ),
    GoRoute(
      path: '/user_map',
      pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
        context: context,
        state: state,
        child: const UserMapView(),
      ),
    ),
    GoRoute(
      path: '/user_coupons',
      pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
        context: context,
        state: state,
        child: const UserCouponsView(),
      ),
    ),

    // CLUB VIEWS
    GoRoute(
      path: '/club_events',
      pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
        context: context,
        state: state,
        child: ClubEventsView(),
      ),
    ),
    GoRoute(
      path: '/club_stats',
      pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
        context: context,
        state: state,
        child: ClubStatisticsView(),
      ),
    ),
    GoRoute(
      path: '/club_coupons',
      pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
        context: context,
        state: state,
        child: ClubCouponsView(),
      ),
    ),
    GoRoute(
      path: '/club_frontpage',
      pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
        context: context,
        state: state,
        child: ClubFrontPageView(),
      ),
    ),

    // DETAIL VIEWS
    GoRoute(
      path: '/coupon_details',
      pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
        context: context,
        state: state,
        child: CouponDetailView(),
      ),
    ),
    GoRoute(
        path: '/event_details',
      pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const EventDetailView()
      )
    ),
    GoRoute(
        path: '/club_details',
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const ClubDetailView()
        )
    ),
  ],
);

CustomTransitionPage buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 600),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(

      routerConfig: _router,

      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
          brightness: Brightness.dark
        ),
        useMaterial3: true,

        textTheme: TextTheme(
            displayLarge: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold
            ),
            titleLarge: GoogleFonts.oswald(
            ),
          bodyMedium: GoogleFonts.merriweather(),
          displaySmall: GoogleFonts.pacifico()
        ),
      ),
    );
  }
}