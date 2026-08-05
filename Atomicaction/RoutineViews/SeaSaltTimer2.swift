//
//  SeaSaltTimer.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/23/26.
//

//
//  SeaSaltTimer.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/14/26.
//

import SwiftUI
import SwiftData
struct SeaSaltTimer2: View {
    
    @Binding var title: String
    @Binding var description: String
    @Binding var minutes: Int
    @Binding var descriptionMode:DescriptionMode
    @Binding var steps: [String]
    
    var onComplete: ((_ complete: Bool)->Void)?
    
    @State private var currentStepIndex: Int = 0

    // MARK: - State
    @State private var secondsRemaining: Int = 0
    @State private var totalSeconds: Int = 0
    @State private var isRunning: Bool = false
    @State private var isSnoozed: Bool = false
    @State private var timer: Timer? = nil
    @State private var isFinished: Bool = false
    @State private var showDescription: Bool = true
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    //@State private var minutes: Int = 5

    @State private var breakStartDate: Date? = nil

    // MARK: - Computed
    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - Double(secondsRemaining) / Double(totalSeconds)
    }

    private var displayMinutes: Int { secondsRemaining / 60 }
    private var displaySeconds: Int { secondsRemaining % 60 }


    // MARK: - Body
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea(.all)

            VStack(spacing: 0) {
                Spacer().frame(height: 10)

                // ── Circular dial ──────────────────────────────────────────
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                        .frame(width: 240, height: 240)
                        .shadow(color: Color.black.opacity(0.4), radius: 1, x: 0, y: 1)

                    // Progress arc
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.white.opacity(0.70), lineWidth: 1.5)
                        .frame(width: 240, height: 240)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)

                    // Dot indicator at tip of arc
                    dotIndicator

                    // Time display
                    VStack(spacing: 4) {
                        Text(String(format: "%02d", displayMinutes))
                            .font(.system(size: 72, weight: .thin, design: .default))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.4), radius: 1, x: 0, y: 1)

                        Text(String(format: "%02d", displaySeconds))
                            .font(.system(size: 52, weight: .thin, design: .default))
                            .foregroundColor(.white.opacity(0.55))
                            .shadow(color: Color.black.opacity(0.4), radius: 1, x: 0, y: 1)
                    }
                }
                .frame(width: 240, height: 240)

                Spacer().frame(height: 20)

                // ── Label ──────────────────────────────────────────────────
                VStack(spacing: 6) {
                    Text(isFinished ? "Time's up" : isRunning ? "Focusing on" : (isSnoozed ? "Having a break" : "Begin"))
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 1)

