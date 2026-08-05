//
//  PreviewRoutineView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/21/26.
//

import SwiftUI
import SwiftData

struct PreviewRoutineView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var router: AppRouter

    let tasks: [RTask]
    @State private var didConfirm = false

    private var totalMinutes: Int {
        tasks.reduce(0) { $0 + $1.minutes }
    }

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section("Your 1-Hour Routine") {
                    ForEach(tasks, id: \.routine_description) { task in
                        HStack {
                            Text(task.routine_description)
                            Spacer()
                            Text("\(task.minutes) min")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Section {
                    HStack {
                        Text("Total")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(totalMinutes) min")
                            .fontWeight(.semibold)
                    }
                }
            }
            .scrollContentBackground(.hidden)   // 👈 hides List's own background

            Button {
                confirmRoutine()
            } label: {
                Text("Confirm")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(AppTheme.backgroundGradient)
            .modifier(AppButtonModifiler())
            .padding()
        }
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden(true)   // 👈 hide default back
        .background(AppTheme.backgroundGradient.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    router.goToCreateRoutine()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                    }
                }
            }
        }
        .alert("Routine saved!", isPresented: $didConfirm) {
            Button("OK") {
                // Pop back to the home screen
                
                
                //dismiss()
                router.goToRoutineHome()
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(AppTheme.backgroundGradient)
            .modifier(AppButtonModifiler())
        }
    }

    private func confirmRoutine() {
        
        for (index, task) in tasks.enumerated(){
            task.order = index
        }
        let routine = Routine(routines: tasks)
        modelContext.insert(routine)
        didConfirm = true
    }
}
