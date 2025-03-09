//
//  MultiSelectButton.swift
//  ToDoListApp
//
//  Created by Dingze on 1/25/25.
//

import SwiftUI

struct MultiSelectButton: View {
    @Binding var multiSelectMode: Bool
    @Binding var selection: [UUID]
    
    var body: some View {
        Button {
            withAnimation(.appDefault){
                multiSelectMode.toggle()
            }
            selection.removeAll()
        } label: {
            Image(systemName: "slider.horizontal.3")
                .foregroundStyle(.accent)
        }
    }
}
