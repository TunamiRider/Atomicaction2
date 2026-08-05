//
//  VerticalDurationPicker.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/14/26.
//

import SwiftUI

struct VerticalDurationPicker: View {
    @Binding var minutes: Int
    let steps: [Int] = Array(stride(from: 30, through: 90, by: 30))
    private let driftwood = Color(red: 0.55, green: 0.50, blue: 0.43)
    @State private var showPicker: Bool = false

    var body: some View {
        Button(action: { showPicker = true }) {
            Text("\(minutes) min")
                .foregroundColor(driftwood)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(driftwood.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(driftwood.opacity(1), lineWidth: 1)
                        )
                )
        }
        .sheet(isPresented: $showPicker) {
            VStack {
                Picker("Duration", selection: $minutes) {
                    ForEach(steps, id: \.self) { step in
                        Text("\(step) min").tag(step)
                    }
                }
                .pickerStyle(.wheel)
                .padding()
                .simultaneousGesture(
                    TapGesture().onEnded {
                        showPicker = false
                    }
                )
            }
            .presentationDetents([.medium])
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(1))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(driftwood.opacity(0.12), lineWidth: 0.8)
                )
        )
    }
}


#Preview {
    @Previewable @State var minutes: Int = 30
    @Previewable @State var isRunning = false
    VerticalDurationPicker(minutes: $minutes).border(Color.red)
        //.background(Color.black).border(Color.red)
}
