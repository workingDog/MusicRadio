//
//  ToolBar.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//
import SwiftUI
import SwiftData


enum ToolTypes: String, CaseIterable, Identifiable {
    case favorite = "Favorite"
    case radio = "Radio"
    case podcasts = "Podcasts"
    
    var id: String { rawValue }
    
    // Each segment defines its own color scheme and emoji
    var gradient: [Color] {
        let opa = 0.5
        switch self {
        case .favorite: return [.pink.opacity(opa), .purple.opacity(opa)]
        case .radio: return [.blue.opacity(opa), .cyan.opacity(opa)]
        case .podcasts: return [.orange.opacity(opa), .red.opacity(opa)]
        }
    }
    
    var icon: String {
        switch self {
        case .favorite: return "🎵"
        case .radio: return "📻"
        case .podcasts: return "🎙️"
        }
    }
    
    var description: String {
        switch self {
        case .favorite: return "Enjoy your favorite songs."
        case .radio: return "Listen to live stations."
        case .podcasts: return "Catch up on trending shows."
        }
    }
}


struct ToolsView: View {
    @Binding var selectedTool: ToolTypes
    
    enum Segment: String, CaseIterable, Identifiable {
        case favorite = "Favorite"
        case radio = "Radio"
        case podcasts = "Podcasts"
        
        var id: String { rawValue }
    }
    
    @State private var showSettings: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Picker("", selection: $selectedTool) {
                    ForEach(ToolTypes.allCases) { tool in
                        Text(tool.rawValue).tag(tool)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 260)
                .padding(.horizontal)
                Spacer()
                Button{
                    showSettings = true
                } label: {
                    Image(systemName: "gear")
                }.font(.system(size: 30))
            }
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 2)
            .padding(.horizontal)
            .padding(.top, 8)
            
            Text(selectedTool.icon)
                .font(.system(size: 60))
                .shadow(radius: 5)
                .frame(height: 66)
                .padding(10)
            
            Spacer()
        }
        .frame(height: 111)
        .padding(.top, 15)
        .sheet(isPresented: $showSettings) {
            Text("settings")
        }
    }
}



/*
 .toolbar {
     ToolbarItem(placement: .topBarTrailing) {
         Picker("", selection: $selectedTool) {
             ForEach(0..<tools.count, id: \.self) { index in
                 Text(tools[index])
             }
         }
         .pickerStyle(.segmented)
         .frame(width: 240)
         .padding(.vertical, 8)
         .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
         .clipShape(RoundedRectangle(cornerRadius: 10))
         .shadow(radius: 2)
     }
 }
 .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
 .toolbarBackground(.visible, for: .navigationBar)
 */
