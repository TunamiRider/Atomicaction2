//
//  RoutineSummaryView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/22/26.
//

import SwiftUI
import SwiftData

// MARK: - Pie Slice Shape

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle - .degrees(90),
            endAngle: endAngle - .degrees(90),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - Pie Chart

struct PieChartView: View {
    let tasks: [RTask]
    let colors: [Color]
    let icons: [String]

    private var total: Double {
        tasks.reduce(0) { $0 + Double($1.minutes) }
    }

    struct Slice: Identifiable {
        let id = UUID()
        let task: RTask
        let startAngle: Angle
        let endAngle: Angle
        let color: Color
        let icon: String
    }

    private var slices: [Slice] {
        var result: [Slice] = []
        var currentAngle = Angle.degrees(0)

        for (_, task) in tasks.enumerated() {
            let fraction = total > 0 ? Double(task.minutes) / total : 0
            let sweep = Angle.degrees(fraction * 360)
            let endAngle = currentAngle + sweep
            result.append(
//                Slice(task: task, startAngle: currentAngle, endAngle: endAngle, color: colors[index % colors.count],icon: icons[index % icons.count])
                
                Slice(task: task, startAngle: currentAngle, endAngle: endAngle, color: task.icon.color,icon: task.icon.systemName)
                
            )
            currentAngle = endAngle
        }
        return result
    }
    
    // Minimum sweep (in degrees) before we bother placing an icon,
    // so tiny slivers don't get an overlapping/clipped icon.
    private let minSweepForIcon: Double = 18

    var body: some View {

        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = size / 2
            let iconRadius = radius * 0.62
 
            ZStack {
                ForEach(slices) { slice in
                    PieSlice(startAngle: slice.startAngle, endAngle: slice.endAngle)
                        .fill(slice.color)
//                        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 1, y: 1)
//                        .shadow(color: Color.black.opacity(0.1), radius: 1, x: -1, y: -1)
                    // 🌟 Top-Left Glossy Highlight Overlay
                        .overlay(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.gray.opacity(0.45),
                                            Color.gray.opacity(0.10),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .blendMode(.overlay) // Blends cleanly into base slice colors
                                .allowsHitTesting(false)
                        )
                        // 🌟 Rim Light / Border Glow
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.6), Color.clear, Color.white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                                .allowsHitTesting(false)
                        )
                }
 
                ForEach(slices) { slice in
                    let sweepDegrees = slice.endAngle.degrees - slice.startAngle.degrees
                    if sweepDegrees >= minSweepForIcon {
                        let midAngle = Angle.degrees(
                            (slice.startAngle.degrees + slice.endAngle.degrees) / 2 - 90
                        )
                        let x = radius + iconRadius * CGFloat(cos(midAngle.radians))
                        let y = radius + iconRadius * CGFloat(sin(midAngle.radians))
 
                        Image(systemName: slice.icon)
                            .font(.system(size: max(12, size * 0.06), weight: .semibold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.25), radius: 1, x: 0, y: 1)
                            .position(x: x, y: y)
                    }
                }
            }
            .frame(width: size, height: size)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Routine Summary (the "attached screenshot" screen)

struct RoutineSummaryView: View {
    let routine: Routine
    @ObservedObject var router: AppRouter
    @State private var expandedTasks: Set<String> = []
    
    @State private var legendPage = 0
    @State private var isTapped: Bool = false

    // Cycle through these colors in order, same order the tasks are stored.
    private let palette: [Color] = [
        Color(red: 0.10, green: 0.45, blue: 0.45), // dark teal
        Color(red: 0.55, green: 0.78, blue: 0.90), // light blue
        Color(red: 0.35, green: 0.75, blue: 0.45), // green
        Color(red: 0.95, green: 0.75, blue: 0.30), // yellow
        Color(red: 0.95, green: 0.60, blue: 0.25), // orange

        Color(red: 0.75, green: 0.40, blue: 0.55), // rose
        Color(red: 0.60, green: 0.50, blue: 0.80), // lavender
        Color(red: 0.30, green: 0.50, blue: 0.70), // steel blue
        Color(red: 0.20, green: 0.30, blue: 0.45), // deep navy
        Color(red: 0.80, green: 0.40, blue: 0.20)  // terra cotta
    ]
    
    // Cycles in lockstep with `palette` — index i's icon always pairs with index i's color.
    private let iconPalette: [String] = [
        "book.fill",
        "figure.walk",
        "leaf.fill",
        "cup.and.saucer.fill",
        "flame.fill",
        "heart.fill",
        "moon.stars.fill",
        "drop.fill",
        "pencil",
        "sun.max.fill"
    ]

    private var totalMinutes: Int {
        routine.routines.reduce(0) { $0 + $1.minutes }
    }

