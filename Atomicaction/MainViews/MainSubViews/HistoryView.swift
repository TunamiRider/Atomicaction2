//
//  HistoryView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/15/26.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ATask.timestamp, order: .reverse) private var tasks: [ATask]

    // Peek amount — how much of the next card shows on the right
    private let peek: CGFloat = 32
    
    private func clearAllTasks() {
        for task in tasks {
            modelContext.delete(task)
        }

        do {
            try modelContext.save()
        } catch {
            //print("Failed to clear tasks: \(error)")
        }
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea(.all)
            
            GeometryReader { geo in
                //let cardWidth = geo.size.width - peek
                
                VStack(alignment: .center ,spacing: 20) {
                    // MARK: Top Bar

                    HeaderView()
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .center, spacing: 8) {
                            ForEach(tasks) { task in
                                TaskCardHarbor(task: task)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .scrollTargetLayout()
                        .padding(.horizontal, 8)
                        
                        Button(role: .destructive) {
                            clearAllTasks()
                        } label: {
                            Label("Clear All Tasks", systemImage: "trash")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.red)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                        Spacer().frame(height: 10)
                    }
                    .frame(maxWidth: .infinity)
                    .scrollTargetBehavior(.viewAligned)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }

    }
}

// MARK: - Task Card (compact, vertical scroll)
struct TaskCardHarbor: View {
    let task: ATask
    @State private var isExpanded = false
    private var timestampLabel: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: task.timestamp)
    }

    private struct MetaRow: View {
        let icon: String
        let label: String

        var body: some View {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.85))
                    .frame(width: 14)
                Text(label)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {

            // ── Header row ──────────────────────────────────
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.descriptionMode == .steps ? "STEPS" : (task.descriptionMode == .plain ? "NOTE" : "Routine"))
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(1))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.15), in: Capsule())
                        .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 1)

                    Text(task.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 1)
                }

                Spacer()
            }

            // ── Description ─────────────────────────────────
            if task.descriptionMode == .steps {
                
                //new
                if !task.steps.isEmpty{
                    if task.steps.count <= 3 {
                        ForEach(task.steps, id: \.self){ step in
                            HStack(spacing: 6) {
                                Text("•")
                                    .foregroundColor(.white.opacity(1))
                                Text(step.description)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.white.opacity(1))
                                    .lineLimit(1)
                            }
                        }
                    } else {
                        
                        if !isExpanded {
                            let firstThreeSteps = Array(task.steps.prefix(3))
                            ForEach(firstThreeSteps, id: \.self){ step in
                                HStack(spacing: 6) {
                                    Text("•")
                                        .foregroundColor(.white.opacity(1))
                                    Text(step.description)
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(.white.opacity(1))
                                        .lineLimit(1)
                                }
                            }
                            Text("+\(task.steps.count - 3) more")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(1))
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isExpanded = true
                                    }
                                }
                            
                        } else {
                            
                            ForEach(task.steps, id: \.self){ step in
                                HStack(spacing: 6) {
                                    Text("•")
                                        .foregroundColor(.white.opacity(1))
                                    Text(step.description)
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(.white.opacity(1))
                                        .lineLimit(1)
                                }
                            }
                            Text("Show less")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(1))
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isExpanded = false
                                    }
                                }
                        }

                    }
                }
                // new
                
                
//                if let firstStep = task.steps.first, !firstStep.isEmpty {
//                    VStack(alignment: .leading, spacing: 4) {
//                        if !isExpanded {
//                            // Collapsed view
//                            
//                            HStack(spacing: 6) {
//                                Text("•")
//                                    .foregroundColor(.white.opacity(1))
//                                Text(firstStep)
//                                    .font(.system(size: 14, weight: .regular))
//                                    .foregroundColor(.white.opacity(1))
//                                    .lineLimit(1)
//
//                                if task.steps.count > 1 {
//                                    Text("+\(task.steps.count - 1) more")
//                                        .font(.system(size: 11, weight: .medium))
//                                        .foregroundColor(.white.opacity(1))
//                                        .onTapGesture {
//                                            withAnimation(.easeInOut(duration: 0.2)) {
//                                                isExpanded = true
//                                            }
//                                        }
//                                }
//                            }
//                            
//                        } else {
//                            // Expanded view — show all steps
//                            ForEach(task.steps, id: \.self) { step in
//                                HStack(spacing: 6) {
//                                    Text("•")
//                                        .foregroundColor(.white.opacity(1))
//                                    Text(step)
//                                        .font(.system(size: 14, weight: .regular))
//                                        .foregroundColor(.white.opacity(1))
//                                }
//                            }
//
//                            Text("Show less")
//                                .font(.system(size: 11, weight: .medium))
//                                .foregroundColor(.white.opacity(1))
//                                .onTapGesture {
//                                    withAnimation(.easeInOut(duration: 0.2)) {
//                                        isExpanded = false
//                                    }
//                                }
//                        }
//                    }
//                    .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 1)
//                    
//                }
            } else if !task.task_description.isEmpty {
//                Text(task.task_description)
//                    .font(.system(size: 14, weight: .regular))
//                    .foregroundColor(.white.opacity(1))
//                    .lineLimit(2)
//                    .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 1)
                Text(task.task_description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
                    .lineLimit(nil) // Removes the line cap completely
                    .fixedSize(horizontal: false, vertical: true) // Prevents vertical clipping in stacks
                    .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 1)
            }

            // ── Meta row (inline, single line) ──────────────
            HStack(spacing: 12) {
                if task.minutes > 0 {
                    MetaRow(icon: "timer", label: "\(task.minutes) min")
                }
                MetaRow(icon: "clock", label: timestampLabel)
            }
            .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 1)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.black.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    // Glossy static sheen
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.2), .clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.55), lineWidth: 1.5)
                )
        }
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ATask.self, configurations: config)

    let sampleTasks: [ATask] = [
        ATask(
            title: "Morning Meditation",
            minutes: 10,
            descriptionMode: .plain,
            task_description: "Sit quietly, focus on breathing, and let thoughts pass without judgment.",
            steps: [],
            timestamp: Date().addingTimeInterval(-3600 * 5)
        ),
        ATask(
            title: "Cook Pasta Dinner",
            minutes: 25,
            descriptionMode: .steps,
            task_description: "",
            steps: [
                "Boil water and add salt",
                "Cook pasta for 9 minutes",
                "Prepare the sauce separately",
                "Combine pasta and sauce",
                "Serve with parmesan on top"
            ],
            timestamp: Date().addingTimeInterval(-3600 * 3)
        ),
        ATask(
            title: "Read a Book Chapter",
            minutes: 30,
            descriptionMode: .plain,
            task_description: "Continue reading from where I left off yesterday, take notes on key ideas.",
            steps: [],
            timestamp: Date().addingTimeInterval(-3600 * 1.5)
        ),
        ATask(
            title: "Clean the Kitchen",
            minutes: 15,
            descriptionMode: .steps,
            task_description: "",
            steps: [
                "Wash dishes",
                "Wipe countertops",
                "Sweep the floor",
                "Take out trash"
            ],
            timestamp: Date().addingTimeInterval(-1800)
        ),
        ATask(
            title: "Quick Stretch",
            minutes: 5,
            descriptionMode: .plain,
            task_description: "",
            steps: [],
            timestamp: Date()
        )
    ]

    for task in sampleTasks {
        container.mainContext.insert(task)
    }

    return HistoryView()
        .modelContainer(container)
        //.background(Color.black.opacity(0.5))
}
