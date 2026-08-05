//
//  TodayProgressView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/17/26.
//
//import SwiftUI
//import SwiftData
//struct TodayProgressView: View {
//    @Query private var days: [DailyProgress]
//
//    init() {
//        let start = Calendar.current.startOfDay(for: Date())
//        _days = Query(filter: #Predicate<DailyProgress> { $0.date == start })
//    }
//
//    var todayEntries: [TaskEntry] {
//        days.first?.entries ?? []
//    }
//
//    var body: some View {
//        List {
//            Text("Completed today: \(todayEntries.count)")
//            Text("Total minutes: \(todayEntries.reduce(0) { $0 + $1.minutes })")
//            ForEach(todayEntries, id: \.completedAt) { entry in
//                Text("\(entry.taskTitle) — \(entry.minutes) min at \(entry.completedAt.formatted(date: .omitted, time: .shortened))")
//            }
//        }
//    }
//}


import SwiftUI
import SwiftData
import Charts

struct TodayProgressView: View {
    @Query private var days: [DailyProgress]
    @Environment(\.modelContext) private var modelContext
    init() {
        let start = Calendar.current.startOfDay(for: Date())
        _days = Query(filter: #Predicate<DailyProgress> { $0.date == start })
    }

    var todayEntries: [TaskEntry] {
        days.first?.entries ?? []
    }

    // MARK: - Derived stats

    /// Total minutes spent per hour (0-23), for the bar chart.
    var hourlyBuckets: [(hour: Int, minutes: Int)] {
        var minutesByHour = Array(repeating: 0, count: 24)
        for entry in todayEntries {
            let hour = Calendar.current.component(.hour, from: entry.completedAt)
            minutesByHour[hour] += entry.minutes
        }
        return minutesByHour.enumerated().map { (hour: $0.offset, minutes: $0.element) }
    }

    /// The hour with the most minutes spent, formatted like "14:00".
    var mostActivePeriod: String {
        guard let busiest = hourlyBuckets.max(by: { $0.minutes < $1.minutes }),
              busiest.minutes > 0 else { return "--:--" }
        return String(format: "%02d:00", busiest.hour)
    }

    /// Average gap between consecutive completions today, in minutes.
    var averageBreakMinutes: Int {
        let sorted = todayEntries.sorted { $0.completedAt < $1.completedAt }
        guard sorted.count > 1 else { return 0 }

        let gaps: [TimeInterval] = zip(sorted, sorted.dropFirst()).map { first, second in
            second.completedAt.timeIntervalSince(first.completedAt)
        }
        let averageSeconds = gaps.reduce(0, +) / Double(gaps.count)
        return Int(averageSeconds / 60)
    }
    
    private func averageBreakMinutes2() -> Double {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<DailyBreak>(
            predicate: #Predicate { $0.date == startOfDay }
        )
        return (try? modelContext.fetch(descriptor))?.first?.averageBreakMinutes ?? 0.0
    }
    
    private func formattedDuration(minutes totalMinutes: Int) -> String {
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        switch (hours, minutes) {
        case (0, 0):
            return "0 min"
        case (0, _):
            return "\(minutes) min"
        case (_, 0):
            return hours == 1 ? "1 hour" : "\(hours) hours"
        default:
            let hourLabel = hours == 1 ? "1 hour" : "\(hours) hours"
            return "\(hourLabel) \(minutes) min"
        }
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea(.all)
            
            
            VStack(alignment: .center, spacing: 10) {
                HeaderView()
                Text("My Progress")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.4), radius: 1, x: 0, y: 1)
                
                VStack(alignment: .leading, spacing: 16) {
                    Label("Actions, today", systemImage: "clock")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(todayEntries.count)")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(.indigo)
                            Text("Actions Completed")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            //Text("\(todayEntries.reduce(0) { $0 + $1.minutes }) min")
                            Text(formattedDuration(minutes: todayEntries.reduce(0) { $0 + $1.minutes }))
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.green)
                            Text("Total time")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Chart(hourlyBuckets, id: \.hour) { bucket in
                        BarMark(
                            x: .value("Hour", Double(bucket.hour)+0.5),
                            y: .value("Minutes", bucket.minutes),
                            width: .fixed(8)
                        )
                        .foregroundStyle(bucket.minutes > 0 ? Color.indigo : Color.gray.opacity(0.2))
                        .cornerRadius(2)
                    }
                    .frame(height: 100)
                    .chartXScale(domain: 0...24)
                    .chartYScale(domain: 0...60)
                    .chartXAxis {
                        AxisMarks(values: [0, 3, 6, 9, 12, 15, 18, 21, 24]) { value in
                            AxisValueLabel {
                                if let hour = value.as(Int.self) {
                                    Text(String(format: "%02dh", hour))
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: [0, 30, 60])
//                        { value in
//                            AxisValueLabel {
//                                if let min = value.as(Int.self){
//                                    Text(String(format: "%02dh", min))
//                                }
//                            }
//                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(mostActivePeriod)
                                .font(.title3.bold())
                                .foregroundStyle(.indigo)
                            Text("Most active period")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(String(format: "%.1f", averageBreakMinutes2())) min")
                                .font(.title3.bold())
                                .foregroundStyle(.indigo)
                            Text("Average break")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Divider()
                    
//                    Button("See details") {
//                        // hook up navigation here
//                    }
//                    .font(.subheadline.weight(.medium))
//                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.4), radius: 1, x: 0, y: 1)
                
                
                
                WeeklyProgressView()
                Spacer().frame(height: 20)
            }
            .padding()
            
            
        }
    }
}
