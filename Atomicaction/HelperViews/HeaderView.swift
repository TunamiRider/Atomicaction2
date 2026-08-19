//
//  HeaderView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/17/26.
//
import SwiftUI

struct HeaderView: View {
    @State private var today = Date()
    @State private var showSettingsSheet = false
    private let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    private func isToday(day: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return day == formatter.string(from: today)
    }
    
    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                VStack(alignment: .center, spacing: 0) {
                    HStack(spacing: 16) {
                        
                        Text("Atomicaction")
                            .font(.system(size: 34, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .overlay(alignment: .trailing) {
                                        Button {
                                            showSettingsSheet = true
                                        } label: {
                                            Image(systemName: "gearshape.fill")
                                                .font(.system(size: 22, weight: .medium))
                                                .foregroundStyle(.white)
                                        }
                                        .alignmentGuide(.trailing) { d in d[.leading] - 12 } // Offsets button to the right of the text
                                    }
                        
//                        Button {
//                            showSettingsSheet = true
//                        } label: {
//                            Image(systemName: "gearshape.fill")
//                                .font(.system(size: 22, weight: .medium)) // Matches ~34pt title height alignment
//                                .foregroundStyle(.white)
//                        }
                        
                        

                    }
                    //.frame(maxWidth: .infinity)
//                    .overlay(alignment: .trailing){
//                        Button {
//                            showSettingsSheet = true
//                        } label: {
//                            Image(systemName: "gearshape.fill")
//                                .font(.system(size: 22, weight: .medium)) // Matches ~34pt title height alignment
//                                .foregroundStyle(.white)
//                        }
//                    }
                    
                    HStack(spacing: 12) {
                        ForEach(days, id: \.self) {day in
                            Text(day.prefix(1))
                                .font(.system(size: 13, weight: isToday(day: day) ? .bold : .medium))
                                .foregroundColor(isToday(day: day) ? .white : .white.opacity(0.5))
                        }
                    }
//                    HStack {
//
//                        TimelineView(.periodic(from: .now, by: 1.0)) { context in
//                            let dateString = context.date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
//                            let timeString = context.date.formatted(date: .omitted, time: .shortened)
//                            
//                            
//                            HStack(spacing: 8) {
//                                Image(systemName: "calendar")
//                                    .font(.system(size: 13, weight: .medium))
//                                
//                                Text("\(dateString) ")
//                                    .font(.system(size: 14, weight: .medium, design: .rounded))
//                                
//                                
//                                
//                                Image(systemName: "clock.fill") // or "bell.fill" / "alarm.fill"
//                                    .font(.system(size: 13, weight: .medium))
//                                
//                                Text(timeString)
//                                    .font(.system(size: 14, weight: .medium, design: .rounded))
//                                
//                                Spacer().frame(width: 30)
//                            }
//                            .foregroundColor(.white.opacity(1.0))
//                            
//                            
//                            //                        Text("\(dateString) at \(timeString)")
//                            //                            .font(.system(size: 14, weight: .semibold, design: .serif))
//                            //                            .foregroundColor(.white.opacity(1.0))
//                            //                            .frame(height: 34) // Keeps baseline aligned with 34pt title
//                        }
//                    }
                    
                }
                //.padding(.horizontal)
                .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 1)
            }
            .sheet(isPresented: $showSettingsSheet){
                SettingsView()
                    .presentationDetents([.large, .medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
}
