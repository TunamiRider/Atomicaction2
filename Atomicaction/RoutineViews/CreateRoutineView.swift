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
    
    @State private var selectedTask: RTask?
    
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
                HStack {
                    Button {
                        router.navigateTo(.routineHome)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.backward")
                                .circularIconStyle()
//                                .renderingMode(.template)
//                                .font(.system(size: 14, weight: .semibold))
//                                .foregroundStyle(.white)
//                                .frame(width: 28, height: 28)
//                                .background(AppTheme.backgroundGradient)
//                                .clipShape(Circle())
//                                .overlay(
//                                    Circle()
//                                        .stroke(Color.white.opacity(0.8), lineWidth: 1)
//                                )
//                                .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                            
                        }
                    }
                    .clipShape(Circle())
                    
                    Spacer()
                    Spacer()
                }
                .overlay{
                    Spacer()
                    Text("Create Routine")
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
                    Section {
                        ForEach(tasks, id: \.routine_description) { task in
                            
                            
                            VStack(alignment: .leading, spacing: 12) {
                                // 1. The Button only wraps the row content
                                Button {
                                    selectedTask = task
                                } label: {
                                    HStack(spacing: 12) {
                                        // Uniform circular badge layout
                                        Image(systemName: task.icon.systemName)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(width: 40, height: 40)
                                            .background(
                                                Circle()
                                                    .fill(task.icon.color.opacity(0.2))
                                            )
                                            .overlay(
                                                Circle()
                                                    .stroke(task.icon.color, lineWidth: 2)
                                            )
                                        
                                        Text(task.routine_description)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Text("\(task.minutes) min")
                                            .foregroundStyle(AppTheme.textSecondary)
                                        
                                        Image(systemName: "pencil")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(.black.opacity(1.0))
                                    }
                                }
                                .buttonStyle(.plain)
                                
                                // 2. Custom Divider outside the Button
                                Rectangle()
                                    .fill(Color.primary.opacity(0.15)) // Works in both Light and Dark mode
                                    .frame(height: 1)
                            }
                            .padding(.vertical, 4)
                            .listRowSeparator(.hidden)


//                            HStack {
//                                
//                                Image(systemName: task.icon.systemName)
//                                    .font(.system(size: 22))
//                                    .foregroundColor(.black)
//                                    .padding(10)
//                                    .background(
//                                        Circle()
//                                            .fill( Color(hex: task.icon.hexCode).opacity(0.2))
//                                    )
//                                    .overlay(
//                                        Circle()
//                                            .stroke(Color(task.icon.hexCode), lineWidth: 2)
//                                    )
//                                
//                                Text(task.routine_description)
//                                Spacer()
//                                Text("\(task.minutes) min")
//                                    .foregroundStyle(AppTheme.textSecondary)
//                            }
                        }
                        .onDelete { indexSet in
                            tasks.remove(atOffsets: indexSet)
                        }
                    } header: {
                        HStack {
                            Text("Tasks (\(tasks.count)/\(maxTasks))")
                                .foregroundStyle(totalMinutes == AppConstants.totalRoutineMinutes ? .green : AppTheme.textSecondary)
                            Spacer()
                            Text("\(totalMinutes) / \(AppConstants.totalRoutineMinutes) min")
                                .foregroundStyle(totalMinutes == AppConstants.totalRoutineMinutes ? .green : AppTheme.textSecondary)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .sheet(item: $selectedTask) { task in
                    NavigationStack {
                        EditTaskView(task: task, remainingMinutes: totalMinutes)
                    }
                }
                .scrollContentBackground(.hidden)
                
                

                VStack(spacing: 12) {
                    Button {
                        isPresentingAddTask = true
                    } label: {
                        Label(
                            hasReachedTaskLimit ? (!isReadyToPreview ? "Max tasks reached, but not at \(AppConstants.totalRoutineMinutes) min yet":"Task limit reached (\(maxTasks))") : "Add a routine",
                            systemImage: "plus.circle.fill"
                        ).frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(AppTheme.backgroundGradient)
                    .disabled(hasReachedTaskLimit)
                    .modifier(AppButtonModifiler())
                    
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
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $isPresentingAddTask) {
                AddTaskView(remainingMinutes: AppConstants.totalRoutineMinutes - totalMinutes) { newTask in
                    tasks.append(newTask)
                }
            }
            
        }
    }
}