    var body: some View {
        ZStack{
            AppTheme.backgroundGradient.ignoresSafeArea()
            
            
            VStack(alignment: .center ,spacing: 0) {
                // MARK: Top Bar
                
                HeaderView()
                
                ScrollView(.vertical, showsIndicators: false) {
                    Text("THE 1-HOUR ROUTINE")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: Color.black.opacity(0.4), radius: 2, x: 0, y: 1)
                    
                    PieChartView(tasks: routine.sortedTasks, colors: palette, icons: iconPalette)
                        .padding(.horizontal, 32)
                        .shadow(color: Color.black.opacity(0.3), radius: 3, x: 1, y: 1)
                        .shadow(color: Color.black.opacity(0.3), radius: 3, x: -1, y: -1)
                    
                    legend
                }
                .frame(maxWidth: .infinity)
                .padding()
                
                VStack {
                    Button {
                        router.navigateTo(.editRoutine(routine: routine))
                    } label: {
                        Text("Edit Routine")
                            .frame(maxWidth: .infinity)
                        
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.backgroundGradient)
                    .controlSize(.regular)
                    .modifier(AppButtonModifiler())
                    
                    Button {
                        router.navigateTo(.routineSession(routine: routine))
                    } label: {
                        Text("Start Routine")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.backgroundGradient)
                    .controlSize(.regular)
                    .modifier(AppButtonModifiler())

                }.padding()

                Spacer().frame(height: 10)
                
            }//.padding()

        }
    }
    private var legend: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
            ForEach(Array(routine.sortedTasks.enumerated()), id: \.offset) { index, task in
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        
                        if task.doneToday {
                            Text("Done")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white.opacity(1))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(task.icon.color.opacity(1), in: Capsule())
                        }
                        
                        Image(systemName: task.icon.systemName)
                            .foregroundStyle(task.icon.color)
                        Text("\(task.minutes) mins")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .italic()
                            .foregroundStyle(task.icon.color)
                    }

                    let description = task.routine_description
                    let isLong = description.count > 30
                    let isExpanded = expandedTasks.contains(description)

                    Text(
                        isLong && !isExpanded
                        ? String(description.prefix(30)) + "…"  // truncated
                        : description
                    )
                    .font(.system(.subheadline, design: .rounded))
                    .italic()
                    .foregroundStyle(.primary)
                    .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)

                    if isLong {
                        Button {
                            if isExpanded {
                                expandedTasks.remove(description)
                            } else {
                                expandedTasks.insert(description)
                            }
                        } label: {
                            Text(isExpanded ? "Show less" : "Show more")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        var result: [[Element]] = []
        var index = 0
        while index < count {
            let chunk = Array(self[index..<Swift.min(index + size, count)])
            result.append(chunk)
            index += size
        }
        return result
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
    
    
/*
 let defaultPaletteHexes = [
             "#1A7373", // dark teal
             "#8CC7E6", // light blue
             "#59BF73", // green
             "#F2BF4D", // yellow
             "#F29940", // orange
             "#BF668C", // rose
             "#9980CC", // lavender
             "#4D80B2", // steel blue
             "#334D73", // deep navy
             "#CC6633"  // terra cotta
         ]
 
 let defaultIconPalettes: [String] = [
     "book.fill",
     "figure.walk",
     "leaf.fill",
     "cup.and.saucer.fill",
     "flame.fill",
     "heart.fill",
     "moon.stars.fill",
     "drop.fill",
     "pencil",
     "sun.max.fill"
 ]
 
 */
    
    let sampleTasks: [RTask] = [
        RTask(minutes: 10, routine_description: "Read a book Read a book Read a book Read a book Read a book Read a book Read a book Read a book Read a book ",icon: ActionIcon(systemName: "book.fill", hexCode: "#CC6633")),
                                 RTask(minutes: 10, routine_description: "Exercise your muscle1 aaaaaaaa dddddd ffffff   ddwdwwqrqrqdrwqrv3q fewnrew;uo griowf;ntfeia grientferuisof fheionferi", icon: ActionIcon(systemName: "book.fill", hexCode: "#8CC7E6")),
                                 
                                 RTask(minutes: 10, routine_description: "Exercise your muscle2", doneToday: true, icon: ActionIcon(systemName: "figure.walk", hexCode: "#334D73")),
                                 
                                 RTask(minutes: 10, routine_description: "Exercise your muscle3", doneToday: true, icon: ActionIcon(systemName: "book.fill", hexCode: "#F29940")),
                                 
                                 RTask(minutes: 10, routine_description: "Exercise your muscl4", doneToday: true, icon: ActionIcon(systemName: "book.fill", hexCode: "#9980CC")),
                                 
//                                 RTask(minutes: 10, routine_description: "Exercise your muscle4"),
//                                 
//                                 RTask(minutes: 10, routine_description: "Exercise your muscle5"),
//                                 
//                                 RTask(minutes: 10, routine_description: "Exercise your muscle6"),
//                                 
//                                 RTask(minutes: 10, routine_description: "Exercise your muscle7"),
//                                 RTask(minutes: 10, routine_description: "Exercise your muscle8"),
                                 
    ]
    
    let sampleRoutine = Routine(routines: sampleTasks)
    
    
    
    RoutineSummaryView(routine: sampleRoutine, router: appRouter).modelContainer(container)
}
