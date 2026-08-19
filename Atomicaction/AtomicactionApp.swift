//
//  AtomicactionApp.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/14/26.
//

import SwiftUI
import SwiftData
import GoogleMobileAds

//import AppTrackingTransparency
//import AdSupport

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    // let versionNumber = string(for: MobileAds.shared.versionNumber)
      
      // ONLY FOR TEST PURPOSE, Delete when publish
      
      //MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [ "e036b20abdf9d274903aab0c9b2aa19b" ];
    //print("Google Mobile Ads SDK version: \(versionNumber)")

    return true
  }
}

@main
struct AtomicactionApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            AtomicactionView()
//                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
//                                // Request ATT after app becomes fully active
//                                requestIDFA()
//                            }
//            MenuView()
//                .navigationViewStyle(StackNavigationViewStyle())
            
        }.modelContainer(for: [ATask.self, DailyProgress.self, DailyBreak.self,  Routine.self, ActionIcon.self])
    }

//    func requestIDFA() {
//            ATTrackingManager.requestTrackingAuthorization { status in
//                DispatchQueue.main.async {
//                    switch status {
//                    case .authorized:
//                        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
//                        print("IDFA: \(idfa)")
//                    case .denied:
//                        print("Tracking denied by user or settings.")
//                    case .restricted:
//                        print("Tracking restricted (child account or device restrictions).")
//                    case .notDetermined:
//                        print("Tracking not determined yet.")
//                    @unknown default:
//                        break
//                    }
//                }
//            }
//        }
}

