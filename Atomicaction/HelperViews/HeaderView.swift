//
//  HeaderView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/17/26.
//
import SwiftUI

struct HeaderView: View {
    @State private var today = Date()
    
    private let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    private func isToday(day: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return day == formatter.string(from: today)
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center, spacing: 4) {
                Text("Atomicaction")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    ForEach(days, id: \.self) {day in
                        Text(day.prefix(1))
                            .font(.system(size: 13, weight: isToday(day: day) ? .bold : .medium))
                            .foregroundColor(isToday(day: day) ? .white : .white.opacity(0.5))
                    }
                }
            }
        }
        .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 1)
    }
}
