//
//  MenuButton.swift
//  ToDoListApp
//
//  Created by Dingze on 1/25/25.
//

import SwiftUI

struct MenuButton: View {
    @Binding var filter: FilterType
    @Binding var showMenu: Bool
    
    @Namespace private var namespace
    
    var body: some View {
        Button(action: {
            withAnimation(.appDefault){
                showMenu.toggle()
            }
        }, label: {
            Image(systemName: "chevron.left")
                .foregroundStyle(.accent)
        })
    }
}
