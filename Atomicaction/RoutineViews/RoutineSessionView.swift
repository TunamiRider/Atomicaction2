//
//  RoutineSessionView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/23/26.
//

import SwiftUI
import SwiftData
import AVFoundation

struct RoutineSessionView: View {
    let routine: Routine
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var router: AppRouter
    @State private var currentIndex = 0
    @State private var title = ""
    @State private var description = ""
    @State private var minutes = 1
    @State private var descriptionMode: DescriptionMode = .routine
    @State private var steps: [String] = [""]
    @State private var isAllRountineDone = false
    @Environment(\.modelContext) private var modelContext
    
    private let interstitialViewModel = InterstitialViewModel()
    @State private var showGameOverAlert = false
    
    @State private var animateText = false
    @State private var isDoneDisabled = true

    private var tasks: [RTask] {
        routine.sortedTasks.filter{ $0.doneToday == false }
    }

    private var currentTask: RTask? {
        guard tasks.indices.contains(currentIndex) else { return nil }
        return tasks[currentIndex]
    }
    
    private var done: Bool {
         currentIndex == tasks.count
    }

    var body: some View {
        Group {
            if let task = currentTask, !done {
                
                ZStack {
                    AppTheme.backgroundGradient.ignoresSafeArea(.all)
                    VStack(spacing: 10) {
                        // 2. Navigation Header Layer
                        HStack {
                            Button {
                                router.navigateTo(.routineHome)
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.backward")
                                        .circularIconStyle()
                                    
                                }
                            }
                            .clipShape(Circle())
                            Spacer()
                            Spacer()
                        }
                        .overlay {
                            
                            Text(String(title.prefix(30))) // 1. Cap to max 30 characters
                                .font(.system(size: 24, weight: .regular))
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 1)
                                .lineLimit(1) // 2. Keep on a single line
                                .minimumScaleFactor(0.5) // 3. Auto-shrink font down to 12pt if text is long
                                .padding(.horizontal, 48) // 4. Prevent text from overlapping the back button
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                        
                        // 1. Main Timer View
                        SeaSaltTimer2(
                            title: $title,
                            description: $description,
                            minutes: $minutes,
                            descriptionMode: $descriptionMode,
                            steps: $steps,
                            onComplete: { complete in
                                goNext(complete: complete)
                            }
                        )
                        .id(task.id)
                        .task(id: task.id) {
                            load(task)
                        }
                        
                    }
                }
                
//            } else {
//                VStack(spacing: 16) {
//                    
//                    if tasks.count == 0 {
//                        Text("Great job🎉")
//                            .font(.title2)
//                            .foregroundStyle(.white)
//                            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
//                            .padding(.bottom, -8)
//                        Text("All Routines are complete.")
//                            .font(.title2)
//                            .foregroundStyle(.white)
//                            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
//                    }else {
//                        Text("Routine Session done!")
//                            .font(.title2)
//                            .foregroundStyle(.white)
//                            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
//                    }
//
//                    Button {
//                        interstitialViewModel.showAdCls {
//                            router.navigateTo(.routineHome)
//                        }
//                    } label: {
//                        Text("Done")
//                            .frame(maxWidth: .infinity)
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .tint(AppTheme.backgroundGradient)
//                    .controlSize(.regular)
//                    .modifier(AppButtonModifiler())
//                    .padding(.horizontal, 128)
//                    
//
//                    
//                    if tasks.count == 0 {
//                    }else {
//                        Text("The following are the skipped routines.")
//                            .font(.title3)
//                            .foregroundStyle(.white)
//                            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
//                            .padding(.top, 80)
//                        VStack(alignment: .leading) {
//                            ForEach(tasks, id: \.self){ task in
//                                Text("• \(task.routine_description)")
//                                    .font(.subheadline)
//                                    .foregroundStyle(.white)
//                                    .multilineTextAlignment(.center)
//                                    .padding(.horizontal, 8)
//                                    .padding(.vertical, 2)
//                            }
//                            .padding(.horizontal, 32)
//                        }.padding(.horizontal)
//                    }
//                    
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(AppTheme.backgroundGradient.ignoresSafeArea())
//            }
            } else {
                VStack(spacing: 16) {
                    if tasks.count == 0 {
                        Text("Great job 🎉")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                            .scaleEffect(animateText ? 1.15 : 0.8)
                            .offset(y: animateText ? -5 : 0)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.4, blendDuration: 0)
                                .repeatCount(3, autoreverses: true),
                                value: animateText
                            )
                        
                        Text("All Routines are complete.")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.9))
                            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                            .opacity(animateText ? 1.0 : 0.0)
                            .animation(.easeIn(duration: 0.4).delay(0.2), value: animateText)

                    } else {
                        Text("Routine Session done! ✨")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                            .scaleEffect(animateText ? 1.12 : 0.85)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.35, blendDuration: 0),
                                value: animateText
                            )
                    }

                    Button {
                        Task {
                            // Safety net: Wait briefly if ad is still loading in background
                            if interstitialViewModel.isLoaded() {
                                await interstitialViewModel.loadAd()
                            }
                            
                            interstitialViewModel.showAdCls {
                                router.navigateTo(.routineHome)
                            }
                        }
                    } label: {
                        Text("Done")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.backgroundGradient)
                    .controlSize(.regular)
                    .modifier(AppButtonModifiler())
                    .padding(.horizontal, 128)
                    .padding(.top, 12)
                    .disabled(isDoneDisabled) // <--- Disables user interaction
                            .opacity(isDoneDisabled ? 0.6 : 1.0) // <--- Visual indication
                            .animation(.easeInOut(duration: 0.15), value: isDoneDisabled)

                    if !tasks.isEmpty {
                        Text("The following are the skipped routines.")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                            .padding(.top, 40)
                        
                        VStack(alignment: .leading) {
                            ForEach(tasks, id: \.self) { task in
                                Text("• \(task.routine_description)")
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                            }
                            .padding(.horizontal, 32)
                        }
                        .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppTheme.backgroundGradient.ignoresSafeArea())
                .task {
                    // 1. Lock the Done button and start bounce animation
                            isDoneDisabled = true
                            withAnimation {
                                animateText = true
                            }
                    
                    // 2. Preload the interstitial ad in parallel
                            await interstitialViewModel.loadAd()
                            
                            // 3. Keep disabled until the bounce animation finishes (~1.2s delay)
                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                            
                            // 4. Enable the Done button smoothly
                            withAnimation {
                                isDoneDisabled = false
                            }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
//        .task{
//            print("task main loadAd")
//            await interstitialViewModel.loadAd()
//        }
        .onChange(of: done){ oldValue, newValue in
            if newValue {
                Task {
                    await interstitialViewModel.loadAd()
                }
            }
        }

    }

    private func load(_ task: RTask) {
        title = task.routine_description
        description = task.routine_description
        minutes = task.minutes
        descriptionMode = .routine
        steps = [task.routine_description]
    }

    private func goNext(complete: Bool) {
        
        if complete && tasks.indices.contains(currentIndex) {
            let taskToUpdate = tasks[currentIndex]
            
            taskToUpdate.doneToday = true
            taskToUpdate.completeDate = Date()
            
            try? modelContext.save()
        }
        
        if !complete {
            currentIndex += 1
        }
        
        if tasks.count == 0 {
            routine.completeDate = Date()
            try? modelContext.save()
        }
        
    }
}


#Preview {
    @Previewable @StateObject var appRouter = AppRouter()
    @Previewable @Query var rutines:[Routine]
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: ATask.self, DailyProgress.self, DailyBreak.self,  Routine.self,// <-- register both models
        configurations: config
    )
    
    
    let sampleTasks: [RTask] = [ RTask(minutes: 1, routine_description: "Test 1 Test 1 Test 1 Test 1 Test 1 Test 1 Test 1 Test 1 Test 1 Test 1"),
//                                 RTask(minutes: 1, routine_description: "Test 2"),
//                                 
//                                 RTask(minutes: 1, routine_description: "Test 3"),
                                
                                 
    ]
    let sampleRoutine = Routine(routines: sampleTasks)
    
    
    RoutineSessionView(routine: sampleRoutine, router:appRouter).modelContainer(container)
}
