import 'dart:ui';

import 'package:club_me/1_events/club_view/club_edit_event_view.dart';
import 'package:club_me/1_events/user_view/user_upcoming_events_view.dart';
import 'package:club_me/3_clubs/club_view/components/add_opening_days_view.dart';
import 'package:club_me/3_clubs/club_view/components/offers_list_club_view.dart';
import 'package:club_me/3_clubs/club_view/components/update_frontpage_banner_image_view.dart';
import 'package:club_me/3_clubs/user_view/offers_list_view.dart';
import 'package:club_me/club_statistics/club_statistics_view.dart';
import 'package:club_me/log_in/log_in_view.dart';
import 'package:club_me/models/hive_models/0_club_me_user_data.dart';
import 'package:club_me/models/hive_models/5_club_me_used_discount.dart';
import 'package:club_me/profile/profile_view.dart';
import 'package:club_me/provider/current_and_liked_elements_provider.dart';
import 'package:club_me/provider/fetched_content_provider.dart';
import 'package:club_me/provider/state_provider.dart';
import 'package:club_me/provider/user_data_provider.dart';
import 'package:club_me/register/components/enter_as_developer_view.dart';
import 'package:club_me/register/components/forgot_password_view.dart';
import 'package:club_me/register/components/log_in_as_club_view.dart';
import 'package:club_me/register/components/register_for_user_as_club_view.dart';
import 'package:club_me/register/register_view.dart';
import 'package:club_me/settings/club_view/components/faq_club_view.dart';
import 'package:club_me/settings/club_view/settings_club_view.dart';
import 'package:club_me/settings/user_view/components/faq_user_view.dart';
import 'package:club_me/settings/user_view/components/sponsors_view.dart';
import 'package:club_me/settings/user_view/settings_user_view.dart';
import 'package:club_me/shared/test.dart';
import 'package:club_me/stories/show_story_chewie.dart';
import 'package:club_me/stories/video_recorder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:camera/camera.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:workmanager/workmanager.dart';

import '1_events/club_view/club_choose_event_template_view.dart';
import '1_events/club_view/club_events_view.dart';
import '1_events/club_view/club_new_event_view.dart';
import '1_events/club_view/club_past_events_view.dart';
import '1_events/club_view/club_upcoming_events_view.dart';
import '1_events/event_detail_view.dart';
import '1_events/user_view/user_events_view.dart';
import '2_discounts/club_view/club_choose_discount_template_view.dart';
import '2_discounts/club_view/club_coupons_view.dart';
import '2_discounts/club_view/club_edit_discount_view.dart';
import '2_discounts/club_view/club_new_discount_view.dart';
import '2_discounts/club_view/club_past_discounts_view.dart';
import '2_discounts/club_view/club_upcoming_discounts_view.dart';
import '2_discounts/discount_active_view.dart';
import '2_discounts/user_view/user_coupons_view.dart';
import '3_clubs/club_detail_view.dart';
import '3_clubs/club_view/club_front_page_view.dart';
import '3_clubs/club_view/components/update_contact_view.dart';
import '3_clubs/club_view/components/update_news_view.dart';
import '3_clubs/club_view/components/update_photos_and_videos_view.dart';
import '3_clubs/user_view/user_clubs_view.dart';
import '4_map/user_map_view.dart';
import 'models/hive_models/1_club_me_discount_template.dart';
import 'models/hive_models/2_club_me_local_discount.dart';
import 'models/hive_models/3_club_me_event_template.dart';
import 'models/hive_models/4_temp_geo_location_data.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

