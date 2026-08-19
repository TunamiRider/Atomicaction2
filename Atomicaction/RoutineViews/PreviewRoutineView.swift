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
            HStack {
                Button {
                    router.navigateTo(.createRoutine)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                            .circularIconStyle()
                    }
                }
                .clipShape(Circle())
                
                Spacer()
                Spacer()
            }
            .overlay{
                Spacer()
                Text("Preview Routine")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 16)
            List {
                Section(header: Text("Your 1-Hour Routine").foregroundStyle(AppTheme.textPrimary)) {
                    ForEach(tasks, id: \.routine_description) { task in
//                        HStack {
//                            // Uniform circular badge layout
//                            Image(systemName: task.icon.systemName)
//                                .font(.system(size: 18, weight: .semibold))
//                                .foregroundColor(.black)
//                                .frame(width: 40, height: 40) // Fixed frame aligns all icons vertically
//                                .background(
//                                    Circle()
//                                        .fill(task.icon.color.opacity(0.2))
//                                )
//                                .overlay(
//                                    Circle()
//                                        .stroke(task.icon.color, lineWidth: 2) // Fixed: Added hex initializer
//                                )
//                            
//                            Text(task.routine_description)
//                            Spacer()
//                            Text("\(task.minutes) min")
//                                .foregroundStyle(AppTheme.textSecondary)
//                        }
                        
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                // Uniform circular badge layout
                                Image(systemName: task.icon.systemName)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40) // Fixed frame aligns all icons vertically
                                    .background(
                                        Circle()
                                            .fill(task.icon.color.opacity(0.2))
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(task.icon.color, lineWidth: 2) // Fixed: Added hex initializer
                                    )
                                
                                Text(task.routine_description)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("\(task.minutes) min")
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                            
                            // 2. Custom Divider outside the Button
                            Rectangle()
                                .fill(Color.primary.opacity(0.15)) // Works in both Light and Dark mode
                                .frame(height: 1)
                        }
                        .padding(.vertical, 4)
                        .listRowSeparator(.hidden)
                        
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
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .alert("Routine saved!", isPresented: $didConfirm) {
            Button("OK") {
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