//                    HStack(spacing: 6) {
//                        Text(title)
//                            .font(.system(size: 24, weight: .regular))
//                            .foregroundColor(.white.opacity(1))
//                    }

                    // MARK: - Description Display
                    Group {
                        if descriptionMode == .steps {
                            VStack(spacing: 0) {
                                TabView(selection: $currentStepIndex) {
                                    ForEach(Array(steps.indices), id: \.self) { index in
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
                                Text(description)
                                    .font(.system(size: 22, weight: .regular))
                                    .foregroundColor(.white.opacity(1))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
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
                    )
                    .frame(height: 300) // set a stable height
                    .padding(.horizontal, 40)
                    //.opacity(showDescription && !description.isEmpty ? 1 : 0)
                    .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 1)
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: showDescription)
                }

                Spacer().frame(height: 20)

                // ── Buttons ────────────────────────────────────────────────
                VStack(alignment: .leading, spacing: 16) {

                    Button {
                        if isFinished {
                            completeRountine()
                            print("isFinished")
                        } else if !isRunning  {
                            startTimer()
                        } else {
                            haveaBreak()
                        }
                    } label: {
//                        Text(isFinished ? "Complete" : isRunning ? "Have a break" : "Start focus")
//                            .font(.system(size: 18, weight: .regular))
//                            .foregroundColor(.white)
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 58)
//                            .background(Color.black.opacity(0.25))
//                            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 30, style: .continuous)
//                                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
//                            )
                        
                        Text(isFinished ? "Complete" : isRunning ? "Have a break" : "Start focus")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 38)
                            .background(Color.black.opacity(0.25))
                            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                            .overlay(
                                // Glossy static sheen
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [.white.opacity(0.4), .clear],
                                            startPoint: .top,
                                            endPoint: .center
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                            )
                            //.shimmering(isActive: true)        // ← animated sweep on top
                    }
                    .padding(.horizontal, 40)
                    
                    if isFinished {
                        Button {
                            startTimer()
                        } label: {
                            Text("Try again")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 38)
                                .background(Color.black.opacity(0.25))
                                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                                .overlay(
                                    // Glossy static sheen
                                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [.white.opacity(0.4), .clear],
                                                startPoint: .top,
                                                endPoint: .center
                                            )
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                                )
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
                    }else {
                        Button {

                            goesToNext()
                        } label: {
                            Text("Skip")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 38)
                                .background(Color.black.opacity(0.25))
                                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                                .overlay(
                                    // Glossy static sheen
                                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [.white.opacity(0.4), .clear],
                                                startPoint: .top,
                                                endPoint: .center
                                            )
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 40)
                        .disabled(isRunning)
                        .opacity(!isRunning ? 1 : 0)
                        .animation(
                            .easeInOut(duration: 1.0),
                            value: !isRunning
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                        
                    }
                }.animation(.spring(response: 0.4, dampingFraction: 0.8), value: isFinished)
                //Spacer(minLength: 50)
                Spacer().frame(height: 10)
            }
        }
        .onAppear {
            totalSeconds = minutes * 60
            secondsRemaining = totalSeconds
        }
        .onChange(of: minutes) { _, newValue in
            guard !isRunning else { return } // don't reset a timer already in progress
            totalSeconds = newValue * 60
            secondsRemaining = totalSeconds
        }
        .onDisappear {
            stopTimer()
            breakStartDate = nil
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
        }
        .frame(width: 240, height: 240)
    }

    // MARK: - Timer logic
    private func startTimer() {
        
        if let start = breakStartDate {
            recordBreak(start: start, end: Date())
            print("recordBreak:")
            breakStartDate = nil
        }
        
        isSnoozed = false
        isFinished = false

        // Reset if needed
        if secondsRemaining == 0 {
            
            totalSeconds = minutes * 60
            secondsRemaining = totalSeconds

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
        print("descriptionMode: \(descriptionMode.rawValue)")
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
            print("Failed to save task: \(error)")
        }
        title = ""
        description = ""
        steps = [""]
        
        onComplete?(true)
    }
    private func goesToNext(){
        onComplete?(false)
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
            print("successfully saved : recordBreak : \(startOfDay.description)")
        } catch {
            print("Failed to save break stat: \(error)")
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
            print("snooze")
        }
    }

    private func haveaBreak() {
        stopTimer()
        // Notify completion — in a real app you'd call bubble.markCompleted() or dismiss
        breakStartDate = Date()
    }
}






//// MARK: - Preview
//#Preview {
//    @Previewable @State var title = "Review app store screenshots"
//    @Previewable @State var description = "A simple tas"
//    //"k app that helps you focus on one thing at a time. Add tasks, view clear steps, and complete work without distraction. Designed for quick action, calm organization, and better daily productivity.A simple task app that helps you focus on one thing at a time. Add tasks, view clear stepsss."
//    @Previewable @State var minutes = 1
//    @Previewable @State var descriptionMode = DescriptionMode.steps
//    @Previewable @State var steps = ["Focus on one task at a time, finish it with clarity, and keep your workflow simple, calm, and productive today.", "test2", "test3"]
//    @Previewable @State var isTapped = true
//    SeaSaltTimer(title: $title, description: $description, minutes: $minutes, descriptionMode: $descriptionMode, steps: $steps)
//
//}