const rescheduledTaskKey = "be.szymendera.workmanager.rescheduledTask";

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Set up Hive, our on device database
  await Hive.initFlutter((await getApplicationDocumentsDirectory()).path);
  Hive.registerAdapter(ClubMeUserDataAdapter());
  Hive.registerAdapter(ClubMeEventTemplateAdapter());
  Hive.registerAdapter(ClubMeDiscountTemplateAdapter());
  Hive.registerAdapter(ClubMeLocalDiscountAdapter());
  Hive.registerAdapter(TempGeoLocationDataAdapter());
  Hive.registerAdapter(ClubMeUsedDiscountAdapter());

  // Used to make sure that coupons and user timezones match
  tz.initializeTimeZones();

  // connect to our backend
  await Supabase.initialize(
    url: 'https://mssfbflgzkgxyhkkfukh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1zc2ZiZmxnemtneHloa2tmdWtoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTUyNTM2MzUsImV4cCI6MjAzMDgyOTYzNX0.aG3TR8A3UrpZNW65qDZ1BXyasQEo65NzgS03FcTebs0'
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Get the directory of the app to save images and videos
  var appDocumentsDir = await getApplicationDocumentsDirectory();

  // Get cameras for stories
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  // Set a logger to make development easier
  Logger.level = Level.debug;

  // No landscape mode because it is not optimised for it
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider<StateProvider>(
          create: (context) => StateProvider(camera: firstCamera, appDocumentsDir: appDocumentsDir)
      ),
      ChangeNotifierProvider<UserDataProvider>(
          create: (context) => UserDataProvider()
      ),
      ChangeNotifierProvider<FetchedContentProvider>(
          create: (context) => FetchedContentProvider()
      ),
      ChangeNotifierProvider<CurrentAndLikedElementsProvider>(
          create: (context) => CurrentAndLikedElementsProvider()
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
      builder: (BuildContext context, GoRouterState state)
      => RegisterView()
      //ComingSoonView();//LogInView(); //Test();
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
      path: '/user_settings',
      pageBuilder: (context, state) => buildPageWithoutTransition<void>(
        context: context,
        state: state,
        child: SettingsUserView(),
      ),
    ),
    GoRoute(
      path: '/club_settings',
      pageBuilder: (context, state) => buildPageWithoutTransition<void>(
        context: context,
        state: state,
        child: SettingsClubView(),
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
        path: '/club_event_templates',
        pageBuilder: (context, state) => buildPageWithoutTransition(
            context: context,
            state: state,
            child: const ClubChooseEventTemplateView()
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
      path: '/user_upcoming_events',
      pageBuilder: (context, state) => buildPageWithoutTransition<void>(
        context: context,
        state: state,
        child: UserUpcomingEventsView(),
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
        path: '/club_discount_templates',
        pageBuilder: (context, state) => buildPageWithoutTransition(
            context: context,
            state: state,
            child: const ClubChooseDiscountTemplateView()
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
        path: '/club_update_photos_and_videos',
        pageBuilder: (context, state) => buildPageWithoutTransition(
            context: context,
            state: state,
            child: const UpdatePhotosAndVideosView()
        )
    ),
    GoRoute(
        path: '/club_offers',
        pageBuilder: (context, state) => buildPageWithoutTransition(
            context: context,
            state: state,
            child: const OffersListClubView()
        )
    ),
    GoRoute(
        path: '/user_offers',
        pageBuilder: (context, state) => buildPageWithoutTransition(
            context: context,
            state: state,
            child: const OffersListView()
        )
    ),


    GoRoute(
        path: '/show_story',
        pageBuilder: (context, state) => buildPageWithoutTransition(
            context: context,
            state: state,
            child: ShowStoryChewie()
        )
    ),


    GoRoute(
        path: '/club_edit_event',
        pageBuilder: (context, state) => buildPageWithoutTransition(
            context: context,
            state: state,
            child: const ClubEditEventView()
        )
    ),

    GoRoute(
        path: '/club_edit_discount',
        pageBuilder: (context, state) => buildPageWithoutTransition(
            context: context,
            state: state,
            child: const ClubEditDiscountView()
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
        path: '/register_log_in_club',
        builder: (context, state) => const LogInAsClubView()
    ),

    GoRoute(
        path: '/register_for_user_as_club',
        builder: (context, state) => const RegisterForUserAsClubView()
    ),

    GoRoute(
      path: '/forgot_password',
      builder: (context, state) => ForgotPasswordView()
    ),

    GoRoute(
        path: '/club_faq',
        builder: (context, state) => const FaqClubView()
    ),


    GoRoute(
        path: '/user_faq',
        builder: (context, state) => const FaqUserView()
    ),


    GoRoute(
        path: '/user_sponsors',
        builder: (context, state) => const SponsorsView()
    ),

    GoRoute(
        path: '/club_change_banner_image',
        builder: (context, state) => const UpdateFrontpageBannerImageView()
    ),

    GoRoute(
        path: '/club_change_opening_times',
        builder: (context, state) => const AddOpeningDaysView()
    ),

    GoRoute(
        path: '/test',
        pageBuilder: (context, state) => buildPageWithoutTransition(
            context: context,
            state: state,
            child: const Test()
        )
    ),

    GoRoute(
        path: '/enter_as_developer',
        builder: (context, state) => const EnterAsDeveloperView()
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
          scaffoldBackgroundColor: const Color(0xff121111),

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
