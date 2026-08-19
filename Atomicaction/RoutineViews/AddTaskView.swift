//
//  AddTaskView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/21/26.
//

import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<ActionIcon>{ $0.isSelected == false }) private var actionIcons: [ActionIcon]
    
    let remainingMinutes: Int
    var onAdd: (RTask) -> Void

    @State private var description = ""
    @State private var minutes = AppConstants.initialRoutineDuration
    @State private var selectedActionIcon: ActionIcon = ActionIcon(systemName: "book.fill", hexCode: "#1A7373")
    
    private let columns = [GridItem(.adaptive(minimum: 60), spacing: 10)]
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea(.all)
            NavigationStack {
                Form {
                    Section(header: Text("Task").foregroundStyle(.white)) {
                        TextField("Description", text: $description, axis: .vertical)
                            .onChange(of: description) { oldValue, newValue in
                                if newValue.count > 60 {
                                    description = String(newValue.prefix(60))
                                }
                            }
                            .foregroundStyle(.black)
                            .tint(.black)
                        Stepper("Minutes: \(minutes)",value: $minutes,in: AppConstants.initialRoutineDuration...max(AppConstants.initialRoutineDuration, remainingMinutes),step: AppConstants.stepRoutineDuration)
                        
                        
                        
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(actionIcons, id: \.self){ icon in
                                CircleIcon(
                                            actionIcon: icon,
                                            isSelected: selectedActionIcon.systemName == icon.systemName
                                        ) {
                                            selectedActionIcon = icon
                                        }
                            }
                        }

                    }
                    .listRowBackground(Color.white)     // Forces the row card background to white
                    //.environment(\.colorScheme, .light)
                    

                    if remainingMinutes <= 0 {
                        Text("You've already reached \(AppConstants.totalRoutineMinutes) minutes.")
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
                        .controlSize(.regular)
                        .foregroundColor(.white)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            //let dummy = ActionIcon(systemName: "book.fill")
                            let task = RTask(minutes: minutes, routine_description: description, icon: selectedActionIcon)
                            
                            
                            selectedActionIcon.isSelected = true
                            try? modelContext.save()
                            
                            onAdd(task)
                            dismiss()
                        }
                        .controlSize(.regular)
                        .foregroundColor((description.trimmingCharacters(in: .whitespaces).isEmpty || minutes > remainingMinutes) ?  .white.opacity(0.25) : .white)
                        .disabled(description.trimmingCharacters(in: .whitespaces).isEmpty || minutes > remainingMinutes)
                    }
                }
            }
        }
        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
        .task{
            IconDataHelper.seedIconDataIfNeeded(in: modelContext)
            
            selectedActionIcon = actionIcons.first ?? ActionIcon(systemName: "book.fill", hexCode: "#1A7373")
        }
    }
    
    private struct CircleIcon: View {
        let actionIcon: ActionIcon
        let isSelected: Bool
        let onTap: () -> Void
        
        var body: some View {
            Image(systemName: actionIcon.systemName)
                .font(.system(size: 22))
                .foregroundColor(.white)
                .opacity(isSelected ? 1.0 : 0.4)
                .padding(10)
                .background(
                    Circle()
                        .fill(isSelected ? actionIcon.color.opacity(0.2) : Color.gray.opacity(1.0))
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? actionIcon.color : Color.gray.opacity(1.0), lineWidth: 2)
                )
                .onTapGesture(perform: onTap)
        }
    }
}
