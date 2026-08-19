//
//  Content2View.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 8/11/26.
//
import SwiftUI

struct ParentView: View {
    @State private var activeScreen: ActiveScreen = .main
    @State private var isMenuItemDisabled = true
    @State private var isPrivacyOptionsButtonDisabled = true
    // Your existing bindings/state
    @State private var title = ""
    @State private var description = ""
    @State private var minutes = 1
    @State private var descriptionMode: DescriptionMode = .plain
    @State private var steps: [String] = [""]

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                            .ignoresSafeArea()
            
            switch activeScreen {
            case .main:
                MainContentView(
                    activeScreen: $activeScreen,
                    title: $title,
                    description: $description,
                    minutes: $minutes,
                    descriptionMode: $descriptionMode,
                    steps: $steps
                )
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    )
                )

            case .timer:
                SeaSaltTimer(
                    activeScreen: $activeScreen,
                    title: $title,
                    description: $description,
                    minutes: $minutes,
                    descriptionMode: $descriptionMode,
                    steps: $steps
                )
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    )
                )
            }
        }
        // Controls system tab bar visibility smoothly in sync with activeScreen
        .toolbar(activeScreen == .timer ? .hidden : .visible, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .animation(.easeInOut(duration: 0.35), value: activeScreen)
    }
}
