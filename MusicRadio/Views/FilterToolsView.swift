//
//  FilterToolsView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/06.
//
import SwiftUI
import SwiftData


struct FilterToolsView: View {
    @Environment(Selector.self) var selector
    
    
    var body: some View {
        @Bindable var selector = selector
        VStack {
            HStack {
                Picker("", selection: $selector.filter) {
                    ForEach(FilterTypes.allCases) { tool in
                        Text(tool.rawValue).tag(tool)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                Spacer()
            }
            
//            HStack {
//                ForEach(FilterTypes.allCases) { selection in
//                    HStack {
//                        Button {
//                            selectedTool = selection
//                        } label: {
//                            HStack {
//                                Image(systemName: selectedTool == selection ? "largecircle.fill.circle" : "circle")
//                                    .foregroundColor(.accentColor)
//                                Text(selection.rawValue)
//                            }
//                        }
//                        .buttonStyle(.plain)
//                    }
//                }
//            }
            
            .padding(4)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 2)
        }
    }
}
