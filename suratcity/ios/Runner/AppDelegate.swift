import UIKit
import Flutter
import GoogleMaps
import Firebase
import FirebaseMessaging
import FirebaseAnalytics



@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
        if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        GMSServices.provideAPIKey("AIzaSyB91yhHGMRWDgLYajpg8ACtG5Dl1YUFFEw")
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
