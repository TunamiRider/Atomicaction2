//
//  InterstitialViewModel.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 8/13/26.
//

//
//  Copyright 2022 Google LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

// [START load_ad]
import GoogleMobileAds

class InterstitialViewModel: NSObject, FullScreenContentDelegate {
  private var interstitialAd: InterstitialAd?
  private var isLoading = false
  private var onAdDismissed: (() -> Void)?
    
  func loadAd() async {
      // Prevent simultaneous duplicate requests or reloading if an ad is already cached
      guard interstitialAd == nil, !isLoading else { return }
      
      isLoading = true
      defer{ isLoading = false }
      
    do {
      interstitialAd = try await InterstitialAd.load(
        with: "ca-app-pub-7983349823335048/7060066040", request: Request())
      // [START set_the_delegate]
      interstitialAd?.fullScreenContentDelegate = self
      // [END set_the_delegate]
    } catch {
      print("Failed to load interstitial ad with error: \(error.localizedDescription)")
    }
  }
  // [END load_ad]

  // [START show_ad]
  func showAd() {
    guard let interstitialAd = interstitialAd else {
      //print("Ad wasn't ready.")
        // Try fetching an ad now so it's ready for next time
        Task { await loadAd() }
        return
    }

    interstitialAd.present(from: nil)
  }
  // [END show_ad]
    
  // Yuki
    func showAdCls(onDismiss: @escaping () -> Void){
//        guard let interstitialAd = interstitialAd else {
//            onDismiss()
//            return
//        }
//        
//        self.onAdDismissed = onDismiss
//        
//        if let rootViewController = UIApplication.shared.firstKeyWindow?.rootViewController {
//            interstitialAd.fullScreenContentDelegate = self
//            interstitialAd.present(from: rootViewController)
//        } else {
//            onDismiss()
//        }
        guard let interstitialAd = interstitialAd else {
                onDismiss() // Fallback if ad isn't ready
                // Try fetching an ad now so it's ready for next time
                Task { await loadAd() }
                return
            }
            
            self.onAdDismissed = onDismiss
            interstitialAd.fullScreenContentDelegate = self
            
            // Passing nil automatically presents from the root view controller
            interstitialAd.present(from: nil)
    }
    
    func isLoaded() -> Bool {
        return interstitialAd == nil
    }
  // Yuki

  // MARK: - GADFullScreenContentDelegate methods

  // [START ad_events]
  func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
    //print("\(#function) called")
  }

  func adDidRecordClick(_ ad: FullScreenPresentingAd) {
  }

  func ad(
    _ ad: FullScreenPresentingAd,
    didFailToPresentFullScreenContentWithError error: Error
  ) {

    // Yuki
    // If ad fails to show, trigger the dismiss closure immediately
      onAdDismissed?()
      onAdDismissed = nil
    
      interstitialAd = nil
      // Automatically preload the NEXT ad in the background
              Task {
                  await loadAd()
              }
      
  }

  func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {

  }

  func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {

  }

  func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {

      
      // 1. Run navigation callback
          onAdDismissed?()
          onAdDismissed = nil
      
    // 2. Clear the interstitial ad reference
    // Clear the interstitial ad.
    interstitialAd = nil
      
      // 3. Preload the next ad for future use
          Task {
              await loadAd()
          }
  }
  // [END ad_events]
}


extension UIApplication {
    var firstKeyWindow: UIWindow? {
        return connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
