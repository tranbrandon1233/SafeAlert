import SwiftUI
import FirebaseCore



class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()


    return true
  }
}

@available(iOS 14.0, *)
@main
struct YourApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


    @available(iOS 14.0, *)
    var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
      }
    }
  }
}
