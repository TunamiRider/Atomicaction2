//
//  ContentView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/14/26.
//

import SwiftUI

struct ContentView: View {
    @State private var title = ""


    @State private var minutes : Int = 1
    // MARK: - State (put these with your other @State vars)
    @State private var descriptionMode: DescriptionMode = .plain
    @State private var description: String = ""
    @State private var steps: [String] = [""]
    
    @State private var isTapped: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var isTitleFocused: Bool
    @FocusState private var isDescriptionFocused: Bool
    @FocusState private var isStepsFocused: Bool
    
//    @State private var today = Date()
//    
//    private let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
//    
//    private func isToday(day: String) -> Bool {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "EEE"
//        return day == formatter.string(from: today)
//    }
    
    var body: some View {
        NavigationStack {
        ZStack() {//alignment: .bottom
            AppTheme.backgroundGradient.ignoresSafeArea(.all)
            
            VStack(spacing: 20) {
                // MARK: Top Bar
                HeaderView()

                // MARK: Title
                fieldSection(label: "Task") {
                    ZStack(alignment: .topLeading) {
                        if title.isEmpty {
                            Text("Name this bubble...")
                                .font(.system(size: 15))
                                .foregroundStyle(.black)
                                .padding(.top, 12)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                        TextEditor(text: Binding(
                            get: { title },
                            set: { title = String($0.prefix(30))}
                        ))
                        .focused($isTitleFocused)
                        .font(.system(size: 15))
                        .foregroundStyle(.black)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 44, maxHeight: 44)
                        .tint(.black)

                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.9))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.55), lineWidth: 1.5)
                            )
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: 1, x: 0, y: 0)
    
                }
                
                // MARK: Description
                fieldSection(label: "Description") {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // Mode switcher
                        Picker("Description Mode", selection: $descriptionMode) {
                            ForEach(DescriptionMode.allCases, id: \.self) { mode in
                                if mode != .routine {
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 14)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        
                        // Boundary divider
                        Divider()
                            .background(Color.black.opacity(0.15))
                        
                        // Content area
                        Group {
                            if descriptionMode == .plain {
                                
                                plainDescriptionEditor
                            } else {
                                stepsEditor
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 90, maxHeight: 280, alignment: .topLeading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.9))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.55), lineWidth: 1.5)
                            )
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 0)
                }
                
                // MARK:  Duration
                fieldSection(label: "Duration") {
                    DurationPicker(minutes: $minutes, isRunning:false)
                        .frame(maxWidth: .infinity, minHeight: 36, alignment: .center)
                }
                
                Spacer()
                // MARK: Start
                Button {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        isTapped = true
                    }
                } label: {
                    Text("Start")
                        .frame(maxWidth: .infinity, alignment: .center)

                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.backgroundGradient)
                .controlSize(.regular)
                .disabled(!isStart())
                .animation(.easeInOut(duration: 0.2), value: title.isEmpty)
                .navigationDestination(isPresented: $isTapped) {
                    SeaSaltTimer(title: $title, description: $description, minutes: $minutes, descriptionMode: $descriptionMode, steps: $steps)
                        //.toolbar(.hidden, for: .tabBar)
                        .toolbar(isTapped ? .hidden : .visible, for: .tabBar)
                        .toolbarColorScheme(.dark, for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                }
                .modifier(AppButtonModifiler())
            
                Spacer().frame(height: 10)
                
            }
            .contentShape(Rectangle()) // makes empty space tappable too
            .onTapGesture {
                isDescriptionFocused = false
                isTitleFocused = false
                isStepsFocused = false
            }
            .padding(.horizontal, 20)
            .animation(.easeInOut(duration: 0.35), value: isTapped)
            
            Spacer().frame(height: 20)
        }}
    }
    
    private func isStart() -> Bool {
        if descriptionMode == .plain {
            return !title.isEmpty && !description.isEmpty
        }else {
            return !title.isEmpty && !steps.isEmpty && steps.allSatisfy {
                !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
        }
    }
    
    // MARK: - Plain text editor
    private var plainDescriptionEditor: some View {
        ZStack(alignment: .topLeading) {
            if description.isEmpty {
                Text("Write your description")
                    .font(.system(size: 15))
                    .foregroundStyle(.black)
                    .padding(.top, 12)
                    .padding(.leading, 4)
                    .allowsHitTesting(false)
                    .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 0)
            }
            TextEditor(text: Binding(
                get: { description },
                set: { description = String($0.prefix(300)) }
            ))
            .focused($isDescriptionFocused)
            .font(.system(size: 15))
            .foregroundStyle(.black)
            .scrollContentBackground(.hidden)
            .tint(.black)
            

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: - Step-by-step editor
    private var stepsEditor: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(steps.indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(.top, 2)

                        TextField("Step \(index + 1)", text: $steps[index], axis: .vertical)
                            .focused($isStepsFocused)
                            .font(.system(size: 14))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1...4)
                            .onChange(of: steps[index]) { oldValue, newValue in
                                if newValue.count > 120 {
                                    steps[index] = String(newValue.prefix(120))
                                }
                            }

                        if steps.count > 1 {
                            Button {
                                steps.remove(at: index)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red.opacity(0.7))
                            }
                        }
                    }
                }

                HStack {
                    Spacer()
                    Button {
                        steps.append("")
                    } label: {
                        Label("Add step", systemImage: "plus.circle.fill")
                            .font(.system(size: 14))
                            .tint(.black.opacity(0.6))
                    }
                    Spacer()
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    func wrapped(_ text: String, every limit: Int = 30) -> String {
        var result = ""
        var currentLineLength = 0

        for word in text.split(separator: " ", omittingEmptySubsequences: false) {
            let wordLength = word.count
            if currentLineLength + wordLength + (currentLineLength > 0 ? 1 : 0) > limit {
                result += "\n"
                currentLineLength = 0
            } else if currentLineLength > 0 {
                result += " "
                currentLineLength += 1
            }
            result += word
            currentLineLength += wordLength
        }
        return result
    }
    
    // MARK: - Helpers
    @ViewBuilder
    private func fieldSection<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.white.opacity(1))
                .kerning(1.4)
            content()
        }
    }
    
}

#Preview {
    ContentView()
}
