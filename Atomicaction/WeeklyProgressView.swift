//
//  WeeklyProgressView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/17/26.
//

import SwiftUI
import SwiftData
import Charts

struct WeeklyProgressView: View {
    @Query private var days: [DailyProgress]

    init() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // Find the Monday that starts this week (adjust firstWeekday if your week starts Sunday)
        var cal = calendar
        cal.firstWeekday = 2 // Monday
        let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let weekEnd = cal.date(byAdding: .day, value: 7, to: weekStart)!

        _days = Query(
            filter: #Predicate<DailyProgress> { $0.date >= weekStart && $0.date < weekEnd },
            sort: \.date
        )
    }

    // MARK: - Derived stats

    private var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = 2
        return cal
    }

    private var weekStart: Date {
        calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
    }

    /// One bucket per weekday (Mon...Sun), with total minutes and whether it's today.
    struct DayBucket: Identifiable {
        let id = UUID()
        let date: Date
        let label: String
        let minutes: Int
        let isToday: Bool
        
        /// Minutes expressed as a 0-10 ratio of a full day (1440 minutes = 10).
        var dayRatio: Double {
            Double(minutes) / 1440.0 * 10.0
        }
        /// Ratio capped at 5 (i.e. 12 hours) so the bar never draws past the axis ceiling.
        var clampedRatio: Double {
            min(dayRatio, 5.0)
        }

        /// True if the actual value exceeds the 12-hour cap.
        var isOverflowing: Bool {
            dayRatio > 5.0
        }
    }

    var weeklyBuckets: [DayBucket] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // "Mon", "Tue", ...
        let today = calendar.startOfDay(for: Date())

        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: weekStart)!
            let progress = days.first { calendar.isDate($0.date, inSameDayAs: date) }
            let totalMinutes = progress?.entries.reduce(0) { $0 + $1.minutes } ?? 0

            return DayBucket(
                date: date,
                label: formatter.string(from: date),
                minutes: totalMinutes,
                isToday: calendar.isDate(date, inSameDayAs: today)
            )
        }
    }

    var totalActionsThisWeek: Int {
        days.reduce(0) { $0 + $1.entries.count }
    }

    var totalMinutesThisWeek: Int {
        days.reduce(0) { $0 + $1.entries.reduce(0) { $0 + $1.minutes } }
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
        VStack(alignment: .leading, spacing: 16) {
            Label("Actions, week", systemImage: "calendar")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(totalActionsThisWeek)")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.indigo)
                    Text("Actions week")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(formattedDuration(minutes: totalMinutesThisWeek))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.green)
                    Text("Total time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
//            Chart(weeklyBuckets) { bucket in
//                BarMark(
//                    x: .value("Day", bucket.label),
//                    y: .value("Day Ratio", bucket.dayRatio),
//                    width: .fixed(24)
//                )
//                .foregroundStyle(bucket.isToday ? Color.indigo : (bucket.minutes > 0 ? Color.orange : Color.gray.opacity(0.2)))
//                .cornerRadius(4)
//            }
//            .frame(height: 120)
//            .chartXAxis {
//                AxisMarks { value in
//                    AxisValueLabel {
//                        if let label = value.as(String.self) {
//                            let isToday = weeklyBuckets.first { $0.label == label }?.isToday ?? false
//                            Text(label)
//                                .foregroundStyle(isToday ? Color.indigo : Color.secondary)
//                                .fontWeight(isToday ? .bold : .regular)
//                        }
//                    }
//                }
//            }
//            .chartYScale(domain: 0...10)
//            .chartYAxis {
//                AxisMarks(position: .trailing, values: [0, 2.5, 5, 7.5, 10]) { value in
//                    AxisGridLine()
//                    AxisTick()
//                    AxisValueLabel {
//                        if let ratio = value.as(Double.self) {
//                            let hours = ratio * 2.4
//                            Text("\(Int(hours))h")
//                        }
//                    }
//                }
//            }
            Chart(weeklyBuckets) { bucket in
                BarMark(
                    x: .value("Day", bucket.label),
                    y: .value("Day Ratio", bucket.clampedRatio),
                    width: .fixed(24)
                )
                .foregroundStyle(/*bucket.isToday ? Color.indigo :*/ (        bucket.dayRatio > 4 ? .green :
                                                                            bucket.dayRatio > 3  ? .mint   :
                                                                            bucket.dayRatio > 2  ? .teal  :
                                                                            bucket.dayRatio > 1  ? .yellow :
                                                                            bucket.dayRatio > 0  ? .orange :
                                                                                                  Color.gray.opacity(0.2)))
                .cornerRadius(4)
                .annotation(position: .top) {
                    if bucket.isOverflowing {
                        Text("+")
                            .font(.caption.bold())
                            .foregroundStyle(.green)
                    }
                }
            }
            .frame(height: 120)
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let label = value.as(String.self) {
                            let isToday = weeklyBuckets.first { $0.label == label }?.isToday ?? false
                            Text(label)
                                .foregroundStyle(isToday ? Color.black.opacity(0.6) : Color.secondary)
                                .fontWeight(isToday ? .bold : .regular)
                        }
                    }
                }
            }
            .chartYScale(domain: 0...5)
            .chartYAxis {
                AxisMarks(position: .trailing, values: [0, 1.25, 2.5, 3.75, 5]) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let ratio = value.as(Double.self) {
                            let hours = ratio * 2.4
                            Text("\(Int(hours))h")
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity) 
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.4), radius: 1, x: 0, y: 1)
    }
}
