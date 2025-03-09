//
//  TaskHighlightsView.swift
//  ToDoListApp
//
//  Created by Dingze on 1/21/25.
//

import SwiftUI

struct TaskHighlightsView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @ObservedObject var highlightsManager: TaskHighlightsManager
    
    @State private var isLoading: Bool = false
    @State private var hasAppeared: Bool = false
    @State private var isExpanded: Bool = true
        
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "staroflife.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .foregroundStyle(.accent)

                Text("Highlights")
                    .font(.headline)
                    .bold()
                
                Button(action: {
                    withAnimation(.appDefault) {
                        isExpanded.toggle()
                    }
                }) {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                        .foregroundStyle(.accent)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }
            .padding(.horizontal)
            
            if isExpanded {
                ScrollView {
                    Text(highlightsManager.highlights ?? "Loading Highlights...")
                        .font(.body)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .padding()
                }
                .frame(maxHeight: 105)
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(13)
                .padding(.horizontal)
            }
        }
        .task {
            if !hasAppeared {
                hasAppeared = true
                isLoading = true
                await highlightsManager.loadAIHighlights(from: userDataManager.ToDoList)
                isLoading = false
            }
        }
    }
}
