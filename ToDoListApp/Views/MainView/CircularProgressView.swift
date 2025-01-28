//
//  CircularProgressView.swift
//  ToDoListApp
//
//  Created by Dingze on 1/25/25.
//

import SwiftUI

struct CircularProgressView: View {
    @Binding var filter: FilterType
    
    @Environment(\.colorScheme) var colorScheme
    
    var percent: Double

    @State private var animatedPercent: Double = 0.0
    
    var body: some View {
        let percentText = String(format: "%.0f%%", animatedPercent * 100)
        HStack {
            ZStack {
                Circle()
                    .stroke(.accent.secondary, lineWidth: 7)
                    .overlay(
                        Text(percentText)
                            .contentTransition(.numericText(value: percent))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    )
                Circle()
                    .trim(from: 0.0, to: percent > 0 && percent <= 1 ? CGFloat(percent) : 0.01)
                    .stroke(.accent, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.appDefault, value: percent)
            }
            .frame(width: 50, height: 50)
            .padding()
            
            Text("Tasks Completion Progress")
                .fontWeight(.bold)
            Spacer()
        }
        .frame(height: 80)
        .background(
            Color(uiColor: colorScheme == .light ? .systemBackground : .secondarySystemBackground)
        )
        .cornerRadius(100)
        .shadow(radius: 10, x: 0, y: 8)
        .onAppear {
            withAnimation(.appDefault) {
                animatedPercent = percent
            }
        }
        .onChange(of: percent) {
            withAnimation(.appDefault) {
                animatedPercent = percent
            }
        }
    }
}
