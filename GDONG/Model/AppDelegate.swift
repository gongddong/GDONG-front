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


@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        KakaoSDKCommon.initSDK(appKey: "1cb2a37d6920168105b844b889d7766f") // native key
        GIDSignIn.sharedInstance()?.clientID = "966907908166-emcm81mpq4217qoqtkl9c3ndjcdl5to5.apps.googleusercontent.com"
        
        //apple id 기반으로 사용자 인증 요청
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: KeychainItem.currentUserIdentifier) { (credentialState, error) in
            switch credentialState {
            case .authorized:
                print("apple authorized")
                break // The Apple ID credential is valid.
            case .revoked, .notFound:
                // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
                DispatchQueue.main.async {
                    self.window?.rootViewController?.showLoginViewController()
                }
            default:
                break
            }
        }
        
        //화면 분기
        if (UserDefaults.standard.string(forKey: UserDefaultKey.accessToken) != nil) {
            print("access token yes")
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let tabbarVC = storyboard.instantiateViewController(identifier: "tabbar")
            window?.rootViewController = tabbarVC
            window?.makeKeyAndVisible()
        }else{
            print("access token nil")
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(identifier: "login")
            window?.rootViewController = loginVC
            window?.makeKeyAndVisible()
        }
        
        
        //push notification
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
              [weak self] granted, error in
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
       let token = tokenParts.joined()
       print("Device Token: \(token)")
       
   }
       
   //foreground에서 알림이 온 상태
   func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       // 푸시가 오면 alert, badge, sound표시를 하라는 의미
       completionHandler([.alert, .badge, .sound])
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

}

extension NSNotification.Name {
    static let message = NSNotification.Name("message")
}


