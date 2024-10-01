import UIKit
import Flutter
import workmanager
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    GMSServices.provideAPIKey("AIzaSyB3DEyasr0mp7UJVlajTOdLIe7pyLLpUwQ")

//            WorkmanagerPlugin.setPluginRegistrantCallback { registry in
               // Registry in this case is the FlutterEngine that is created in Workmanager's
               // performFetchWithCompletionHandler or BGAppRefreshTask.
               // This will make other plugins available during a background operation.
//                GeneratedPluginRegistrant.register(with: registry)
//            }

           // When this task is scheduled from dart it will run with minimum 20 minute frequency. The
           // frequency is not guaranteed rather iOS will schedule it as per user's App usage pattern.
           // If frequency is not provided it will default to 15 minutes
//            WorkmanagerPlugin.registerPeriodicTask(withIdentifier: "be.szymendera.workmanager.rescheduledTask", frequency: NSNumber(value: 20 * 60))

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

   override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
         completionHandler(.alert) // shows banner even if app is in foreground
     }


}
