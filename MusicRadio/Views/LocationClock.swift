//
//  LocationClock.swift
//  MusicRadio
//
//  Created by Ringo Wathelet on 2026/10/17.
//
import Foundation
import CoreLocation
import MapKit
import SwiftUI


struct LocationClock: View {
    let station: RadioStation
    
    @State private var timeZone: TimeZone?
    
    var body: some View {
        Group {
            if let timeZone {
                TimelineView(.periodic(from: .now, by: 60)) { context in
                    let date = context.date
                    let format = Date.FormatStyle(date: .omitted, time: .shortened, timeZone: timeZone).hour().minute()
                    HStack(spacing: 6) {
                        Text(date.formatted(format)).monospacedDigit()
                        if stationWeekdayDiffers(from: date, timeZone: timeZone) {
                            Text(date.formatted(Date.FormatStyle(date: .omitted, time: .omitted, timeZone: timeZone).weekday(.wide)))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else {
                Text("—")
            }
        }
        .task {
            do {
                if let tz = try await TimeLocator.stationTimeZone(country: station.country, state: station.state) {
                    timeZone = tz
                } else {
                    timeZone = .gmt
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func stationWeekdayDiffers(from date: Date, timeZone: TimeZone) -> Bool {
        var stationCalendar = Calendar.autoupdatingCurrent
        stationCalendar.timeZone = timeZone
        return stationCalendar.component(.weekday, from: date) != Calendar.autoupdatingCurrent.component(.weekday, from: date)
    }

}
