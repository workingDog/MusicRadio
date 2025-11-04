//
//  ToolsView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/02.
//
import SwiftUI
import SwiftData
import UIKit
import AVKit


enum ToolTypes: String, CaseIterable, Identifiable {
    case favorites = "Favorites"
    case countries = "Countries"
    case stations = "Stations"
    
    var id: String { rawValue }
    
    // Each type defines its own color scheme and emoji
    var gradient: [Color] {
        let opa = 0.5
        switch self {
        case .favorites: return [.pink.opacity(opa), .purple.opacity(opa)]
        case .stations: return [.blue.opacity(opa), .cyan.opacity(opa)]
        case .countries: return [.orange.opacity(opa), .red.opacity(opa)]
        }
    }
    
    var icon: String {
        switch self {
            case .favorites: return "🎵"
            case .stations: return "📻"
            case .countries: return "🎙️"
        }
    }
    
    var description: String {
        switch self {
            case .favorites: return "Enjoy your favorite songs."
            case .stations: return "Listen to live stations."
            case .countries: return "Check all countries' radio stations."
        }
    }
}

struct ToolsView: View {
    @Binding var selectedTool: ToolTypes
    
    @State private var showSettings: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                AirPlayButton()
                    .frame(width: 50, height: 50)
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
                }
                .font(.system(size: 30))
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 2)
            .padding(.horizontal)
        }
        .frame(height: 111)
        .sheet(isPresented: $showSettings) {
            Text("settings")
        }
    }
}

struct AirPlayButton: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
 //       view.prioritizesVideoDevices = false    // set to true for Apple TV
        view.activeTintColor = .systemBlue      // highlighted color
        view.tintColor = .gray                  // normal color
        view.prioritizesVideoDevices = false    // audio only
        return view
    }
    
    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {
        // Nothing to update
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {}
}
