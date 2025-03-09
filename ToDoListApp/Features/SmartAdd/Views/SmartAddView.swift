//
//  SmartAddView.swift
//  ToDoListApp
//
//  Created by Dingze on 1/20/25.
//

import SwiftUI

struct SmartAddView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var userDataManager: UserDataManager
    @ObservedObject var viewModel = SmartAddViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    TextEditor(text: $viewModel.userInput)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.secondary, lineWidth: 0.3)
                        )

                    if viewModel.userInput.isEmpty {
                        VStack {
                            HStack {
                                Text("What do you need to get done?")
                                    .foregroundStyle(.placeholder)
                                    .padding(.top, 8)
                                    .padding(.leading, 5)

                                Spacer()
                            }

                            Spacer()
                        }
                    }
                }
                .padding(.top)
                .padding()
                
                HStack {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .frame(width: .infinity)
                    .buttonStyle(.borderedProminent)
                    
                    Button("Process Task") {
                        viewModel.processTask(in: userDataManager){
                            isPresented = false
                        }
                    }
                    .frame(width: .infinity)
                    .buttonStyle(.borderedProminent)
                }
                
                //Spacer()
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Input Error"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

#Preview {
    SmartAddView(isPresented: .constant(true))
}
