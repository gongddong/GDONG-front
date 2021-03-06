//
//  AppDelegate.swift
//  GDONG
//
//  Created by JoSoJeong on 2021/04/07.
//

import UIKit
import CoreData
import KakaoSDKCommon
import KakaoSDKUser
import GoogleSignIn
import AuthenticationServices
import CoreLocation
import Firebase
import Photos


@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {
  
    var window: UIWindow?
    var locationManager: CLLocationManager!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        KakaoSDKCommon.initSDK(appKey: "1cb2a37d6920168105b844b889d7766f") // native key
        _ = GIDConfiguration.init(clientID: "966907908166-emcm81mpq4217qoqtkl9c3ndjcdl5to5.apps.googleusercontent.com")
        
        self.locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    
        FirebaseApp.configure()
        
        
//        //apple id 기반으로 사용자 인증 요청
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        appleIDProvider.getCredentialState(forUserID: KeychainItem.currentUserIdentifier) { (credentialState, error) in
//            switch credentialState {
//            case .authorized:
//                print("apple authorized")
//                break // The Apple ID credential is valid.
//            case .revoked, .notFound:
//                // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
//                DispatchQueue.main.async {
//                    print(".revoked, .notFound")
//                    //self.window?.rootViewController?.showLoginViewController()
//                }
//            default:
//                break
//            }
//        }
        
//        if #available(iOS 8.0, *) {
//              // For iOS 10 display notification (sent via APNS)
//              UNUserNotificationCenter.current().delegate = self
//
//            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//              UNUserNotificationCenter.current().requestAuthorization(
//                options: authOptions,
//                completionHandler: {_, _ in })
//            } else {
//              let settings: UIUserNotificationSettings =
//                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//              application.registerUserNotificationSettings(settings)
//            }
//
//
//        //앱 추적 허용
//        UNUserNotificationCenter.current().delegate = self
//        application.registerForRemoteNotifications()
//
//        ATTrackingManager.requestTrackingAuthorization { status in
//            DispatchQueue.main.async {
//                switch status {
//                case .authorized:
//                    //idfa = identity for advertisers
//                    let idfa = ASIdentifierManager.shared().advertisingIdentifier
//                    //print("앱 추적 허용")
//
//                case .denied,
//                     .notDetermined,
//                     .restricted:
//                    //print("앱 추적 금지 요청")
//                    break
//                @unknown default:
//                    break
//                }
//            }
//        }
        
        
        //push notification
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
              print("Permission granted: \(granted)")
              
          }
        // APNS 등록
        application.registerForRemoteNotifications()
        
        return true
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
           print("failed to register for notifications")
       }
       
   func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       let tokenParts = deviceToken.map {
           data in String(format: "%02.2hhx", data) }
       let deviceToken = tokenParts.joined()
        UserDefaults.standard.setValue(deviceToken, forKey: UserDefaultKey.deviceToken)
       print("Device Token: \(deviceToken)")
       
   }
       
   //foreground에서 알림이 온 상태
   func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       // 푸시가 오면 alert, badge, sound표시를 하라는 의미
       //completionHandler([.alert, .sound])
   }
   
   //TODO
   //push 온 경우 (보내는 쪽)
   func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

       //post
       NotificationCenter.default.post(name: .message, object: nil)
    }

    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "GDONG")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled: Bool

          handled = GIDSignIn.sharedInstance.handle(url)
          if handled {
            return true
          }

          // Handle other custom URL types.

          // If not handled by this app, return false.
          return false
    }

}

extension NSNotification.Name {
    static let message = NSNotification.Name("message")
}


