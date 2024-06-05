import 'package:club_me/club_coupons/club_coupons_view.dart';
import 'package:club_me/club_coupons/club_new_discount_view.dart';
import 'package:club_me/club_coupons/club_past_discounts_view.dart';
import 'package:club_me/club_coupons/club_upcoming_discounts_view.dart';
import 'package:club_me/club_events/club_events_view.dart';
import 'package:club_me/club_events/club_new_event_view.dart';
import 'package:club_me/club_events/club_past_events_view.dart';
import 'package:club_me/club_events/club_upcoming_events_view.dart';
import 'package:club_me/club_frontpage/club_front_page_view.dart';
import 'package:club_me/club_frontpage/components/update_contact_view.dart';
import 'package:club_me/club_frontpage/components/update_news_view.dart';
import 'package:club_me/club_statistics/club_statistics_view.dart';
import 'package:club_me/log_in/log_in_view.dart';
import 'package:club_me/provider/state_provider.dart';
import 'package:club_me/shared/detail_pages/club_detail_view.dart';
import 'package:club_me/shared/detail_pages/discount_active_view.dart';
import 'package:club_me/shared/detail_pages/discount_detail_view.dart';
import 'package:club_me/shared/detail_pages/event_detail_view.dart';
import 'package:club_me/shared/test.dart';
import 'package:club_me/shared/video_recorder_screen.dart';
import 'package:club_me/user_clubs/user_clubs_view.dart';
import 'package:club_me/user_coupons/user_coupons_view.dart';
import 'package:club_me/user_events/user_events_view.dart';
import 'package:club_me/user_map/user_map_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:camera/camera.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up Hive
  await Hive.initFlutter((await getApplicationDocumentsDirectory()).path);

  // Used to make sure that coupons and user timezones match
  tz.initializeTimeZones();

  await Supabase.initialize(
    url: 'https://mssfbflgzkgxyhkkfukh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1zc2ZiZmxnemtneHloa2tmdWtoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTUyNTM2MzUsImV4cCI6MjAzMDgyOTYzNX0.aG3TR8A3UrpZNW65qDZ1BXyasQEo65NzgS03FcTebs0'
  );

  final cameras = await availableCameras();

  final firstCamera = cameras.first;

  Logger.level = Level.debug;

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider<StateProvider>(
          create: (context) => StateProvider(camera: firstCamera)
      )
    ],
      child: const MyApp()
    ));
}

final supabase = Supabase.instance.client;

/// The route configuration.
final GoRouter _router = GoRouter(

  routes: <RouteBase>[

    // INIT VIEW
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return LogInView();
      },
    ),

    // USER VIEWS
    GoRoute(
      path: '/user_events',
      builder: (context, state) => const UserEventsView(),
      // pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      //   context: context,
      //   state: state,
      //   child: const UserEventsView(),
      // ),
    ),
    GoRoute(
      path: '/user_clubs',
      builder: (context, state) => const UserClubsView(),
      // pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      //   context: context,
      //   state: state,
      //   child: const UserClubsView(),
      // ),
    ),
    GoRoute(
      path: '/user_map',
      builder: (context, state) => const UserMapView(),
      // pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      //   context: context,
      //   state: state,
      //   child: const UserMapView(),
      // ),
    ),
    GoRoute(
      path: '/user_coupons',
      builder: (context, state) => const UserCouponsView(),
      // pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      //   context: context,
      //   state: state,
      //   child: const UserCouponsView(),
      // ),
    ),

    // CLUB VIEWS
    GoRoute(
      path: '/club_events',
      builder: (context, state) => ClubEventsView(),
      // pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      //   context: context,
      //   state: state,
      //   child: ClubEventsView(),
      // ),
    ),

    GoRoute(
      path: '/club_upcoming_events',
      builder: (context, state) => ClubUpcomingEventsView(),
      // pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      //   context: context,
      //   state: state,
      //   child: ClubUpcomingEventsView(),
      // ),
    ),

    GoRoute(
      path: '/club_past_events',
      builder: (context, state) => ClubPastEventsView(),
      // pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      //   context: context,
      //   state: state,
      //   child: ClubPastEventsView(),
      // ),
    ),

    GoRoute(
      path: '/club_stats',
      builder: (context, state) => ClubStatisticsView(),
      // pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      //   context: context,
      //   state: state,
      //   child: ClubStatisticsView(),
      // ),
    ),
    GoRoute(
      path: '/club_coupons',
      builder: (context, state) => ClubDiscountsView(),
      // pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      //   context: context,
      //   state: state,
      //   child: ClubDiscountsView(),
      // ),
    ),
    GoRoute(
      path: '/club_discounts',
      builder: (context, state) => ClubDiscountsView(),
      // pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      //   context: context,
      //   state: state,
      //   child: ClubDiscountsView(),
      // ),
    ),

    GoRoute(
      path: '/club_upcoming_discounts',
      builder: (context, state) => ClubUpcomingDiscountsView(),
      // pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      //   context: context,
      //   state: state,
      //   child: ClubUpcomingDiscountsView(),
      // ),
    ),

    GoRoute(
      path: '/club_past_discounts',
      builder: (context, state) => ClubPastDiscountsView(),
      // pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      //   context: context,
      //   state: state,
      //   child: ClubPastDiscountsView(),
      // ),
    ),

    GoRoute(
      path: '/club_frontpage',
      builder: (context, state) => ClubFrontPageView(),
      // pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      //   context: context,
      //   state: state,
      //   child: ClubFrontPageView(),
      // ),
    ),

    // DETAIL VIEWS
    GoRoute(
      path: '/coupon_active',
      builder: (context, state) => const DiscountActiveView(),
      // pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      //   context: context,
      //   state: state,
      //   child: const DiscountActiveView(),
      // ),
    ),
    GoRoute(
      path: '/discount_details',
      builder: (context, state) => const DiscountDetailView(),
      // pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      //   context: context,
      //   state: state,
      //   child: const DiscountDetailView(),
      // ),
    ),

    GoRoute(
        path: '/event_details',
        builder: (context, state) => EventDetailView()
      /*pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: EventDetailView()
      )*/
    ),
    GoRoute(
        path: '/club_details',
        builder: (context, state) => const ClubDetailView()
       /* pageBuilder: (context, state) => buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const ClubDetailView()
        )*/
    ),
    GoRoute(
        path: '/test',
        builder: (context, state) => const Test()
        /*pageBuilder: (context, state) => buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const Test()
        )*/
    ),
    GoRoute(
        path: '/club_new_event',
        builder: (context, state) => const ClubNewEventView()
/*        pageBuilder: (context, state) => buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const ClubNewEventView()
        )*/
    ),

    GoRoute(
        path: '/club_update_news',
        builder: (context, state) => const UpdateNewsView()
/*        pageBuilder: (context, state) => buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const UpdateNewsView()
        )*/
    ),

    GoRoute(
        path: '/club_update_contact',
        builder: (context, state) =>  const UpdateContactView()
        // pageBuilder: (context, state) => buildPageWithDefaultTransition(
        //     context: context,
        //     state: state,
        //     child: const UpdateContactView()
        // )
    ),

    GoRoute(
        path: '/club_new_discount',
        builder: (context, state) => ClubNewDiscountView()
/*        pageBuilder: (context, state) => buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const ClubNewDiscountView()
        )*/
    ),

    GoRoute(
        path: '/video_recording',
        builder: (context, state) => const VideoRecorderScreen()
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
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      child: MaterialApp.router(

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('de')
        ],

        routerConfig: _router,

        title: 'Club Me Test Version',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
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
      )
    );
  }
}