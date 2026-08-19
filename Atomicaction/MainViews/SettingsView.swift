//
//  SettingsView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 8/13/26.
//
import SwiftUI


struct SettingsView: View {
    //@Binding var isPrivacyOptionsButtonDisabled: Bool
    
    @State private var isMenuItemDisabled = true
    @State private var showPrivacyOptionsAlert = false
    @State private var formErrorDescription: String?
    
    // Check property directly from the manager
    private var isPrivacyOptionsButtonDisabled: Bool {
        !GoogleMobileAdsConsentManager.shared.isPrivacyOptionsRequired
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea(.all)
                Form {
                    Section {
                        Button {
                            Task {
                                do {
                                    try await GoogleMobileAdsConsentManager.shared.presentPrivacyOptionsForm()
                                } catch {
                                    formErrorDescription = error.localizedDescription
                                    showPrivacyOptionsAlert = true
                                }
                            }
                        } label: {
                            HStack(spacing: 12) {
                                // Native iOS-style app icon tile
                                Image(systemName: "hand.raised.fill")
                                    .font(.body)
                                    .foregroundStyle(.white)
                                    .frame(width: 28, height: 28)
                                    .background(Color.blue, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                                
                                Text("Privacy Settings")
                                    .foregroundStyle(.black)
                                
                                Spacer()
                                
                                // Chevron indicator for navigation-like action
                                Image(systemName: "chevron.right")
                                    .font(.footnote.bold())
                                    .foregroundStyle(.black)
                            }
                        }
                        .disabled(isPrivacyOptionsButtonDisabled)
                    } footer: {
                        Text("Manage your consent and advertising privacy choices.")
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .listRowBackground(Color.white.opacity(0.85))
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .alert("Error", isPresented: $showPrivacyOptionsAlert, presenting: formErrorDescription) { _ in
                    Button("OK", role: .cancel) { }
                } message: { errorDetails in
                    Text("\(errorDetails)\nPlease try again later.")
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var isPrivacyOptionsButtonDisabled = false
    
    SettingsView()
    
}
