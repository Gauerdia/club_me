import 'package:club_me/club_coupons/club_coupons_view.dart';
import 'package:club_me/club_coupons/club_new_discount_view.dart';
import 'package:club_me/club_coupons/club_past_discounts_view.dart';
import 'package:club_me/club_coupons/club_upcoming_discounts_view.dart';
import 'package:club_me/club_events/club_edit_event_view.dart';
import 'package:club_me/club_events/club_events_view.dart';
import 'package:club_me/club_events/club_new_event_view.dart';
import 'package:club_me/club_events/club_past_events_view.dart';
import 'package:club_me/club_events/club_upcoming_events_view.dart';
import 'package:club_me/club_frontpage/club_front_page_view.dart';
import 'package:club_me/club_frontpage/components/update_contact_view.dart';
import 'package:club_me/club_frontpage/components/update_news_view.dart';
import 'package:club_me/club_statistics/club_statistics_view.dart';
import 'package:club_me/coming_soon/coming_son_view.dart';
import 'package:club_me/log_in/log_in_view.dart';
import 'package:club_me/models/club_me_user_data.dart';
import 'package:club_me/profile/profile_view.dart';
import 'package:club_me/provider/state_provider.dart';
import 'package:club_me/register/register_view.dart';
import 'package:club_me/settings/settings_view.dart';
import 'package:club_me/detail_pages/club_detail_view.dart';
import 'package:club_me/detail_pages/discount_active_view.dart';
import 'package:club_me/club_coupons/club_edit_discount_view.dart';
import 'package:club_me/detail_pages/event_detail_view.dart';
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
  Hive.registerAdapter(ClubMeUserDataAdapter());

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
        return ComingSoonView();//LogInView(); //Test();
      },
    ),


    // USER VIEWS
    GoRoute(
      path: '/user_events',
      pageBuilder: (context, state) => buildPageWithoutTransition<void>(
        context: context,
        state: state,
        child: const UserEventsView(),
      ),
    ),
    GoRoute(
      path: '/user_clubs',
      pageBuilder: (context, state) => buildPageWithoutTransition<void>(
        context: context,
        state: state,
        child: const UserClubsView(),
      ),
    ),
    GoRoute(
      path: '/user_map',
      pageBuilder: (context, state) => buildPageWithoutTransition<void>(
        context: context,
        state: state,
        child: const UserMapView(),
      ),
    ),
    GoRoute(
      path: '/user_coupons',
      pageBuilder: (context, state) => buildPageWithoutTransition<void>(
        context: context,
        state: state,
        child: const UserCouponsView(),
      ),
    ),
    GoRoute(
      path: '/user_profile',
      pageBuilder: (context, state) => buildPageWithoutTransition<void>(
        context: context,
        state: state,
        child: const ProfileView(),
      ),
    ),


    // CLUB VIEWS
    GoRoute(
      path: '/club_events',
      pageBuilder: (context, state) => buildPageWithoutTransition<void>(
        context: context,
        state: state,
        child: ClubEventsView(),
      ),
    ),
    GoRoute(
      path: '/club_stats',
      pageBuilder: (context, state) => buildPageWithoutTransition<void>(
        context: context,
        state: state,
        child: ClubStatisticsView(),
      ),
    ),
    GoRoute(
      path: '/club_coupons',
      pageBuilder: (context, state) => buildPageWithoutTransition<void>(
        context: context,
        state: state,
        child: ClubDiscountsView(),
      ),
    ),
    GoRoute(
      path: '/club_discounts',
      pageBuilder: (context, state) => buildPageWithoutTransition<void>(
        context: context,
        state: state,
        child: ClubDiscountsView(),
      ),
    ),
    GoRoute(
      path: '/club_frontpage',
      pageBuilder: (context, state) => buildPageWithoutTransition<void>(
        context: context,
        state: state,
        child: ClubFrontPageView(),
      ),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => buildPageWithoutTransition<void>(
        context: context,
        state: state,
        child: SettingsView(),
      ),

    ),


    // DETAIL VIEWS
    GoRoute(
      path: '/coupon_active',
      pageBuilder: (context, state) => buildPageWithoutTransition<void>(
        context: context,
        state: state,
        child: const DiscountActiveView(),
      ),
    ),
    GoRoute(
      path: '/discount_details',
      pageBuilder: (context, state) => buildPageWithoutTransition<void>(
        context: context,
        state: state,
        child: const ClubEditDiscountView(),
      ),

    ),
    GoRoute(
        path: '/event_details',
      pageBuilder: (context, state) => buildPageWithoutTransition(
          context: context,
          state: state,
          child: EventDetailView()
      )
    ),
    GoRoute(
        path: '/club_details',
        pageBuilder: (context, state) => buildPageWithoutTransition(
            context: context,
            state: state,
            child: const ClubDetailView()
        )
    ),

    // NEW, UPCOMING, PAST

    // CLUB
    GoRoute(
        path: '/club_new_event',
        pageBuilder: (context, state) => buildPageWithoutTransition(
            context: context,
            state: state,
            child: const ClubNewEventView()
        )
    ),
    GoRoute(
      path: '/club_upcoming_events',
      pageBuilder: (context, state) => buildPageWithoutTransition<void>(
        context: context,
        state: state,
        child: ClubUpcomingEventsView(),
      ),
    ),
    GoRoute(
      path: '/club_past_events',
      pageBuilder: (context, state) => buildPageWithoutTransition<void>(
        context: context,
        state: state,
        child: ClubPastEventsView(),
      ),
    ),

    // Coupons
    GoRoute(
        path: '/club_new_discount',
        pageBuilder: (context, state) => buildPageWithoutTransition(
            context: context,
            state: state,
            child: const ClubNewDiscountView()
        )
    ),
    GoRoute(
      path: '/club_upcoming_discounts',
      pageBuilder: (context, state) => buildPageWithoutTransition<void>(
        context: context,
        state: state,
        child: ClubUpcomingDiscountsView(),
      ),
    ),
    GoRoute(
      path: '/club_past_discounts',
      pageBuilder: (context, state) => buildPageWithoutTransition<void>(
        context: context,
        state: state,
        child: ClubPastDiscountsView(),
      ),
    ),

    // Update
    GoRoute(
        path: '/club_update_news',
        pageBuilder: (context, state) => buildPageWithoutTransition(
            context: context,
            state: state,
            child: const UpdateNewsView()
        )
    ),
    GoRoute(
        path: '/club_update_contact',
        pageBuilder: (context, state) => buildPageWithoutTransition(
            context: context,
            state: state,
            child: const UpdateContactView()
        )
    ),



    GoRoute(
        path: '/video_recording',
        pageBuilder: (context, state) => buildPageWithoutTransition(
          context: context,
          state: state,
          child: const VideoRecorderScreen()
        )
    ),

    GoRoute(
      path: '/log_in',
      builder: (context, state) => const LogInView(),
    ),

    GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterView()
    ),

    GoRoute(
        path: '/test',
        pageBuilder: (context, state) => buildPageWithoutTransition(
            context: context,
            state: state,
            child: const Test()
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

CustomTransitionPage buildPageWithoutTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 0),
    reverseTransitionDuration: const Duration(microseconds: 0),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}




Future<bool> _onWillPop(BuildContext context) async {
  bool? exitResult = await showDialog(
    context: context,
    builder: (context) => _buildExitDialog(context),
  );
  return exitResult ?? false;
}

Future<bool?> _showExitDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (context) => _buildExitDialog(context),
  );
}

AlertDialog _buildExitDialog(BuildContext context) {
  return AlertDialog(
    title: const Text('Bitte bestätigen'),
    content: const Text('Möchtest du die App schließen?'),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: Text('No'),
      ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(true),
        child: Text('Yes'),
      ),
    ],
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
      ),
    );
  }
}