//
//  ActionButtonsView.swift
//  ToDoListApp
//
//  Created by Dingze on 1/21/25.
//

import SwiftUI

struct ActionButtonsView: View {
    @Binding var showAddToDoPage: Bool
    @Binding var showGPTSheet: Bool
    @Binding var multiSelectMode: Bool
    @Binding var selection: [UUID]

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button {
                    showGPTSheet = true
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Smart Add")
                            .font(.headline)
                            .padding(.leading, 5)
                    }
                }
                .opacity(multiSelectMode ? 0 : 1)
                .padding(.leading, 30)
                .padding(.bottom, 40)
                .sheet(isPresented: $showGPTSheet) {
                    SmartAddView(isPresented: $showGPTSheet)
                        .presentationDetents([.fraction(0.3), .medium])
                        .presentationDragIndicator(.visible)
                }

                Spacer()

                Button {
                    showAddToDoPage = true
                } label: {
                    HStack {
                        Text("New Task")
                            .font(.headline)
                            .padding(.trailing, 5)
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
                .opacity(multiSelectMode ? 0 : 1)
                .padding(.trailing, 30)
                .padding(.bottom, 40)
                .sheet(isPresented: $showAddToDoPage) {
                    NavigationStack {
                        TaskDetailView()
                    }
                }
            }
            .padding(.trailing, 5)
        }
        .background(
            VStack {
                Spacer()
                if !multiSelectMode {
                    Rectangle()
                        .fill(Color.secondaryBackground)
                        .frame(height: 80)
                        .edgesIgnoringSafeArea(.bottom)
                        .transition(.opacity)
                        .cornerRadius(20)
                }
            }
        )
        .ignoresSafeArea(edges: .bottom)
    }
}
