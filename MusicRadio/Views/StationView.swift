//
//  StationView.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2025/11/03.
//
import SwiftUI
import WebKit


struct StationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PlayerManager.self) var playerManager
    @Environment(ColorsModel.self) var colorsModel
    
    var station: RadioStation
    let maxRating: Int
    
    @State private var showWeb: Bool = false
    @State private var stars = 0
    
    var body: some View {
        ZStack{
            
            if playerManager.station == station, playerManager.isPlaying {
                EqualizerView()
            }
 
            VStack {
                HStack {
                    Button {
                        station.isFavourite.toggle()
                        if !station.isFavourite {
                            SwiftDataHelper.findAndRemove(station: station, in: modelContext)
                        } else {
                            SwiftDataHelper.updateOrInsert(station: station, in: modelContext)
                        }
                    } label: {
                        Image(systemName: station.isFavourite ? "heart.fill" : "heart.slash")
                            .resizable()
                            .foregroundStyle(colorsModel.favouriteColor)
                            .frame(width: 30, height: 30)
                            .padding(5)
                    }.buttonStyle(.borderless)
                    
                    Spacer()
                    
                    Text(StationTag.inferDominantGenre(from: station.tags).rawValue)
  
                    Spacer()
                    
                    Button {
                        showWeb = true
                    } label: {
                        Image(systemName: "network")
                            .resizable()
                            .foregroundColor(colorsModel.netColor)
                            .frame(width: 30, height: 30)
                            .padding(5)
                    }.buttonStyle(.borderless)
                }
                
                RatingStarsView(station, maxRating)
                
                Image(uiImage: station.faviconImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                
                Text(station.name)
                    .lineLimit(1)
                    .padding(5)
                
            }
        }
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .onTapGesture {
                playerManager.pause()
                playerManager.currentSong = ""
                // tap on same station to unselect it
                if playerManager.station == station {
                    playerManager.station = nil
                } else {
                    playerManager.station = station
                }
            }
            .background(.white.opacity(0.4))
         //   .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 12)) // for iOS26+
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .fullScreenCover(isPresented: $showWeb) {
                WebViewScreen(station: station)
            }
        }

}

struct WebViewScreen: View {
    @Environment(\.dismiss) private var dismiss
    let station: RadioStation

    var body: some View {
        VStack {
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(6)

            Divider()

            if let url = URL(string: station.homepage),
                UIApplication.shared.canOpenURL(url) {
                if #available(iOS 26.0, *) {
                    WebView(url: url)
                } else {
                    OldWebView(urlString: station.homepage)
                }
             } else {
                 Text("No homepage available").font(Font.largeTitle.bold())
                 Spacer()
             }
        }
    }
}

private struct OldWebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Only reload if URL changed
        if let newURL = URL(string: urlString), uiView.url != newURL {
            uiView.load(URLRequest(url: newURL))
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, WKNavigationDelegate { }
}
