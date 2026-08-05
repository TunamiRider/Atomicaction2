//
//  ShimmeringModifier.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/24/26.
//
import SwiftUI

struct ShimmeringModifier: ViewModifier {
    var isActive: Bool = true
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, Color.white.opacity(0.5), .clear],
                        startPoint: .leading, endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.5)
                    .offset(x: phase * geo.size.width * 1.5)
                    .blendMode(.screen)
                }
                .mask(content)
            )
            .opacity(isActive ? 1 : 0)
            .onAppear {
                guard isActive else { return }
                withAnimation(.linear(duration: 2.2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmering() -> some View {
        modifier(ShimmeringModifier()).mask(self)
    }
}
