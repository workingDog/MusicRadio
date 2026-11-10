//
//  LyricsTTML.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2026/11/09.
//
import SwiftUI
import Foundation
import LRCLIBKit


// see https://api.betterlyrics.org/

// extension to the LRCLIBKit LyricsFile
extension LyricsFile {
    
    public init(
        ttml: LyricsTTML,
        title: String,
        artist: String,
        album: String,
        durationMs: Int,
        instrumental: Bool = false
    ) {
        let lines = ttml.songParts.flatMap { part in
            part.lines.map { line in
                LyricLine(
                    text: line.text,
                    startMs: Int((line.start * 1000).rounded()),
                    endMs: Int((line.end * 1000).rounded()),
                    words: line.words.map { word in
                        LyricWord(
                            text: word.text,
                            startMs: Int((word.start * 1000).rounded()),
                            endMs: Int((word.end * 1000).rounded())
                        )
                    }
                )
            }
        }
        
        self.init(
            version: "1.0",
            metadata: Metadata(
                title: title,
                artist: artist,
                album: album,
                durationMs: durationMs,
                instrumental: instrumental
            ),
            lines: lines,
            plain: lines.map(\.text).joined(separator: "\n")
        )
    }
}

public struct LyricsTTML: Codable, Identifiable, Sendable {
    public let id = UUID()
    public var songParts: [LyricTTMLPart] = []
    
    public enum CodingKeys: CodingKey {
        case songParts
    }
    
    public init() { }
    
    public init(songParts: [LyricTTMLPart]) {
        self.songParts = songParts
    }
}

public struct LyricTTMLPart: Identifiable, Codable {
    public let id = UUID()
    public var name: String?
    public var lines: [LyricTTMLLine] = []
    
    public enum CodingKeys: CodingKey {
        case name
        case lines
    }
    
    public init(name: String? = nil, lines: [LyricTTMLLine]) {
        self.name = name
        self.lines = lines
    }
}

public struct LyricTTMLLine: Identifiable, Codable {
    public let id = UUID()
    public var text: String
    public var start: Double
    public var end: Double
    public var words: [LyricTTMLWord] = []
    
    public enum CodingKeys: CodingKey {
        case text
        case start
        case end
        case words
    }
    
    public init(text: String, start: Double, end: Double, words: [LyricTTMLWord]) {
        self.text = text
        self.start = start
        self.end = end
        self.words = words
    }
}

public struct LyricTTMLWord: Identifiable, Codable {
    public let id = UUID()
    public var text: String
    public var start: Double
    public var end: Double
    
    public enum CodingKeys: CodingKey {
        case text
        case start
        case end
    }
    
    public init(text: String, start: Double, end: Double) {
        self.text = text
        self.start = start
        self.end = end
    }
}


public struct BetterLyrics: Decodable {
    public let ttml: String
    public let score: Double?
    
    public enum CodingKeys: CodingKey {
        case ttml
        case score
    }
    
    public init(ttml: String, score: Double?) {
        self.ttml = ttml
        self.score = score
    }
}

final class TTMLParser: NSObject, XMLParserDelegate {
    
    private var result = LyricsTTML()
    private var currentPart: LyricTTMLPart?
    private var currentLine: LyricTTMLLine?
    private var currentWord: LyricTTMLWord?
    
    override init() { }
    
    func parse(_ xml: String) throws -> LyricsTTML {
        result = LyricsTTML()
        
        guard let data = xml.data(using: .utf8) else {
            throw TTMLParsingError.invalidData
        }
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.shouldResolveExternalEntities = false
        
        guard parser.parse() else {
            throw parser.parserError ?? TTMLParsingError.invalidXML
        }
        
        return result
    }
    
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        switch elementName {
        case "div":
            currentPart = LyricTTMLPart(
                name: attributeDict.first { $0.key.hasSuffix("songPart") }?.value, lines: []
            )
            
        case "p":
            currentLine = LyricTTMLLine(
                text: "",
                start: Self.time(attributeDict["begin"]),
                end: Self.time(attributeDict["end"]), words: []
            )
            
        case "span":
            currentWord = LyricTTMLWord(
                text: "",
                start: Self.time(attributeDict["begin"]),
                end: Self.time(attributeDict["end"])
            )
            
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentLine?.text += string
        currentWord?.text += string
    }
    
    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        switch elementName {
        case "span":
            if let word = currentWord {
                currentLine?.words.append(word)
            }
            currentWord = nil
            
        case "p":
            if let line = currentLine {
                currentPart?.lines.append(
                    LyricTTMLLine(
                        text: line.text.trimmingCharacters(in: .whitespacesAndNewlines),
                        start: line.start,
                        end: line.end,
                        words: line.words
                    )
                )
            }
            currentLine = nil
            
        case "div":
            if let part = currentPart {
                result.songParts.append(part)
            }
            currentPart = nil
            
        default:
            break
        }
    }
    
    private static func time(_ value: String?) -> Double {
        guard let value else { return 0 }
        
        let components = value.split(separator: ":")
        
        if components.count == 3 {
            return (Double(components[0]) ?? 0) * 3600
                + (Double(components[1]) ?? 0) * 60
                + (Double(components[2]) ?? 0)
        }
        
        if components.count == 2 {
            return (Double(components[0]) ?? 0) * 60
                + (Double(components[1]) ?? 0)
        }
        
        return Double(value.replacingOccurrences(of: "s", with: "")) ?? 0
    }
}

public enum TTMLParsingError: Error {
    case invalidData
    case invalidXML
}
