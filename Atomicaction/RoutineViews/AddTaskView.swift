//
//  AddTaskView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/21/26.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss

    let remainingMinutes: Int
    var onAdd: (RTask) -> Void

    @State private var description = ""
    @State private var minutes = AppConstants.routineDuration

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea(.all)
            NavigationStack {
                Form {
                    Section("Task") {
                        TextField("Description", text: $description)
                            .onChange(of: description) { oldValue, newValue in
                                if newValue.count > 60 {
                                    description = String(newValue.prefix(60))
                                }
                            }
                        Stepper("Minutes: \(minutes)",value: $minutes,in: AppConstants.routineDuration...max(AppConstants.routineDuration, remainingMinutes),step: AppConstants.routineDuration)
                    }
                    if remainingMinutes <= 0 {
                        Text("You've already reached 60 minutes.")
                            .foregroundStyle(.red)
                    }
                }
                .scrollContentBackground(.hidden)   // 👈 tells Form to stop drawing its own background
                .background(AppTheme.backgroundGradient.ignoresSafeArea())
                .navigationTitle("Add a routine")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                        //.buttonStyle(.borderedProminent)
                        //.tint(AppTheme.backgroundGradient)
                        .controlSize(.regular)
                        .foregroundColor(.black.opacity(0.8))
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            let task = RTask(minutes: minutes, routine_description: description)
                            onAdd(task)
                            dismiss()
                        }
                        //.buttonStyle(.borderedProminent)
                        //.tint(AppTheme.backgroundGradient)
                        .controlSize(.regular)
                        .foregroundColor((description.trimmingCharacters(in: .whitespaces).isEmpty || minutes > remainingMinutes) ?  .black.opacity(0.25) : .black.opacity(0.6))
                        .disabled(description.trimmingCharacters(in: .whitespaces).isEmpty || minutes > remainingMinutes)
                    }
                }
            }
        }.shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}
