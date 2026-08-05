//
//  CreateRoutineView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/21/26.
//

import SwiftUI
import SwiftData

struct CreateRoutineView: View {
    @ObservedObject var router: AppRouter
    
    @State private var tasks: [RTask] = []
    @State private var isPresentingAddTask = false
    
    private let maxTasks = 10

    private var totalMinutes: Int {
        tasks.reduce(0) { $0 + $1.minutes }
    }

    private var isReadyToPreview: Bool {
        totalMinutes == AppConstants.totalRoutineMinutes
    }

    private var hasReachedTaskLimit: Bool {
        tasks.count >= maxTasks
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea(.all)
            VStack(spacing: 0) {
                List {
                    Section {
                        ForEach(tasks, id: \.routine_description) { task in
                            HStack {
                                Text(task.routine_description)
                                Spacer()
                                Text("\(task.minutes) min")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete { indexSet in
                            tasks.remove(atOffsets: indexSet)
                        }
                    } header: {
                        HStack {
                            Text("Tasks (\(tasks.count)/\(maxTasks))")
                            Spacer()
                            Text("\(totalMinutes) / \(AppConstants.totalRoutineMinutes) min")
                                .foregroundStyle(totalMinutes == 60 ? .green : .secondary)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .scrollContentBackground(.hidden)   // 👈 hides List's own background
                .background(AppTheme.backgroundGradient.ignoresSafeArea())
                
                VStack(spacing: 12) {
                    Button {
                        isPresentingAddTask = true
                    } label: {
                        Label(
                            hasReachedTaskLimit ? (!isReadyToPreview ? "Max tasks reached, but not at \(AppConstants.totalRoutineMinutes) min yet":"Task limit reached (\(maxTasks))") : "Add a routine",
                            systemImage: "plus.circle.fill"
                        ).frame(maxWidth: .infinity)
                    }
//                    .buttonStyle(.bordered)
//                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(AppTheme.backgroundGradient)
                    .disabled(hasReachedTaskLimit)
                    .modifier(AppButtonModifiler())
                    
//                    NavigationLink {
//                        PreviewRoutineView(tasks: tasks, path: $path).border(Color.black)
//                    } label: {
//                        Text("Preview")
//                            .frame(maxWidth: .infinity)
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .controlSize(.large)
//                    .tint(AppTheme.backgroundGradient)
//                    .disabled(!isReadyToPreview)
                    Button {
                        router.goToPreview(tasks: tasks)
                    } label: {
                        Text("Preview")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(AppTheme.backgroundGradient)
                    .disabled(!isReadyToPreview)
                    .modifier(AppButtonModifiler())
                }
                .padding()
                
            }
            .navigationTitle("Create routines")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)   // 👈 hide default back
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        router.goToRoutineHome()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.backward")
                        }
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddTask) {
                AddTaskView(remainingMinutes: AppConstants.totalRoutineMinutes - totalMinutes) { newTask in
                    tasks.append(newTask)
                }
            }
            
        }
    }
}
