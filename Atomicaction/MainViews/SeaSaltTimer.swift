//
//  SeaSaltTimer.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/14/26.
//

import SwiftUI
import SwiftData
import AVFoundation
struct SeaSaltTimer: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var activeScreen: ActiveScreen
    @Binding var title: String
    @Binding var description: String
    @Binding var minutes: Int
    @Binding var descriptionMode:DescriptionMode
    @Binding var steps: [String]
    
    @State private var currentStepIndex: Int = 0

    // MARK: - State
    @State private var secondsRemaining: Int = 0
    @State private var totalSeconds: Int = 0
    @State private var isRunning: Bool = false
    @State private var isSnoozed: Bool = false
    @State private var timer: Timer? = nil
    @State private var isFinished: Bool = false
    @State private var showDescription: Bool = true
    @Environment(\.modelContext) private var modelContext
    //@State private var minutes: Int = 5

    @State private var breakStartDate: Date? = nil
    
    private let interstitialViewModel = InterstitialViewModel()
    @State private var showGameOverAlert = false
    
    private let dingPlayer = AVPlayer.dingPlayer()


    // MARK: - Computed
    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - Double(secondsRemaining) / Double(totalSeconds)
    }

    private var displayMinutes: Int { secondsRemaining / 60 }
    private var displaySeconds: Int { secondsRemaining % 60 }

    init(activeScreen: Binding<ActiveScreen>, title: Binding<String>,
         description: Binding<String>, minutes: Binding<Int>, descriptionMode: Binding<DescriptionMode>, steps: Binding<[String]>  ) {
        self._activeScreen = activeScreen
        self._title = title
        self._description = description
        self._minutes = minutes
        self._descriptionMode = descriptionMode
        self._steps = steps
        // Set initial state BEFORE the view appears
        self._totalSeconds = State(initialValue: minutes.wrappedValue * 60)
        self._secondsRemaining = State(initialValue: minutes.wrappedValue * 60)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // Top Navigation Bar Header
                HStack {
                    Button {
                        //dismiss()
                        withAnimation(.easeInOut(duration: 0.6)) {
                            activeScreen = .main
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.backward")
                                .circularIconStyle()
                        }
                    }
                    .clipShape(Circle())
                    
                    Spacer()
//                    Text(title)
//                        .font(.system(size: 24, weight: .regular))
//                        .foregroundColor(.white)
//                        .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 1)
//                    Spacer()
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
                //.padding(.top, 16)
                .padding(.bottom, 8)
                
                Spacer().frame(height: 25)

                // ── Circular dial ──────────────────────────────────────────
                ZStack {
                    // Background ring
//                    Circle()
//                        .stroke(AppTheme.defaultIconTint.opacity(0.8), lineWidth: 8)
//                        .frame(width: 240, height: 240)
//                        .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 1)

                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    .gray.opacity(0.8),
                                    .white.opacity(0.95),                  // High-contrast shiny light reflection
                                    .gray.opacity(0.8),
                                    .gray.opacity(0.5), // Subtle shadow side
                                    .white.opacity(0.7),                   // Secondary gleam
                                    .gray.opacity(0.8)
                                ],
                                center: .center,
                                startAngle: .degrees(-45),
                                endAngle: .degrees(315)
                            ),
                            lineWidth: 8
                        )
                        .frame(width: 260, height: 260)
                        .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 1)
                        .shadow(color: .white.opacity(0.3), radius: 6)
                    // Progress arc
                    Circle()
                        .trim(from: 0, to: progress)
                        //.stroke(Color.teal.opacity(0.70), lineWidth: 8)
                        .stroke(
                            AppTheme.strokeForProgressArc,
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .shadow(
                                color: AppTheme.strokeShadowForProgressArc,
                                radius: 6
                            )
                        .frame(width: 260, height: 260)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)


                    // Dot indicator at tip of arc
                    dotIndicator

                    // Time display
                    VStack(spacing: 8) {
                        // 1. Main Timer Countdown
                        HStack(spacing: 4) {
                            Text(String(format: "%02d", displayMinutes))

                            Text(":")
                            
                            Text(String(format: "%02d", displaySeconds))
                        }
                        .font(.system(size: 72, weight: .thin, design: .default).monospacedDigit())
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.8), radius: 1, x: 0, y: 1)

                        // 2. Current Time Badge (Updates live every second)
                        TimelineView(.periodic(from: .now, by: 1.0)) { context in
                            HStack(spacing: 6) {
                                Image(systemName: "clock.fill") // or "bell.fill" / "alarm.fill"
                                    .font(.system(size: 13, weight: .medium))
                                
                                Text(context.date.formatted(date: .omitted, time: .shortened))
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                            }
                            .foregroundColor(.white.opacity(0.75))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.white.opacity(0.12), in: Capsule())
                            .shadow(color: Color.black.opacity(0.8), radius: 1, x: 0, y: 1)
                        }
                    }
                }
                .frame(width: 240, height: 240)

                Spacer().frame(height: 25)

                // ── Label ──────────────────────────────────────────────────
                VStack(spacing: 6) {
//                    Text(isFinished ? "Time's up" : isRunning ? "Focusing on" : (isSnoozed ? "Having a break" : "Begin"))
//                        .font(.system(size: 24, weight: .semibold))
//                        .foregroundColor(.white)
//                        .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 1)

//                    HStack(spacing: 6) {
//                        Text(title)
//                            .font(.system(size: 24, weight: .regular))
//                            .foregroundColor(.white)
//                            .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 1)
//                    }

                    // MARK: - Description Display
                    Group {
                        if descriptionMode == .steps {
                            VStack(spacing: 0) {
                                TabView(selection: $currentStepIndex) {
                                    ForEach(steps.indices, id: \.self) { index in
                                        Text(steps[index])
                                            .font(.system(size: 22, weight: .regular))
                                            .foregroundColor(.white.opacity(0.80))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 8)
                                            .frame(maxWidth: .infinity)
                                            .tag(index)
                                    }
                                }
                                .tabViewStyle(.page(indexDisplayMode: .never))
                                .frame(height: 300)
                                

                                // Custom dots indicator
                                HStack(spacing: 6) {
                                    ForEach(steps.indices, id: \.self) { index in
                                        Circle()
                                            .fill(index == currentStepIndex ? Color.white.opacity(0.9) : Color.white.opacity(0.3))
                                            .frame(width: 6, height: 6)
                                    }
                                }
                                .offset(y: -8)
                                
                            }
                        } else {
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack {
                                    
                                    Text(description)
                                        .font(.system(size: 22, weight: .regular))
                                        .foregroundColor(.white.opacity(0.80))
                                        .multilineTextAlignment(.center)

                                        .frame(maxWidth: .infinity)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .containerRelativeFrame(.vertical, alignment: .center)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 8)
                                    
                                }.frame(maxWidth: .infinity)

                            }
                            
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.black.opacity(0.25))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.20), lineWidth: 0.5)
                            )
                            .shadow(color: Color.black.opacity(0.6), radius: 2, x: 0, y: 1)
                    )
                    .frame(height: 300) // set a stable height
                    .padding(.horizontal, 40)
                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: showDescription)
                }

                Spacer().frame(height: 10)

                // ── Buttons ────────────────────────────────────────────────
                VStack(alignment: .center, spacing: 16) {

                    Button {
                        if isFinished {
                            completeRountine()
                        } else if !isRunning  {
                            startTimer()
                        } else {
                            getUp()
                        }
                    } label: {
                        Text(isFinished ? "Complete" : isRunning ? "Have a break" : "Start focus")
                            .modifier(AppButtonModifiler())
                    }
                    .padding(.horizontal, 40)
                    .transition(.opacity)

                    
                    Button {
                        startTimer()
                    } label: {
                        Text("Try again")
                            .modifier(AppButtonModifiler())
                    }
                    .padding(.horizontal, 40)
                    .disabled(!isFinished)
                    .opacity(isFinished ? 1 : 0)
                    .animation(
                        .easeInOut(duration: 1.0),
                        value: isFinished
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))

                }
                //.animation(.spring(response: 0.4, dampingFraction: 0.8), value: isFinished)
                
                Spacer().frame(height: 10)
            }
            .toolbar(.hidden, for: .tabBar)
            
        }
        .onDisappear {
            stopTimer()
            breakStartDate = nil
        }
        .onAppear {
            Task {
                await interstitialViewModel.loadAd()
            }
        }
        .alert(isPresented: $showGameOverAlert) {
            Alert(
                title: Text("Routine Completed"),
                message: Text("You completed \(title)!"),
                dismissButton: .default(
                    Text("OK"),
                    action: {
                        // Show Ad
//                        interstitialViewModel.showAd()
//                        withAnimation(.easeInOut(duration: 0.6)){
//                            activeScreen = .main
//                        }
                        
                        interstitialViewModel.showAdCls {
                            // Transition screen AFTER user dismisses alert
                            withAnimation(.easeInOut(duration: 0.6)) {
                                activeScreen = .main
                                title = ""
                                description = ""
                                steps = [""]
                            }
                        }
                        

                    }
                )
            )
        }
    }

    // MARK: - Dot indicator
    private var dotIndicator: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = geo.size.width / 2
            let angle = (progress * 360 - 90) * .pi / 180
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)

            Circle()
                .fill(Color.white)
                .frame(width: 8, height: 8)
                .position(x: x, y: y)
                .shadow(color: Color.black.opacity(0.8), radius: 1, x: 0, y: 1)
        }
        .frame(width: 260, height: 260)
    }

    // MARK: - Timer logic
    private func startTimer() {
        
        if let start = breakStartDate {
            recordBreak(start: start, end: Date())
            breakStartDate = nil
        }
        
        isSnoozed = false
        isFinished = false

        // Reset if needed
        if secondsRemaining == 0 {
            
            totalSeconds = minutes * 60
            secondsRemaining = totalSeconds

        }
        
        //Start a timer
        if totalSeconds == secondsRemaining {
            dingPlayer.seek(to: .zero)
            dingPlayer.play()
        }

        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            
            Task { @MainActor in
                
                guard isRunning else { return }
                if secondsRemaining > 0 {
                    secondsRemaining -= 1
                } else {
                    isFinished = true
                    stopTimer()
                    dingPlayer.seek(to: .zero)
                    dingPlayer.play()
                }
            }

        }
    }
    private func completeRountine(){
        let timestamp = Date()
        
        if let start = breakStartDate {
            recordBreak(start: start, end: timestamp)
            breakStartDate = nil
        }
        
        let task = ATask(
            title: title,
            minutes: minutes,
            descriptionMode: descriptionMode,
            task_description: description,
            steps: steps,
            timestamp: timestamp
        )

        modelContext.insert(task)
        
        recordProgress(taskTitle: title, minutes: minutes, at: timestamp)
        
        do {
            try modelContext.save()
        } catch {
            //print("Failed to save task: \(error)")
        }
//        title = ""
//        description = ""
//        steps = [""]
        
//        withAnimation(.easeInOut(duration: 0.6)) {
//            activeScreen = .main
//        }
        
        showGameOverAlert = true
    }
    
    private func recordProgress(taskTitle: String, minutes: Int, at date: Date) {
        let startOfDay = Calendar.current.startOfDay(for: date)

        let descriptor = FetchDescriptor<DailyProgress>(
            predicate: #Predicate { $0.date == startOfDay }
        )

        let today = (try? modelContext.fetch(descriptor))?.first
            ?? {
                let new = DailyProgress(date: startOfDay)
                modelContext.insert(new)
                return new
            }()

        today.entries.append(TaskEntry(taskTitle: taskTitle, minutes: minutes, completedAt: date))
    }
    
    private func recordBreak(start: Date, end: Date){
        
        let seconds = Int(end.timeIntervalSince(start))
        guard seconds > 0 else { return }
        let minutes = Double(seconds) / 60.0
        
        let startOfDay = Calendar.current.startOfDay(for: end)
        
        let descriptor = FetchDescriptor<DailyBreak>(
            predicate: #Predicate { $0.date == startOfDay }
        )
        
        let stat = (try? modelContext.fetch(descriptor))?.first ?? {
            let new = DailyBreak(date: startOfDay)
            modelContext.insert(new)
            return new
        }()
        
        // Running average: newAvg = (oldAvg * oldCount + newValue) / (oldCount + 1)
        let newCount = stat.breakCount + 1
        let totalAverageBreakMinutes = (Double(stat.averageBreakMinutes) * Double(stat.breakCount) + minutes)
        stat.averageBreakMinutes = totalAverageBreakMinutes  / Double(newCount)
        stat.breakCount = newCount

        do {
            try modelContext.save()
        } catch {
            //print("Failed to save break stat: \(error)")
        }
        
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isSnoozed = true
    }

    private func snooze() {
        stopTimer()
        isSnoozed = true
        // Snooze for 5 minutes
        totalSeconds = minutes * 60
        secondsRemaining = totalSeconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            startTimer()
        }
    }

    private func getUp() {
        stopTimer()
        // Notify completion — in a real app you'd call bubble.markCompleted() or dismiss
        breakStartDate = Date()
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var title = "Review app store screenshots!!"
    @Previewable @State var description = "Focus on one task at a time, finish it with clarity, and keep your workflow simple, calm, and productive today.\nFocus on one task at a time, finish it with clarity, and keep your workflow simple, calm, and productive today.\nFocus on one task at a time, finish it with clarity, and keep your workflow simple, calm, and productive today."
    //"k app that helps you focus on one thing at a time. Add tasks, view clear steps, and complete work without distraction. Designed for quick action, calm organization, and better daily productivity.A simple task app that helps you focus on one thing at a time. Add tasks, view clear stepsss."
    @Previewable @State var minutes = 1
    @Previewable @State var descriptionMode = DescriptionMode.plain
    @Previewable @State var steps = ["Focus on one task at a time, finish it with clarity, and keep your workflow simple, calm, and productive today.", "test2", "test3"]
    @Previewable @State var isTapped = true
    @Previewable @State var activeScreen: ActiveScreen = .main
    
    SeaSaltTimer(activeScreen: $activeScreen, title: $title, description: $description, minutes: $minutes, descriptionMode: $descriptionMode, steps: $steps)

}
